import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:freetds/freetds.dart";

import 'utils/test_utils.dart';

Future<void> main() async {
  late FreeTDS freetds;

  setUp(() async {
    freetds = TestUtils.setUpTest();
  });

  tearDown(() async {
    await FreeTDS.afterTest();
  });

  test('Test connection', () async {
    // Open a connection (test_db should already exist)
    await freetds.connect(
      host: TestUtils.host,
      username: TestUtils.username,
      password: TestUtils.password,
      database: TestUtils.database,
      encryption: TestUtils.encryption,
    );
    sleep(Duration(milliseconds: 300));
    expect(FreeTDS.lastError, isNull);

    // Finally, close the connection
    await freetds.disconnect();
    sleep(Duration(milliseconds: 300));
    expect(FreeTDS.lastError, isNull);
  });

  test('Test connection error', () async {
    try {
      await freetds.connect(
        host: "0.0.0.0:80",
        username: "...",
        password: "...",
        database: "...",
        encryption: null,
      );

      fail("Exception not thrown");
    } catch (e) {
      expect(e, isInstanceOf<FreeTDSException>());
      expect((e as FreeTDSException).message, equals(FreeTDSErrorMessage.connectionError.message));
    }

    expect(FreeTDS.lastError, isNotNull);
    expect(FreeTDS.lastError!.error, equals("Unable to connect: Adaptive Server is unavailable or does not exist (0.0.0.0)"));
    expect(FreeTDS.lastError!.severity, equals(9));

    // Finally, close the connection
    await freetds.disconnect();
    expect(FreeTDS.lastError, isNull);
  });
}
