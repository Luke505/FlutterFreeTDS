import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:freetds/freetds.dart";

import "utils/test_utils.dart";

Future<void> main() async {
  final testUtils = TestUtils();

  setUp(() async {
    await testUtils.setUpTest();
  });

  tearDown(() async {
    await testUtils.tearDownTest();
  });

  test("Test connection", () async {
    // Open a connection (test_db should already exist)
    await FreeTDS.connect(
      host: testUtils.host,
      username: testUtils.username,
      password: testUtils.password,
      database: testUtils.database,
      encryption: testUtils.encryption,
      appName: "Test App", //
    );
    sleep(Duration(milliseconds: 300));
    if (FreeTDS.library != null) {
      testUtils.expectNoLibraryError();
    }

    // Finally, close the connection
    await FreeTDS.disconnect();
    sleep(Duration(milliseconds: 300));
    if (FreeTDS.library != null) {
      testUtils.expectNoLibraryError();
    }
  });

  test("Test connection error", () async {
    try {
      await FreeTDS.connect(
        host: "0.0.0.0:80",
        username: "...",
        password: "...",
        database: "...",
        encryption: null, //
      );

      fail("Exception not thrown");
    } on FreeTDSException catch (e) {
      expect(e.message, equals(FreeTDSErrorMessage.connectionError.message));
    }

    if (FreeTDS.library != null) {
      testUtils.expectLibraryError("Unable to connect: Adaptive Server is unavailable or does not exist (0.0.0.0)", 9);
    }

    // Finally, close the connection
    await FreeTDS.disconnect();
    if (FreeTDS.library != null) {
      testUtils.expectNoLibraryError();
    }
  });
}
