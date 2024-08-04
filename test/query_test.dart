import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:freetds/freetds.dart';
import 'package:tempo/tempo.dart';

import 'utils/test_utils.dart';

Future<void> main() async {
  setUp(() async {
    await TestUtils.setUpTest();
  });

  tearDown(() async {
    await TestUtils.tearDownTest();
  });

  test('Test SQL CREATE', () {
    FreeTDS.connect(
      host: TestUtils.host,
      username: TestUtils.username,
      password: TestUtils.password,
      database: TestUtils.database,
      encryption: TestUtils.encryption,
    );
    TestUtils.expectNoError();

    // Create a table
    var createResult = FreeTDS.query("""
      CREATE TABLE #test_freetds
      (
        id            INTEGER DEFAULT AUTOINCREMENT PRIMARY KEY,
        name          VARCHAR(255),
        email         VARCHAR(255),
        creationTime  DATETIME DEFAULT CURRENT_TIMESTAMP,
      );
    """);
    TestUtils.expectNoError();
    expect(createResult.length, equals(1));
    expect(createResult.last.data.length, equals(0));
    expect(createResult.last.affectedRows, equals(-1));

    // Drop the test table
    FreeTDS.query("DROP TABLE #test_freetds");
    TestUtils.expectNoError();

    // Finally, close the connection
    FreeTDS.disconnect();
    TestUtils.expectNoError();
  });

  test('Test SQL error', () {
    FreeTDS.connect(
      host: TestUtils.host,
      username: TestUtils.username,
      password: TestUtils.password,
      database: TestUtils.database,
      encryption: TestUtils.encryption,
    );
    TestUtils.expectNoError();

    try {
      FreeTDS.query("CREATE TABLE #test_freetds ( ... );");

      fail("Exception not thrown");
    } on FreeTDSException catch (e) {
      expect(e.message, equals("Attempting to execute last command failed."));
    }

    TestUtils.expectError("SQL Anywhere Error -131: Syntax error near '.' on line 1 ", 15);

    FreeTDS.disconnect();
    TestUtils.expectNoError();
  });

  test('Test SQL INSERT', () {
    FreeTDS.connect(
      host: TestUtils.host,
      username: TestUtils.username,
      password: TestUtils.password,
      database: TestUtils.database,
      encryption: TestUtils.encryption,
    );

    // Create a table
    FreeTDS.query("""
      CREATE TABLE #test_freetds
      (
        id            INTEGER DEFAULT AUTOINCREMENT PRIMARY KEY,
        name          VARCHAR(255),
        email         VARCHAR(255),
        creationTime  DATETIME DEFAULT CURRENT_TIMESTAMP,
      );
    """);

    // Insert some data
    var insertResult = FreeTDS.query(
      "INSERT INTO #test_freetds (name, email) VALUES (?, ?);",
      [
        QueryParam("Bob"),
        QueryParam("bob@bob.com"),
      ],
    );
    expect(insertResult.length, equals(1));
    expect(insertResult.last.data.length, equals(0));
    expect(insertResult.last.affectedRows, equals(1));

    var result = FreeTDS.query("SELECT @@IDENTITY");
    expect(result.length, equals(1));
    expect(result.last.data.length, equals(1));
    expect(result.last.data[0].values.length, equals(1));
    expect(result.last.affectedRows, equals(-1));

    var insertId = result.last.data[0].values.first;

    expect(insertId, equals(1));
    TestUtils.expectNoError();

    // Drop the test table
    FreeTDS.query("DROP TABLE #test_freetds");
    TestUtils.expectNoError();

    // Finally, close the connection
    FreeTDS.disconnect();
    TestUtils.expectNoError();
  });

  test('Test SQL INSERT & SELECT', () {
    FreeTDS.connect(
      host: TestUtils.host,
      username: TestUtils.username,
      password: TestUtils.password,
      database: TestUtils.database,
      encryption: TestUtils.encryption,
    );

    // Create a table
    FreeTDS.query("""
      CREATE TABLE #test_freetds
      (
        id            INTEGER DEFAULT AUTOINCREMENT PRIMARY KEY,
        name          VARCHAR(255),
        email         VARCHAR(255),
        creationTime  DATETIME DEFAULT CURRENT_TIMESTAMP,
      );
    """);

    // Insert some data
    var insertResult = FreeTDS.query(
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

    var result = FreeTDS.query("SELECT @@IDENTITY");
    expect(result.length, equals(1));
    expect(result.last.data.length, equals(1));
    expect(result.last.data[0].values.length, equals(1));
    expect(result.last.affectedRows, equals(-1));

    var insertId = result.last.data[0].values.first;

    expect(insertId, equals(1));

    // Query the database using a parameterized query
    var results = FreeTDS.query("SELECT * FROM #test_freetds WHERE id = ?", [QueryParam(insertId)]);
    expect(results.length, equals(1));
    expect(results.last.data.length, equals(1));
    expect(results.last.data[0].values.length, equals(4));
    expect(results.last.affectedRows, equals(-1));

    expect(results.last.data[0]["id"], equals(1));
    expect(results.last.data[0]["name"], equals("Bob"));
    expect(results.last.data[0]["email"], equals("bob@bob.com"));
    expect(results.last.data[0]["creationTime"], equals(LocalDateTime.parse("2000-01-01T23:59:59")));
    TestUtils.expectNoError();

    // Drop the test table
    FreeTDS.query("DROP TABLE #test_freetds");
    TestUtils.expectNoError();

    // Finally, close the connection
    FreeTDS.disconnect();
    TestUtils.expectNoError();
  });

  test('Test SQL CREATE, INSERT, SELECT & UPDATE', () {
    FreeTDS.connect(
      host: TestUtils.host,
      username: TestUtils.username,
      password: TestUtils.password,
      database: TestUtils.database,
      encryption: TestUtils.encryption,
    );

    // Create a table
    FreeTDS.query("""
      CREATE TABLE #test_freetds
      (
        id            INTEGER DEFAULT AUTOINCREMENT PRIMARY KEY,
        name          VARCHAR(255),
        email         VARCHAR(255),
        creationTime  DATETIME DEFAULT CURRENT_TIMESTAMP,
      );
    """);

    var creationStartDateResult = FreeTDS.query("SELECT GETDATE()");
    expect(creationStartDateResult.length, equals(1));
    expect(creationStartDateResult.last.data.length, equals(1));
    expect(creationStartDateResult.last.data[0].values.length, equals(1));
    expect(creationStartDateResult.last.affectedRows, equals(-1));

    var creationStartDate = creationStartDateResult.last.data[0].values.first as LocalDateTime;

    sleep(Duration(milliseconds: 50));

    // Insert some data
    var insertResult = FreeTDS.query(
      "INSERT INTO #test_freetds (name, email) VALUES (?, ?);",
      [
        QueryParam("Bob"),
        QueryParam("bob@bob.com"),
      ],
    );
    expect(insertResult.length, equals(1));
    expect(insertResult.last.data.length, equals(0));
    expect(insertResult.last.affectedRows, equals(1));

    var result = FreeTDS.query("SELECT @@IDENTITY");
    expect(result.length, equals(1));
    expect(result.last.data.length, equals(1));
    expect(result.last.data[0].values.length, equals(1));
    expect(result.last.affectedRows, equals(-1));

    var insertId = result.last.data[0].values.first;

    expect(insertId, equals(1));

    sleep(Duration(milliseconds: 50));

    var creationEndDateResult = FreeTDS.query("SELECT GETDATE()");
    expect(creationEndDateResult.length, equals(1));
    expect(creationEndDateResult.last.data.length, equals(1));
    expect(creationEndDateResult.last.data[0].values.length, equals(1));
    expect(creationEndDateResult.last.affectedRows, equals(-1));

    var creationEndDate = creationEndDateResult.last.data[0].values.first as LocalDateTime;

    expect(creationStartDate.timespanUntil(creationEndDate).inMilliseconds, greaterThanOrEqualTo(100));

    // Query the database using a parameterized query
    var results = FreeTDS.query("SELECT * FROM #test_freetds WHERE id = ?", [QueryParam(insertId)]);
    expect(results.length, equals(1));
    expect(results.last.data.length, equals(1));
    expect(results.last.data[0].values.length, equals(4));
    expect(results.last.affectedRows, equals(-1));

    expect(results.last.data[0]["id"], equals(1));
    expect(results.last.data[0]["name"], equals("Bob"));
    expect(results.last.data[0]["email"], equals("bob@bob.com"));
    expect(results.last.data[0]["creationTime"], allOf(greaterThan(creationStartDate), lessThan(creationEndDate)));
    TestUtils.expectNoError();

    // Update some data
    var updateResult = FreeTDS.query("UPDATE #test_freetds SET name = ? WHERE name = ?", [QueryParam("New Bob"), QueryParam("Bob")]);
    expect(updateResult.length, equals(1));
    expect(updateResult.last.data.length, equals(0));
    expect(updateResult.last.affectedRows, equals(1));

    // Query again database using a parameterized query
    var resultsAfterUpdate = FreeTDS.query("SELECT * FROM #test_freetds WHERE id = ?", [QueryParam(insertId)]);
    expect(resultsAfterUpdate.length, equals(1));
    expect(resultsAfterUpdate.last.data.length, equals(1));
    expect(resultsAfterUpdate.last.data[0].values.length, equals(4));
    expect(resultsAfterUpdate.last.affectedRows, equals(-1));

    expect(resultsAfterUpdate.last.data[0]["id"], equals(1));
    expect(resultsAfterUpdate.last.data[0]["name"], equals("New Bob"));
    expect(resultsAfterUpdate.last.data[0]["email"], equals("bob@bob.com"));
    expect(resultsAfterUpdate.last.data[0]["creationTime"], equals(results.last.data[0]["creationTime"]));
    TestUtils.expectNoError();

    // Drop the test table
    FreeTDS.query("DROP TABLE #test_freetds");
    TestUtils.expectNoError();

    // Finally, close the connection
    FreeTDS.disconnect();
    TestUtils.expectNoError();
  });
}
