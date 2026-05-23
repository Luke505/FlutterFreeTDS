import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:freetds/freetds.dart";
import "package:tempo/tempo.dart";

import "utils/test_utils.dart";

Future<void> main() async {
  final testUtils = TestUtils();

  setUp(() async {
    await testUtils.setUpTest();
  });

  tearDown(() async {
    await testUtils.tearDownTest();
  });

  test("Test SQL CREATE", () async {
    await FreeTDS.connect(
      host: testUtils.host,
      username: testUtils.username,
      password: testUtils.password,
      database: testUtils.database,
      encryption: testUtils.encryption, //
    );
    if (FreeTDS.library != null) {
      testUtils.expectNoLibraryError();
    }

    // Create a table
    var createResult = await FreeTDS.query("""
      CREATE TABLE #test_freetds
      (
        id            INTEGER DEFAULT AUTOINCREMENT PRIMARY KEY,
        name          VARCHAR(255),
        email         VARCHAR(255),
        creationTime  DATETIME DEFAULT CURRENT_TIMESTAMP,
      );
    """);
    if (FreeTDS.library != null) {
      testUtils.expectNoLibraryError();
    }
    expect(createResult.length, equals(1));
    expect(createResult.last.data.length, equals(0));
    expect(createResult.last.affectedRows, equals(-1));

    // Drop the test table
    await FreeTDS.query("DROP TABLE #test_freetds");
    if (FreeTDS.library != null) {
      testUtils.expectNoLibraryError();
    }

    // Finally, close the connection
    await FreeTDS.disconnect();
    if (FreeTDS.library != null) {
      testUtils.expectNoLibraryError();
    }
  });

  test("Test SQL error", () async {
    await FreeTDS.connect(
      host: testUtils.host,
      username: testUtils.username,
      password: testUtils.password,
      database: testUtils.database,
      encryption: testUtils.encryption, //
    );
    if (FreeTDS.library != null) {
      testUtils.expectNoLibraryError();
    }

    try {
      await FreeTDS.query("CREATE TABLE #test_freetds ( ... );");

      fail("Exception not thrown");
    } on FreeTDSException catch (e) {
      expect(e.message, equals("Attempting to execute last command failed."));
    }

    if (FreeTDS.library != null) {
      testUtils.expectLibraryError("SQL Anywhere Error -131: Syntax error near '.' on line 1 ", 15);
    }

    await FreeTDS.disconnect();
    if (FreeTDS.library != null) {
      testUtils.expectNoLibraryError();
    }
  });

  test("Test SQL INSERT", () async {
    await FreeTDS.connect(
      host: testUtils.host,
      username: testUtils.username,
      password: testUtils.password,
      database: testUtils.database,
      encryption: testUtils.encryption, //
    );

    // Create a table
    await FreeTDS.query("""
      CREATE TABLE #test_freetds
      (
        id            INTEGER DEFAULT AUTOINCREMENT PRIMARY KEY,
        name          VARCHAR(255),
        email         VARCHAR(255),
        creationTime  DATETIME DEFAULT CURRENT_TIMESTAMP,
      );
    """);

    // Insert some data
    var insertResult = await FreeTDS.query("INSERT INTO #test_freetds (name, email) VALUES (?, ?);", [QueryParam("Bob"), QueryParam("bob@bob.com")]);
    expect(insertResult.length, equals(1));
    expect(insertResult.last.data.length, equals(0));
    expect(insertResult.last.affectedRows, equals(1));

    var result = await FreeTDS.query("SELECT @@IDENTITY");
    expect(result.length, equals(1));
    expect(result.last.data.length, equals(1));
    expect(result.last.data[0].values.length, equals(1));
    expect(result.last.affectedRows, equals(-1));

    var insertId = result.last.data[0].values.first;

    expect(insertId, equals(1));
    if (FreeTDS.library != null) {
      testUtils.expectNoLibraryError();
    }

    // Drop the test table
    await FreeTDS.query("DROP TABLE #test_freetds");
    if (FreeTDS.library != null) {
      testUtils.expectNoLibraryError();
    }

    // Finally, close the connection
    await FreeTDS.disconnect();
    if (FreeTDS.library != null) {
      testUtils.expectNoLibraryError();
    }
  });

  test("Test SQL INSERT & SELECT", () async {
    await FreeTDS.connect(
      host: testUtils.host,
      username: testUtils.username,
      password: testUtils.password,
      database: testUtils.database,
      encryption: testUtils.encryption, //
    );

    // Create a table
    await FreeTDS.query("""
      CREATE TABLE #test_freetds
      (
        id            INTEGER DEFAULT AUTOINCREMENT PRIMARY KEY,
        name          VARCHAR(255),
        email         VARCHAR(255),
        creationTime  DATETIME DEFAULT CURRENT_TIMESTAMP,
      );
    """);

    // Insert some data
    var insertResult = await FreeTDS.query("INSERT INTO #test_freetds (name, email, creationTime) VALUES (?, ?, ?);", [
      QueryParam("Bob"),
      QueryParam("bob@bob.com"),
      QueryParam("2000-01-01 23:59:59+0000"),
    ]);
    expect(insertResult.length, equals(1));
    expect(insertResult.last.data.length, equals(0));
    expect(insertResult.last.affectedRows, equals(1));

    var result = await FreeTDS.query("SELECT @@IDENTITY");
    expect(result.length, equals(1));
    expect(result.last.data.length, equals(1));
    expect(result.last.data[0].values.length, equals(1));
    expect(result.last.affectedRows, equals(-1));

    var insertId = result.last.data[0].values.first;

    expect(insertId, equals(1));

    // Query the database using a parameterized query
    var results = await FreeTDS.query("SELECT * FROM #test_freetds WHERE id = ?", [QueryParam(insertId)]);
    expect(results.length, equals(1));
    expect(results.last.data.length, equals(1));
    expect(results.last.data[0].values.length, equals(4));
    expect(results.last.affectedRows, equals(-1));

    expect(results.last.data[0]["id"], equals(1));
    expect(results.last.data[0]["name"], equals("Bob"));
    expect(results.last.data[0]["email"], equals("bob@bob.com"));
    expect(results.last.data[0]["creationTime"], equals(LocalDateTime.parse("2000-01-01T23:59:59")));
    if (FreeTDS.library != null) {
      testUtils.expectNoLibraryError();
    }

    // Drop the test table
    await FreeTDS.query("DROP TABLE #test_freetds");
    if (FreeTDS.library != null) {
      testUtils.expectNoLibraryError();
    }

    // Finally, close the connection
    await FreeTDS.disconnect();
    if (FreeTDS.library != null) {
      testUtils.expectNoLibraryError();
    }
  });

  test("Test SQL CREATE, INSERT, SELECT & UPDATE", () async {
    await FreeTDS.connect(
      host: testUtils.host,
      username: testUtils.username,
      password: testUtils.password,
      database: testUtils.database,
      encryption: testUtils.encryption, //
    );

    // Create a table
    await FreeTDS.query("""
      CREATE TABLE #test_freetds
      (
        id            INTEGER DEFAULT AUTOINCREMENT PRIMARY KEY,
        name          VARCHAR(255),
        email         VARCHAR(255),
        creationTime  DATETIME DEFAULT CURRENT_TIMESTAMP,
      );
    """);

    var creationStartDateResult = await FreeTDS.query("SELECT GETDATE()");
    expect(creationStartDateResult.length, equals(1));
    expect(creationStartDateResult.last.data.length, equals(1));
    expect(creationStartDateResult.last.data[0].values.length, equals(1));
    expect(creationStartDateResult.last.affectedRows, equals(-1));

    var creationStartDate = creationStartDateResult.last.data[0].values.first as LocalDateTime;

    sleep(Duration(milliseconds: 50));

    // Insert some data
    var insertResult = await FreeTDS.query("INSERT INTO #test_freetds (name, email) VALUES (?, ?);", [QueryParam("Bob"), QueryParam("bob@bob.com")]);
    expect(insertResult.length, equals(1));
    expect(insertResult.last.data.length, equals(0));
    expect(insertResult.last.affectedRows, equals(1));

    var result = await FreeTDS.query("SELECT @@IDENTITY");
    expect(result.length, equals(1));
    expect(result.last.data.length, equals(1));
    expect(result.last.data[0].values.length, equals(1));
    expect(result.last.affectedRows, equals(-1));

    var insertId = result.last.data[0].values.first;

    expect(insertId, equals(1));

    sleep(Duration(milliseconds: 50));

    var creationEndDateResult = await FreeTDS.query("SELECT GETDATE()");
    expect(creationEndDateResult.length, equals(1));
    expect(creationEndDateResult.last.data.length, equals(1));
    expect(creationEndDateResult.last.data[0].values.length, equals(1));
    expect(creationEndDateResult.last.affectedRows, equals(-1));

    var creationEndDate = creationEndDateResult.last.data[0].values.first as LocalDateTime;

    expect(creationStartDate.timespanUntil(creationEndDate).inMilliseconds, greaterThanOrEqualTo(100));

    // Query the database using a parameterized query
    var results = await FreeTDS.query("SELECT * FROM #test_freetds WHERE id = ?", [QueryParam(insertId)]);
    expect(results.length, equals(1));
    expect(results.last.data.length, equals(1));
    expect(results.last.data[0].values.length, equals(4));
    expect(results.last.affectedRows, equals(-1));

    expect(results.last.data[0]["id"], equals(1));
    expect(results.last.data[0]["name"], equals("Bob"));
    expect(results.last.data[0]["email"], equals("bob@bob.com"));
    expect(results.last.data[0]["creationTime"], allOf(greaterThan(creationStartDate), lessThan(creationEndDate)));
    if (FreeTDS.library != null) {
      testUtils.expectNoLibraryError();
    }

    // Update some data
    var updateResult = await FreeTDS.query("UPDATE #test_freetds SET name = ? WHERE name = ?", [QueryParam("New Bob"), QueryParam("Bob")]);
    expect(updateResult.length, equals(1));
    expect(updateResult.last.data.length, equals(0));
    expect(updateResult.last.affectedRows, equals(1));

    // Query again database using a parameterized query
    var resultsAfterUpdate = await FreeTDS.query("SELECT * FROM #test_freetds WHERE id = ?", [QueryParam(insertId)]);
    expect(resultsAfterUpdate.length, equals(1));
    expect(resultsAfterUpdate.last.data.length, equals(1));
    expect(resultsAfterUpdate.last.data[0].values.length, equals(4));
    expect(resultsAfterUpdate.last.affectedRows, equals(-1));

    expect(resultsAfterUpdate.last.data[0]["id"], equals(1));
    expect(resultsAfterUpdate.last.data[0]["name"], equals("New Bob"));
    expect(resultsAfterUpdate.last.data[0]["email"], equals("bob@bob.com"));
    expect(resultsAfterUpdate.last.data[0]["creationTime"], equals(results.last.data[0]["creationTime"]));
    if (FreeTDS.library != null) {
      testUtils.expectNoLibraryError();
    }

    // Drop the test table
    await FreeTDS.query("DROP TABLE #test_freetds");
    if (FreeTDS.library != null) {
      testUtils.expectNoLibraryError();
    }

    // Finally, close the connection
    await FreeTDS.disconnect();
    if (FreeTDS.library != null) {
      testUtils.expectNoLibraryError();
    }
  });
}
