import "dart:convert";
import "dart:ffi";
import "dart:io";

import "package:collection/collection.dart";
import "package:dart_docker/dart_docker.dart" as docker;
import "package:ffi/ffi.dart";
import "package:flutter_test/flutter_test.dart";
import "package:freetds/freetds.dart";
import "package:freetds/src/library/model/native/db_error.dart";
import "package:http/http.dart";
import "package:logger/logger.dart";
import "package:uuid/uuid.dart";

class TestUtils {
  String host = "0.0.0.0:2638";
  String username = "dba";
  String password = "sql";
  String database = "test";
  SYBEncryptionLevel? encryption = null;
  bool useDocker = true;

  String? containerId = null;

  final Logger logger = Logger(
    level: Level.all,
    output: ConsoleOutput(),
    printer: SimplePrinter(
      colors: true,
      printTime: true, //
    ),
    filter: ProductionFilter(), //
  );

  Future<void> setUpTest() async {
    await freeTDSSetUp();
    if (useDocker) {
      await setUpDockerContainer();
    }
  }

  Future<void> tearDownTest() async {
    await FreeTDS.close();
    if (useDocker) {
      await tearDownDockerContainer();
    }
  }

  Future<void> freeTDSSetUp() async {
    String? libraryPath;

    if (Platform.isMacOS) {
      libraryPath =
          "macos/freetds/FreeTDS.xcframework/macos-arm64_x86_64/FreeTDS.framework/FreeTDS";
    } else if (Platform.isWindows) {
      libraryPath = "windows/sybdb.dll";
    } else if (Platform.isAndroid) {
      libraryPath = null;
    } else {
      throw UnsupportedError("FreeTDS tests are only supported on macOS and windows.");
    }

    await FreeTDS.openForTest(libraryPath);

    FreeTDS.logger = (Level level, String msg) => logger.log(level, msg);
    FreeTDS.errorStream?.stream.listen((event) {
      logger.e(event);
    });
    FreeTDS.messageStream?.stream.listen((event) {
      logger.d(event);
    });
  }

  Future<void> setUpDockerContainer() async {
    database = "TEST_${Uuid().v4()}";
    final databaseFileName = "test";
    final api = docker.DockerSocketClient();
    final container = await api.container.containerCreate(
      docker.ContainerCreateRequest(
        image: "sybase:17",
        healthcheck: docker.HealthConfig(
          test: [
            "CMD",
            "sh",
            "-c",
            "dbisqlc -c \"UID=$username;PWD=$password;SERVERNAME=$database\" -q 'SELECT TOP 1 * FROM SYSTABLE'", //
          ],
          interval: 1_000_000_000,
          timeout: 1_000_000_000,
          retries: 60, //
        ),
        exposedPorts: {
          "2638/tcp": {}, //
        },
        hostConfig: docker.HostConfig(portBindings: {"2638/tcp": []}),
        cmd: [
          "sh",
          "-c",
          "dbinit -dba '$username,$password' -mpl 3 '/db/$databaseFileName.db'"
              " && dbsrv17 -n '$database' '/db/$databaseFileName.db'", //
        ],
      ),
    );
    if (container?.id == null) {
      throw StateError(
        "Failed to create container with image: sybase:17. Container ID is null."
        " Please ensure the Docker image exists and has correct permissions.",
      );
    }
    containerId = container!.id;

    logger.i("Container created with id: $containerId");

    await api.container.containerStart(containerId!);

    logger.i("Container with id: $containerId started, waiting for health check");

    sleep(Duration(seconds: 1));

    if (!await pollingContainerHealthStatusUntil(api, docker.HealthStatusEnum.healthy)) {
      throw StateError("Failed to start container with image: sybase:17. Container is not healthy.");
    }

    var containerNetworkSettings = await getContainerNetworkSettings(api);
    docker.PortBinding portBinding = containerNetworkSettings!.ports["2638/tcp"]!.first;
    host = "${portBinding.hostIp}:${portBinding.hostPort}";

    logger.i("Container with id: $containerId is now healthy on $host");
  }

  Future<void> tearDownDockerContainer() async {
    if (containerId == null) {
      return;
    }
    logger.i("Ending container with id: $containerId");

    final api = docker.DockerSocketClient();

    var containerState = await getContainerState(api);
    var containerStatus = containerState?.status;

    if (![
      docker.ContainerStateStatusEnum.removing,
      docker.ContainerStateStatusEnum.exited,
      docker.ContainerStateStatusEnum.dead,
      null, //
    ].contains(containerStatus)) {
      logger.i("Stopping container with id: $containerId, current status: $containerStatus");
      await api.container.containerStop(containerId!);

      bool containerStopped = await pollingContainerStateUntil(api, [
        docker.ContainerStateStatusEnum.removing,
        docker.ContainerStateStatusEnum.exited,
        docker.ContainerStateStatusEnum.dead, //
        null,
      ]);

      if (containerStopped) {
        logger.i("Container with id: $containerId, stopped");
      } else {
        logger.w("Container with id: $containerId, not stopped after timeout");
      }
    }

    containerState = await getContainerState(api);
    containerStatus = containerState?.status;

    if (![
      docker.ContainerStateStatusEnum.removing,
      null, //
    ].contains(containerStatus)) {
      logger.i("Deleting container with id: $containerId, current status: $containerStatus");
      await api.container.containerDelete(containerId!, force: containerStatus == docker.ContainerStateStatusEnum.dead);

      bool containerDeleted = await pollingContainerStateUntil(api, [null]);

      if (containerDeleted) {
        logger.i("Container with id: $containerId, deleted");
      } else {
        logger.w("Container with id: $containerId, not deleted after timeout");
      }
    } else {
      logger.i("Container with id: $containerId, already deleted");
    }
  }

  Future<T?> containerInspect<T>(docker.DockerSocketClient api, String attribute, T? Function(dynamic value) fromJson) async {
    try {
      final response = await api.container.containerInspectWithHttpInfo(containerId!);

      if (response.statusCode >= HttpStatus.badRequest) {
        throw docker.ApiException(response.statusCode, await dockerDecodeResponseBodyBytes(response));
      }
      if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
        Map<String, dynamic>? jsonBody = json.decode(await dockerDecodeResponseBodyBytes(response));
        return jsonBody?[attribute] != null ? fromJson(jsonBody?[attribute]) : null;
      } else {
        return null;
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<docker.ContainerState?> getContainerState(docker.DockerSocketClient api) async {
    return await containerInspect(api, "State", docker.ContainerState.fromJson);
  }

  Future<docker.NetworkSettings?> getContainerNetworkSettings(docker.DockerSocketClient api) async {
    return await containerInspect(api, "NetworkSettings", docker.NetworkSettings.fromJson);
  }

  Future<bool> pollingContainerStateUntil(
    docker.DockerSocketClient api,
    List<docker.ContainerStateStatusEnum?> validStatuses, {
    int retries = 60,
    Duration sleepDuration = const Duration(seconds: 1),
  }) async {
    var expectedStatusReached = false;
    var i = 0;
    bool firstTime = true;
    docker.ContainerStateStatusEnum? containerStatus;
    while (i < retries && !expectedStatusReached) {
      if (!firstTime) {
        sleep(sleepDuration);
      } else {
        firstTime = false;
      }

      try {
        docker.ContainerState? containerState = await getContainerState(api);
        containerStatus = containerState?.status;
      } catch (_) {
        containerStatus = null;
      }

      expectedStatusReached = validStatuses.contains(containerStatus);
      i++;
    }

    return expectedStatusReached;
  }

  Future<bool> pollingContainerHealthStatusUntil(
    docker.DockerSocketClient api,
    docker.HealthStatusEnum validHealthStatus, {
    int retries = 60,
    Duration sleepDuration = const Duration(seconds: 1),
  }) async {
    var expectedHealthStatusReached = false;
    var i = 0;
    bool firstTime = true;
    while (i < retries && !expectedHealthStatusReached) {
      if (!firstTime) {
        sleep(sleepDuration);
      } else {
        firstTime = false;
      }

      docker.ContainerState containerState = (await getContainerState(api))!;
      docker.ContainerStateStatusEnum? containerStatus = containerState.status;

      if (![
        docker.ContainerStateStatusEnum.created,
        docker.ContainerStateStatusEnum.running,
        docker.ContainerStateStatusEnum.restarting, //
      ].contains(containerStatus)) {
        throw StateError("Invalid container status: $containerStatus, during health check.");
      }

      expectedHealthStatusReached = validHealthStatus == containerState.health!.status;
      i++;
    }

    return expectedHealthStatusReached;
  }

  Future<String> dockerDecodeResponseBodyBytes(Response response) async {
    final contentType = response.headers["content-type"];
    return contentType != null && contentType.toLowerCase().startsWith("application/json")
        ? response.bodyBytes.isEmpty
            ? ""
            : utf8.decode(response.bodyBytes)
        : response.body;
  }

  void expectNoLibraryError() {
    Pointer<DBERROR> lastError = FreeTDS.library!.dbgetlasterror();
    expect(lastError, isNot(nullptr));
    expect(
      lastError.ref.dberrstr,
      equals(nullptr),
      reason:
          "Unexpected error: ${lastError.ref.dberrstr != nullptr ? lastError.ref.dberrstr.toDartString() : nullptr},"
          " with severity: ${lastError.ref.severity}",
    );
    expect(lastError.ref.severity, equals(-1));
  }

  void expectLibraryError(String error, int severity) {
    Pointer<DBERROR> lastError = FreeTDS.library!.dbgetlasterror();
    expect(lastError, isNot(nullptr));
    expect(lastError.ref.dberrstr, isNot(nullptr));
    expect(lastError.ref.dberrstr.toDartString(), equals(error));
    expect(lastError.ref.severity, equals(severity));
  }

  void assertListEquality(List actual, List expected) {
    expect(ListEquality().equals(actual, expected), isTrue, reason: "Expected: $expected\n  Actual: $actual\nAre not equals");
  }
}
