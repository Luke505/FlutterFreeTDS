import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:freetds/freetds.dart";
import "package:freetds/src/error/error_message.dart";
import "package:logger/logger.dart";

Future<void> main() async {
  const host = "192.168.1.174:2638"; // default: localhost:2638
  const username = "dba"; // default: dba
  const password = "sql"; // default: sql
  const database = "dblc"; // default: test_db

  Logger logger = Logger(level: Level.all);

  String libraryPath = (goldenFileComparator as LocalFileComparator).basedir.path + "../";

  if (Platform.isMacOS) {
    libraryPath = 'macos/FreeTDSKit.framework/FreeTDSKit';
  } else if (Platform.isIOS) {
    libraryPath = 'ios/FreeTDSKit.framework/FreeTDSKit';
  } else {
    throw UnsupportedError('FreeTDS is only supported on iOS and macOS.');
  }

  late FreeTDS freetds;

  setUp(() async {
    FreeTDS.initTest(libraryPath, logger);
    freetds = FreeTDS.instance;
  });

  tearDown(() async {
    await FreeTDS.afterTest();
  });

  test('Test connection', () async {
    // Open a connection (test_db should already exist)
    await freetds.connect(
        host: host,
        username: username,
        password: password,
        database: database
    );
    expect(FreeTDS.lastError, isNull);

    // Finally, close the connection
    await freetds.disconnect();
    expect(FreeTDS.lastError, isNull);
  });

  test('T1', () async {
    // Open a connection (test_db should already exist)
    await freetds.connect(
        host: host,
        username: username,
        password: password,
        database: database
    );
    expect(FreeTDS.lastError, isNull);

    // Create a table
    await freetds.query("""
    SELECT MAX(ven_dist_progre) FROM ven_distinta
        WHERE ven_dist_sbt_tavolo = ? AND ven_dist_orachiu IS NULL AND ven_dist_chiuoperatore IS NULL
    """, [
      QueryParam(1)
    ]);

    // Finally, close the connection
    await freetds.disconnect();
    expect(FreeTDS.lastError, isNull);
  });

  test('Test connection error', () async {
    // Open a connection (test_db should already exist)
    await expectLater(() async => await freetds.connect(
        host: "0.0.0.0",
        username: "...",
        password: "...",
        database: "..."
    ), throwsA(FreeTDSException.fromErrorMessage(ErrorMessage.connectionError)));
    expect(FreeTDS.lastError, isNotNull);
    expect(FreeTDS.lastError!.error, equals("Unable to connect: Adaptive Server is unavailable or does not exist (0.0.0.0)"));
    expect(FreeTDS.lastError!.code, equals(20018));
    expect(FreeTDS.lastError!.severity, equals(15));

    // Finally, close the connection
    await freetds.disconnect();
    expect(FreeTDS.lastError, isNull);
  });

  test('Test SQL CREATE', () async {
    // Open a connection (test_db should already exist)
    await freetds.connect(
        host: host,
        username: username,
        password: password,
        database: database
    );
    expect(FreeTDS.lastError, isNull);

    // Create a table
    var createResult = await freetds.query("""
    CREATE TABLE #test_freetds
    (
        id    INTEGER DEFAULT AUTOINCREMENT PRIMARY KEY,
        name  VARCHAR(255) NULL,
        email VARCHAR(255),
        age   INTEGER,
        balance_f FLOAT NULL,
        balance_r REAL NULL,
        balance_n NUMERIC(7,2) NULL,
        creationTime DATETIME DEFAULT CURRENT_TIMESTAMP
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

  test('Test SQL CREATE error', () async {
    // Open a connection (test_db should already exist)
    await freetds.connect(
        host: host,
        username: username,
        password: password,
        database: database
    );
    expect(FreeTDS.lastError, isNull);

    // Create a table
    try {
      await freetds.query("CREATE TABLE #test_freetds();");
    } catch (_) {}

    expect(FreeTDS.lastError, isNotNull);
  });

  test('Test SQL INSERT', () async {
    // Open a connection (test_db should already exist)
    await freetds.connect(
        host: host,
        username: username,
        password: password,
        database: database
    );

    // Create a table
    await freetds.query("""
    CREATE TABLE #test_freetds
    (
        id    INTEGER DEFAULT AUTOINCREMENT PRIMARY KEY,
        name  VARCHAR(255) NULL,
        email VARCHAR(255),
        age   INTEGER,
        balance_f FLOAT NULL,
        balance_r REAL NULL,
        balance_n NUMERIC(7,2) NULL,
        creationTime DATETIME DEFAULT CURRENT_TIMESTAMP
    );
    """);

    // Insert some data
    var insertResult = await freetds.query(
      "INSERT INTO #test_freetds (name, email, age, balance_f, balance_r, balance_n, creationTime) VALUES (?, ?, ?, ?, ?, ?, ?);",
      [
        QueryParam("Bob"),
        QueryParam("bob@bob.com"),
        QueryParam(-9223372036854775808),
        QueryParam(-100000.77),
        QueryParam(-100000.88),
        QueryParam(-10000.99),
        QueryParam("2023-01-01 23:59:59"),
      ],
    );
    expect(insertResult.length, equals(1));
    expect(insertResult.last.data.length, equals(0));
    expect(insertResult.last.affectedRows, equals(1));

    var result = await freetds.query("SELECT @@IDENTITY");
    expect(result.length, equals(1));
    expect(result.last.data.length, equals(1));
    expect(result.last.data[0].values.length, equals(1));

    var insertId = result.last.data[0].values.first;
    print("Inserted row id=$insertId");

    expect(insertId, equals(1));

    // Drop the test table
    await freetds.query("DROP TABLE #test_freetds");

    // Finally, close the connection
    await freetds.disconnect();
  });

  test('Test SQL INSERT error', () async {
    // Open a connection (test_db should already exist)
    await freetds.connect(
        host: host,
        username: username,
        password: password,
        database: database
    );

    // Create a table
    await freetds.query("""
    CREATE TABLE #test_freetds
    (
        id    INTEGER DEFAULT AUTOINCREMENT PRIMARY KEY,
        name  VARCHAR(255) NULL,
        email VARCHAR(255),
        age   INTEGER,
        balance_f FLOAT NULL,
        balance_r REAL NULL,
        balance_n NUMERIC(7,2) NULL,
        creationTime DATETIME DEFAULT CURRENT_TIMESTAMP
    );
    """);

    // Insert some data
    var insertResult = await freetds.query(
      "INSERT INTO #test_freetds (name, email, age, balance_f, balance_r, balance_n, creationTime) VALUES (?, ?, ?, ?, ?, ?, ?);",
      [
        QueryParam("Bob"),
        QueryParam("bob@bob.com"),
        QueryParam(-9223372036854775808),
        QueryParam(-100000.77),
        QueryParam(-100000.88),
        QueryParam(-10000.99),
        QueryParam("2023-01-01 23:59:59"),
      ],
    );
    expect(insertResult.length, equals(1));
    expect(insertResult.last.data.length, equals(0));
    expect(insertResult.last.affectedRows, equals(1));

    var result = await freetds.query("SELECT @@IDENTITY");
    expect(result.length, equals(1));
    expect(result.last.data.length, equals(1));
    expect(result.last.data[0].values.length, equals(1));

    var insertId = result.last.data[0].values.first;
    print("Inserted row id=$insertId");

    expect(insertId, equals(1));

    // Drop the test table
    await freetds.query("DROP TABLE #test_freetds");

    // Finally, close the connection
    await freetds.disconnect();
  });

  test('Test SQL INSERT & SELECT', () async {
    // Open a connection (test_db should already exist)
    await freetds.connect(
        host: host,
        username: username,
        password: password,
        database: database
    );

    // Create a table
    await freetds.query("""
    CREATE TABLE #test_freetds
    (
        id    INTEGER DEFAULT AUTOINCREMENT PRIMARY KEY,
        name  VARCHAR(255) NULL,
        email VARCHAR(255),
        age   INTEGER,
        balance_f FLOAT NULL,
        balance_r REAL NULL,
        balance_n NUMERIC(7,2) NULL,
        creationTime DATETIME DEFAULT CURRENT_TIMESTAMP
    );
    """);

    // Insert some data
    var insertResult = await freetds.query(
      "INSERT INTO #test_freetds (name, email, age, balance_f, balance_r, balance_n, creationTime) VALUES (?, ?, ?, ?, ?, ?, ?);",
      [
        QueryParam("Bob"),
        QueryParam("bob@bob.com"),
        QueryParam(-9223372036854775808),
        QueryParam(-100000.77),
        QueryParam(-100000.88),
        QueryParam(-10000.99),
        QueryParam("2023-01-01 23:59:59"),
      ],
    );
    expect(insertResult.length, equals(1));
    expect(insertResult.last.data.length, equals(0));
    expect(insertResult.last.affectedRows, equals(1));

    var result = await freetds.query("SELECT @@IDENTITY");
    expect(result.length, equals(1));
    expect(result.last.data.length, equals(1));
    expect(result.last.data[0].values.length, equals(1));

    var insertId = result.last.data[0].values.first;
    print("Inserted row id=$insertId");

    expect(insertId, equals(1));

    // Query the database using a parameterized query
    var results = await freetds.query("SELECT * FROM #test_freetds WHERE id = ?", [
      QueryParam(insertId)
    ]);
    expect(result.length, equals(1));
    expect(results.last.data.length, equals(1));
    expect(results.last.data[0].values.length, equals(3));
    expect(results.last.affectedRows, equals(-1));

    expect(results.last.data[0]["name"], equals("Bob"));
    expect(results.last.data[0]["email"], equals("bob@bob.com"));
    expect(results.last.data[0]["age"], equals(-25));

    // Drop the test table
    await freetds.query("DROP TABLE #test_freetds");

    // Finally, close the connection
    await freetds.disconnect();
  });

  test('Test SQL CREATE, INSERT & SELECT error', () async {
    // Open a connection (test_db should already exist)
    await freetds.connect(
        host: host,
        username: username,
        password: password,
        database: database
    );

    // Create a table
    await freetds.query("""
    CREATE TABLE #test_freetds
    (
        id    INTEGER DEFAULT AUTOINCREMENT PRIMARY KEY,
        name  VARCHAR(255) NULL,
        email VARCHAR(255),
        age   INTEGER,
        balance_f FLOAT NULL,
        balance_r REAL NULL,
        balance_n NUMERIC(7,2) NULL,
        creationTime DATETIME DEFAULT CURRENT_TIMESTAMP
    );
    """);

    // Insert some data
    var insertResult = await freetds.query(
        "INSERT INTO #test_freetds (name, email, age, balance_f, balance_r, balance_n, creationTime) VALUES (?, ?, ?, ?, ?, ?, ?);",
        [
          QueryParam("Bob"),
          QueryParam("bob@bob.com"),
          QueryParam(-9223372036854775808),
          QueryParam(-100000.77),
          QueryParam(-100000.88),
          QueryParam(-10000.99),
          QueryParam("2023-01-01 23:59:59"),
        ],
    );
    expect(insertResult.length, equals(1));
    expect(insertResult.last.data.length, equals(0));
    expect(insertResult.last.affectedRows, equals(1));

    var result = await freetds.query("SELECT @@IDENTITY");
    expect(result.length, equals(1));
    expect(result.last.data.length, equals(1));
    expect(result.last.data[0].values.length, equals(1));

    var insertId = result.last.data[0].values.first;
    print("Inserted row id=$insertId");

    expect(insertId, equals(1));

    // Query the database using a parameterized query
    var results = await freetds.query("SELECT * FROM #test_freetds WHERE id = ?", [
      QueryParam(insertId)
    ]);
    expect(result.length, equals(1));
    expect(results.last.data.length, equals(1));
    expect(results.last.data[0].values.length, equals(3));
    expect(results.last.affectedRows, equals(-1));

    expect(results.last.data[0]["name"], equals("Bob"));
    expect(results.last.data[0]["email"], equals("bob@bob.com"));
    expect(results.last.data[0]["age"], equals(-25));

    // Drop the test table
    await freetds.query("DROP TABLE #test_freetds");

    // Finally, close the connection
    await freetds.disconnect();
  });

  test('Test SQL CREATE, INSERT, SELECT & UPDATE', () async {
    // Open a connection (test_db should already exist)
    await freetds.connect(
        host: host,
        username: username,
        password: password,
        database: database
    );

    // Create a table
    await freetds.query("""
      CREATE TABLE #test_freetds
      (
          id           INTEGER DEFAULT AUTOINCREMENT PRIMARY KEY,
          name         VARCHAR(255),
          email        VARCHAR(255),
          age          INTEGER,
          balance      DECIMAL(7, 2),
          birthDate    DATE,
          birthTime    TIME,
          creationTime DATETIME,
          lastUpdate   TIMESTAMP,
          version      BIGINT
      )
    """);

    // Query the database using a parameterized query
    var rt = await freetds.query("SELECT name, email, age, balance, birthDate, birthTime, creationTime, lastUpdate, version"
        " FROM #test_freetds");
    assert(rt.last.data.length == 0);

    // Insert some data
    await freetds.query(
        "INSERT INTO #test_freetds (name, email, age, balance, birthDate, birthTime, creationTime, lastUpdate, version)"
            " VALUES (:name, :email, :age, :balance, :birthDate, :birthTime, :creationTime, :lastUpdate, :version)",
        [
          QueryParam("Bob", name: "name"),
          QueryParam("bob@bob.com", name: "email"),
          QueryParam(25, name: "age"),
          QueryParam(12345.45, name: "balance"),
          QueryParam("2023-01-01", name: "birthDate"),
          QueryParam("10:00:00", name: "birthTime"),
          QueryParam("2023-01-01 10:00:00", name: "creationTime"),
          QueryParam("2023-01-01 10:00:00", name: "lastUpdate"),
          QueryParam(9223372036854775807, name: "version"),
        ]);

    var result = await freetds.query("SELECT @@IDENTITY");
    assert(result.length == 1);
    assert(result.last.data.length == 1);
    assert(result.last.data[0].values.length == 1);

    var insertId = result.last.data[0].values.first;
    print("Inserted row id=$insertId");

    assert(insertId == 1);

    // Query the database using a parameterized query
    var results = await freetds.query("SELECT name, email, age, balance, birthDate, birthTime, creationTime, lastUpdate, version"
        " FROM #test_freetds WHERE id = ?", [
      QueryParam(insertId)
    ]);
    assert(result.length == 1);
    assert(results.last.data.length == 1);
    assert(results.last.data[0].values.length == 9);

    assert(results.last.data[0]["name"] == "Bob");
    assert(results.last.data[0]["email"] == "bob@bob.com");
    assert(results.last.data[0]["age"] == 25);
    assert(results.last.data[0]["balance"] == 12345678.12345);
    assert(results.last.data[0]["birthDate"] == "2023-01-01");
    assert(results.last.data[0]["birthTime"] == "10:00:00");
    assert(results.last.data[0]["creationTime"] == "2023-01-01 10:00:00");
    assert(results.last.data[0]["lastUpdate"] == "2023-01-01 10:00:00");
    assert(results.last.data[0]["version"] == 9223372036854775807);

    // Update some data
    await freetds.query("UPDATE #test_freetds SET age = ? WHERE name = ?", [
      QueryParam(26),
      QueryParam("Bob")
    ]);

    // Query again database using a parameterized query
    var results2 = await freetds.query("SELECT name, email, age FROM #test_freetds WHERE id = ?", [
      QueryParam(insertId)
    ]);
    for (var row in results2.last.data) {
      print("Name: ${row[0]}, email: ${row[1]} age: ${row[2]}");
    }

    // Drop the test table
    await freetds.query("DROP TABLE #test_freetds");

    // Finally, close the connection
    await freetds.disconnect();
  });

  test('Test SQL CREATE, INSERT, SELECT & UPDATE error', () async {
    // Open a connection (test_db should already exist)
    await freetds.connect(
        host: host,
        username: username,
        password: password,
        database: database
    );

    // Create a table
    await freetds.query("""
      CREATE TABLE #test_freetds
      (
          id           INTEGER DEFAULT AUTOINCREMENT PRIMARY KEY,
          name         VARCHAR(255),
          email        VARCHAR(255),
          age          INTEGER,
          balance      DECIMAL(7, 2),
          birthDate    DATE,
          birthTime    TIME,
          creationTime DATETIME,
          lastUpdate   TIMESTAMP,
          version      BIGINT
      )
    """);

    // Query the database using a parameterized query
    var rt = await freetds.query("SELECT name, email, age, balance, birthDate, birthTime, creationTime, lastUpdate, version"
        " FROM #test_freetds");
    assert(rt.last.data.length == 0);

    // Insert some data
    await freetds.query(
        "INSERT INTO #test_freetds (name, email, age, balance, birthDate, birthTime, creationTime, lastUpdate, version)"
            " VALUES (:name, :email, :age, :balance, :birthDate, :birthTime, :creationTime, :lastUpdate, :version)",
        [
          QueryParam("Bob", name: "name"),
          QueryParam("bob@bob.com", name: "email"),
          QueryParam(25, name: "age"),
          QueryParam(12345.45, name: "balance"),
          QueryParam("2023-01-01", name: "birthDate"),
          QueryParam("10:00:00", name: "birthTime"),
          QueryParam("2023-01-01 10:00:00", name: "creationTime"),
          QueryParam("2023-01-01 10:00:00", name: "lastUpdate"),
          QueryParam(9223372036854775807, name: "version"),
        ]);

    var result = await freetds.query("SELECT @@IDENTITY");
    assert(result.length == 1);
    assert(result.last.data.length == 1);
    assert(result.last.data[0].values.length == 1);

    var insertId = result.last.data[0].values.first;
    print("Inserted row id=$insertId");

    assert(insertId == 1);

    // Query the database using a parameterized query
    var results = await freetds.query("SELECT name, email, age, balance, birthDate, birthTime, creationTime, lastUpdate, version"
        " FROM #test_freetds WHERE id = ?", [
      QueryParam(insertId)
    ]);
    assert(result.length == 1);
    assert(results.last.data.length == 1);
    assert(results.last.data[0].values.length == 9);

    assert(results.last.data[0]["name"] == "Bob");
    assert(results.last.data[0]["email"] == "bob@bob.com");
    assert(results.last.data[0]["age"] == 25);
    assert(results.last.data[0]["balance"] == 12345678.12345);
    assert(results.last.data[0]["birthDate"] == "2023-01-01");
    assert(results.last.data[0]["birthTime"] == "10:00:00");
    assert(results.last.data[0]["creationTime"] == "2023-01-01 10:00:00");
    assert(results.last.data[0]["lastUpdate"] == "2023-01-01 10:00:00");
    assert(results.last.data[0]["version"] == 9223372036854775807);

    // Update some data
    await freetds.query("UPDATE #test_freetds SET age = ? WHERE name = ?", [
      QueryParam(26),
      QueryParam("Bob")
    ]);

    // Query again database using a parameterized query
    var results2 = await freetds.query("SELECT name, email, age FROM #test_freetds WHERE id = ?", [
      QueryParam(insertId)
    ]);
    for (var row in results2.last.data) {
      print("Name: ${row[0]}, email: ${row[1]} age: ${row[2]}");
    }

    // Drop the test table
    await freetds.query("DROP TABLE #test_freetds");

    // Finally, close the connection
    await freetds.disconnect();
  });
}