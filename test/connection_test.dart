import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:freetds/freetds.dart';

import 'utils/test_utils.dart';

Future<void> main() async {
  setUp(() async {
    await TestUtils.setUpTest();
  });

  tearDown(() async {
    await TestUtils.tearDownTest();
  });

  test('Test connection', () {
    // Open a connection (test_db should already exist)
    FreeTDS.connect(
      host: TestUtils.host,
      username: TestUtils.username,
      password: TestUtils.password,
      database: TestUtils.database,
      encryption: TestUtils.encryption,
      appName: "Test App",
    );
    sleep(Duration(milliseconds: 300));
    TestUtils.expectNoError();

    // Finally, close the connection
    FreeTDS.disconnect();
    sleep(Duration(milliseconds: 300));
    TestUtils.expectNoError();
  });

  test('Test connection error', () {
    try {
      FreeTDS.connect(
        host: "0.0.0.0:80",
        username: "...",
        password: "...",
        database: "...",
        encryption: null,
      );

      fail("Exception not thrown");
    } on FreeTDSException catch (e) {
      expect(e.message, equals(FreeTDSErrorMessage.connectionError.message));
    }

    TestUtils.expectError("Unable to connect: Adaptive Server is unavailable or does not exist (0.0.0.0)", 9);

    // Finally, close the connection
    FreeTDS.disconnect();
    TestUtils.expectNoError();
  });
}
