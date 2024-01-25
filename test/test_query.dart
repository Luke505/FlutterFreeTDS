import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:freetds/freetds.dart";
import "package:tempo/tempo.dart";

import 'utils/test_utils.dart';

Future<void> main() async {
  late FreeTDS freetds;

  setUp(() async {
    freetds = TestUtils.setUpTest();
  });

  tearDown(() async {
    await FreeTDS.afterTest();
  });

  test('Test SQL CREATE', () async {
    await freetds.connect(
      host: TestUtils.host,
      username: TestUtils.username,
      password: TestUtils.password,
      database: TestUtils.database,
      encryption: TestUtils.encryption,
    );
    expect(FreeTDS.lastError, isNull);

    // Create a table
    var createResult = await freetds.query("""
      CREATE TABLE #test_freetds
      (
        id            INTEGER DEFAULT AUTOINCREMENT PRIMARY KEY,
        name          VARCHAR(255),
        email         VARCHAR(255),
        creationTime  DATETIME DEFAULT CURRENT_TIMESTAMP,
      );
    """);
    expect(FreeTDS.lastError, isNull);
    expect(createResult.length, equals(1));
    expect(createResult.last.data.length, equals(0));
    expect(createResult.last.affectedRows, equals(-1));

    // Drop the test table
    await freetds.query("DROP TABLE #test_freetds");
    expect(FreeTDS.lastError, isNull);

    // Finally, close the connection
    await freetds.disconnect();
    expect(FreeTDS.lastError, isNull);
  });

  test('Test SQL error', () async {
    await freetds.connect(
      host: TestUtils.host,
      username: TestUtils.username,
      password: TestUtils.password,
      database: TestUtils.database,
      encryption: TestUtils.encryption,
    );
    expect(FreeTDS.lastError, isNull);

    expect(() async => await freetds.query("CREATE TABLE #test_freetds ( ... );"), throwsA(isA<FreeTDSException>()));
    expect(FreeTDS.lastError, isNotNull);

    FreeTDS.lastError = null;
    await freetds.disconnect();
    expect(FreeTDS.lastError, isNull);
  });

  test('Test SQL INSERT', () async {
    await freetds.connect(
      host: TestUtils.host,
      username: TestUtils.username,
      password: TestUtils.password,
      database: TestUtils.database,
      encryption: TestUtils.encryption,
    );

    // Create a table
    await freetds.query("""
      CREATE TABLE #test_freetds
      (
        id            INTEGER DEFAULT AUTOINCREMENT PRIMARY KEY,
        name          VARCHAR(255),
        email         VARCHAR(255),
        creationTime  DATETIME DEFAULT CURRENT_TIMESTAMP,
      );
    """);

    // Insert some data
    var insertResult = await freetds.query(
      "INSERT INTO #test_freetds (name, email) VALUES (?, ?);",
      [
        QueryParam("Bob"),
        QueryParam("bob@bob.com"),
      ],
    );
    expect(insertResult.length, equals(1));
    expect(insertResult.last.data.length, equals(0));
    expect(insertResult.last.affectedRows, equals(1));

    var result = await freetds.query("SELECT @@IDENTITY");
    expect(result.length, equals(1));
    expect(result.last.data.length, equals(1));
    expect(result.last.data[0].values.length, equals(1));
    expect(result.last.affectedRows, equals(-1));

    var insertId = result.last.data[0].values.first;

    expect(insertId, equals(1));
    expect(FreeTDS.lastError, isNull);

    // Drop the test table
    await freetds.query("DROP TABLE #test_freetds");
    expect(FreeTDS.lastError, isNull);

    // Finally, close the connection
    await freetds.disconnect();
    expect(FreeTDS.lastError, isNull);
  });

  test('Test SQL INSERT & SELECT', () async {
    await freetds.connect(
      host: TestUtils.host,
      username: TestUtils.username,
      password: TestUtils.password,
      database: TestUtils.database,
      encryption: TestUtils.encryption,
    );

    // Create a table
    await freetds.query("""
      CREATE TABLE #test_freetds
      (
        id            INTEGER DEFAULT AUTOINCREMENT PRIMARY KEY,
        name          VARCHAR(255),
        email         VARCHAR(255),
        creationTime  DATETIME DEFAULT CURRENT_TIMESTAMP,
      );
    """);

    // Insert some data
    var insertResult = await freetds.query(
      "INSERT INTO #test_freetds (name, email, creationTime) VALUES (?, ?, ?);",
      [
        QueryParam("Bob"),
        QueryParam("bob@bob.com"),
        QueryParam("2000-01-01 23:59:59+0000"),
      ],
    );
    expect(insertResult.length, equals(1));
    expect(insertResult.last.data.length, equals(0));
    expect(insertResult.last.affectedRows, equals(1));

    var result = await freetds.query("SELECT @@IDENTITY");
    expect(result.length, equals(1));
    expect(result.last.data.length, equals(1));
    expect(result.last.data[0].values.length, equals(1));
    expect(result.last.affectedRows, equals(-1));

    var insertId = result.last.data[0].values.first;

    expect(insertId, equals(1));

    // Query the database using a parameterized query
    var results = await freetds.query("SELECT * FROM #test_freetds WHERE id = ?", [QueryParam(insertId)]);
    expect(results.length, equals(1));
    expect(results.last.data.length, equals(1));
    expect(results.last.data[0].values.length, equals(4));
    expect(results.last.affectedRows, equals(-1));

    expect(results.last.data[0]["id"], equals(1));
    expect(results.last.data[0]["name"], equals("Bob"));
    expect(results.last.data[0]["email"], equals("bob@bob.com"));
    expect(results.last.data[0]["creationTime"], equals(LocalDateTime.parse("2000-01-01T23:59:59")));
    expect(FreeTDS.lastError, isNull);

    // Drop the test table
    await freetds.query("DROP TABLE #test_freetds");
    expect(FreeTDS.lastError, isNull);

    // Finally, close the connection
    await freetds.disconnect();
    expect(FreeTDS.lastError, isNull);
  });

  test('Test SQL CREATE, INSERT, SELECT & UPDATE', () async {
    await freetds.connect(
      host: TestUtils.host,
      username: TestUtils.username,
      password: TestUtils.password,
      database: TestUtils.database,
      encryption: TestUtils.encryption,
    );

    // Create a table
    await freetds.query("""
      CREATE TABLE #test_freetds
      (
        id            INTEGER DEFAULT AUTOINCREMENT PRIMARY KEY,
        name          VARCHAR(255),
        email         VARCHAR(255),
        creationTime  DATETIME DEFAULT CURRENT_TIMESTAMP,
      );
    """);

    var creationStartDateResult = await freetds.query("SELECT GETDATE()");
    expect(creationStartDateResult.length, equals(1));
    expect(creationStartDateResult.last.data.length, equals(1));
    expect(creationStartDateResult.last.data[0].values.length, equals(1));
    expect(creationStartDateResult.last.affectedRows, equals(-1));

    var creationStartDate = creationStartDateResult.last.data[0].values.first as LocalDateTime;

    sleep(Duration(milliseconds: 50));

    // Insert some data
    var insertResult = await freetds.query(
      "INSERT INTO #test_freetds (name, email) VALUES (?, ?);",
      [
        QueryParam("Bob"),
        QueryParam("bob@bob.com"),
      ],
    );
    expect(insertResult.length, equals(1));
    expect(insertResult.last.data.length, equals(0));
    expect(insertResult.last.affectedRows, equals(1));

    var result = await freetds.query("SELECT @@IDENTITY");
    expect(result.length, equals(1));
    expect(result.last.data.length, equals(1));
    expect(result.last.data[0].values.length, equals(1));
    expect(result.last.affectedRows, equals(-1));

    var insertId = result.last.data[0].values.first;

    expect(insertId, equals(1));

    sleep(Duration(milliseconds: 50));

    var creationEndDateResult = await freetds.query("SELECT GETDATE()");
    expect(creationEndDateResult.length, equals(1));
    expect(creationEndDateResult.last.data.length, equals(1));
    expect(creationEndDateResult.last.data[0].values.length, equals(1));
    expect(creationEndDateResult.last.affectedRows, equals(-1));

    var creationEndDate = creationEndDateResult.last.data[0].values.first as LocalDateTime;

    expect(creationStartDate.timespanUntil(creationEndDate).inMilliseconds, greaterThanOrEqualTo(100));

    // Query the database using a parameterized query
    var results = await freetds.query("SELECT * FROM #test_freetds WHERE id = ?", [QueryParam(insertId)]);
    expect(results.length, equals(1));
    expect(results.last.data.length, equals(1));
    expect(results.last.data[0].values.length, equals(4));
    expect(results.last.affectedRows, equals(-1));

    expect(results.last.data[0]["id"], equals(1));
    expect(results.last.data[0]["name"], equals("Bob"));
    expect(results.last.data[0]["email"], equals("bob@bob.com"));
    expect(results.last.data[0]["creationTime"], allOf(greaterThan(creationStartDate), lessThan(creationEndDate)));
    expect(FreeTDS.lastError, isNull);

    // Update some data
    var updateResult = await freetds.query("UPDATE #test_freetds SET name = ? WHERE name = ?", [QueryParam("New Bob"), QueryParam("Bob")]);
    expect(updateResult.length, equals(1));
    expect(updateResult.last.data.length, equals(0));
    expect(updateResult.last.affectedRows, equals(1));

    // Query again database using a parameterized query
    var resultsAfterUpdate = await freetds.query("SELECT * FROM #test_freetds WHERE id = ?", [QueryParam(insertId)]);
    expect(resultsAfterUpdate.length, equals(1));
    expect(resultsAfterUpdate.last.data.length, equals(1));
    expect(resultsAfterUpdate.last.data[0].values.length, equals(4));
    expect(resultsAfterUpdate.last.affectedRows, equals(-1));

    expect(resultsAfterUpdate.last.data[0]["id"], equals(1));
    expect(resultsAfterUpdate.last.data[0]["name"], equals("New Bob"));
    expect(resultsAfterUpdate.last.data[0]["email"], equals("bob@bob.com"));
    expect(resultsAfterUpdate.last.data[0]["creationTime"], equals(results.last.data[0]["creationTime"]));
    expect(FreeTDS.lastError, isNull);

    // Drop the test table
    await freetds.query("DROP TABLE #test_freetds");
    expect(FreeTDS.lastError, isNull);

    // Finally, close the connection
    await freetds.disconnect();
    expect(FreeTDS.lastError, isNull);
  });
}
