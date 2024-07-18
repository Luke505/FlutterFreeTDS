import 'dart:ffi';

import "package:ffi/ffi.dart";
import "package:flutter_test/flutter_test.dart";
import "package:freetds/freetds.dart";
import "package:freetds/src/library/model/model.dart";
import "package:freetds/src/utils/connection_utils.dart";
import "package:tempo/tempo.dart";
import "package:uuid/uuid.dart";

import "model/int_query_param_test_model.dart";
import 'utils/test_utils.dart';

Future<void> main() async {
  late FreeTDS freetds;
  late List<IntQueryParamTestModel> elements;

  setUp(() async {
    freetds = TestUtils.setUpTest();
    elements = [
      IntQueryParamTestModel(
        name: "SYBINT1_MIN",
        value: BigInt.parse("0"),
        datatype: SYBINT1,
        datalen: 1,
        endValue: [0x00],
        endDatatype: SYBINT1,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBINT2_MIN",
        value: BigInt.parse("-32768"),
        datatype: SYBINT2,
        datalen: 2,
        endValue: [0x00, 0x80],
        endDatatype: SYBINT2,
        dartValue: -32768,
      ),
      IntQueryParamTestModel(
        name: "SYBINT4_MIN",
        value: BigInt.parse("-2147483648"),
        datatype: SYBINT4,
        datalen: 4,
        endValue: [0x00, 0x00, 0x00, 0x80],
        endDatatype: SYBINT4,
        dartValue: -2147483648,
      ),
      IntQueryParamTestModel(
        name: "SYBINT8_MIN",
        value: BigInt.parse("-9223372036854775808"),
        datatype: SYBINT8,
        datalen: 8,
        endValue: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80],
        endDatatype: SYBINT8,
        dartValue: -9223372036854775808,
      ),
      IntQueryParamTestModel(
        name: "SYBUINT1_MIN",
        value: BigInt.parse("0"),
        datatype: SYBINT1,
        datalen: 1,
        endValue: [0x00],
        endDatatype: SYBINT1,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBUINT2_MIN",
        value: BigInt.parse("0"),
        datatype: SYBUINT2,
        datalen: 2,
        endValue: [0x00, 0x00],
        endDatatype: SYBUINT2,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBUINT4_MIN",
        value: BigInt.parse("0"),
        datatype: SYBUINT4,
        datalen: 4,
        endValue: [0x00, 0x00, 0x00, 0x00],
        endDatatype: SYBUINT4,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBUINT8_MIN",
        value: BigInt.parse("0"),
        datatype: SYBUINT8,
        datalen: 8,
        endValue: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
        endDatatype: SYBUINT8,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBINT1_N_MIN",
        value: BigInt.parse("0"),
        datatype: SYBINTN,
        datalen: 1,
        endValue: [0x00],
        endDatatype: SYBINT1,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBINT2_N_MIN",
        value: BigInt.parse("-32768"),
        datatype: SYBINTN,
        datalen: 2,
        endValue: [0x00, 0x80],
        endDatatype: SYBINT2,
        dartValue: -32768,
      ),
      IntQueryParamTestModel(
        name: "SYBINT4_N_MIN",
        value: BigInt.parse("-2147483648"),
        datatype: SYBINTN,
        datalen: 4,
        endValue: [0x00, 0x00, 0x00, 0x80],
        endDatatype: SYBINT4,
        dartValue: -2147483648,
      ),
      IntQueryParamTestModel(
        name: "SYBINT8_N_MIN",
        value: BigInt.parse("-9223372036854775808"),
        datatype: SYBINTN,
        datalen: 8,
        endValue: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80],
        endDatatype: SYBINT8,
        dartValue: -9223372036854775808,
      ),
      IntQueryParamTestModel(
        name: "SYBUINT1_N_MIN",
        value: BigInt.parse("0"),
        datatype: SYBUINTN,
        datalen: 1,
        endValue: [0x00],
        endDatatype: SYBINT1,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBUINT2_N_MIN",
        value: BigInt.parse("0"),
        datatype: SYBUINTN,
        datalen: 1,
        endValue: [0x00],
        endDatatype: SYBINT1,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBUINT4_N_MIN",
        value: BigInt.parse("0"),
        datatype: SYBUINTN,
        datalen: 1,
        endValue: [0x00],
        endDatatype: SYBINT1,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBUINT8_N_MIN",
        value: BigInt.parse("0"),
        datatype: SYBUINTN,
        datalen: 1,
        endValue: [0x00],
        endDatatype: SYBINT1,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBINT1_0",
        value: BigInt.parse("0"),
        datatype: SYBINT1,
        datalen: 1,
        endValue: [0x00],
        endDatatype: SYBINT1,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBINT2_0",
        value: BigInt.parse("0"),
        datatype: SYBINT2,
        datalen: 2,
        endValue: [0x00, 0x00],
        endDatatype: SYBINT2,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBINT4_0",
        value: BigInt.parse("0"),
        datatype: SYBINT4,
        datalen: 4,
        endValue: [0x00, 0x00, 0x00, 0x00],
        endDatatype: SYBINT4,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBINT8_0",
        value: BigInt.parse("0"),
        datatype: SYBINT8,
        datalen: 8,
        endValue: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
        endDatatype: SYBINT8,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBUINT1_0",
        value: BigInt.parse("0"),
        datatype: SYBINT1,
        datalen: 1,
        endValue: [0x00],
        endDatatype: SYBINT1,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBUINT2_0",
        value: BigInt.parse("0"),
        datatype: SYBUINT2,
        datalen: 2,
        endValue: [0x00, 0x00],
        endDatatype: SYBUINT2,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBUINT4_0",
        value: BigInt.parse("0"),
        datatype: SYBUINT4,
        datalen: 4,
        endValue: [0x00, 0x00, 0x00, 0x00],
        endDatatype: SYBUINT4,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBUINT8_0",
        value: BigInt.parse("0"),
        datatype: SYBUINT8,
        datalen: 8,
        endValue: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
        endDatatype: SYBUINT8,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBINT1_N_0",
        value: BigInt.parse("0"),
        datatype: SYBINTN,
        datalen: 1,
        endValue: [0x00],
        endDatatype: SYBINT1,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBINT2_N_0",
        value: BigInt.parse("0"),
        datatype: SYBINTN,
        datalen: 1,
        endValue: [0x00],
        endDatatype: SYBINT1,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBINT4_N_0",
        value: BigInt.parse("0"),
        datatype: SYBINTN,
        datalen: 1,
        endValue: [0x00],
        endDatatype: SYBINT1,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBINT8_N_0",
        value: BigInt.parse("0"),
        datatype: SYBINTN,
        datalen: 1,
        endValue: [0x00],
        endDatatype: SYBINT1,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBUINT1_N_0",
        value: BigInt.parse("0"),
        datatype: SYBUINTN,
        datalen: 1,
        endValue: [0x00],
        endDatatype: SYBINT1,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBUINT2_N_0",
        value: BigInt.parse("0"),
        datatype: SYBUINTN,
        datalen: 1,
        endValue: [0x00],
        endDatatype: SYBINT1,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBUINT4_N_0",
        value: BigInt.parse("0"),
        datatype: SYBUINTN,
        datalen: 1,
        endValue: [0x00],
        endDatatype: SYBINT1,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBUINT8_N_0",
        value: BigInt.parse("0"),
        datatype: SYBUINTN,
        datalen: 1,
        endValue: [0x00],
        endDatatype: SYBINT1,
        dartValue: 0,
      ),
      IntQueryParamTestModel(
        name: "SYBINT1_MAX",
        value: BigInt.parse("255"),
        datatype: SYBINT1,
        datalen: 1,
        endValue: [0xFF],
        endDatatype: SYBINT1,
        dartValue: 255,
      ),
      IntQueryParamTestModel(
        name: "SYBINT2_MAX",
        value: BigInt.parse("32767"),
        datatype: SYBINT2,
        datalen: 2,
        endValue: [0xFF, 0x7F],
        endDatatype: SYBINT2,
        dartValue: 32767,
      ),
      IntQueryParamTestModel(
        name: "SYBINT4_MAX",
        value: BigInt.parse("2147483647"),
        datatype: SYBINT4,
        datalen: 4,
        endValue: [0xFF, 0xFF, 0xFF, 0x7F],
        endDatatype: SYBINT4,
        dartValue: 2147483647,
      ),
      IntQueryParamTestModel(
        name: "SYBINT8_MAX",
        value: BigInt.parse("9223372036854775807"),
        datatype: SYBINT8,
        datalen: 8,
        endValue: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F],
        endDatatype: SYBINT8,
        dartValue: 9223372036854775807,
      ),
      IntQueryParamTestModel(
        name: "SYBUINT1_MAX",
        value: BigInt.parse("255"),
        datatype: SYBINT1,
        datalen: 1,
        endValue: [0xFF],
        endDatatype: SYBINT1,
        dartValue: 255,
      ),
      IntQueryParamTestModel(
        name: "SYBUINT2_MAX",
        value: BigInt.parse("65535"),
        datatype: SYBUINT2,
        datalen: 2,
        endValue: [0xFF, 0xFF],
        endDatatype: SYBUINT2,
        dartValue: 65535,
      ),
      IntQueryParamTestModel(
        name: "SYBUINT4_MAX",
        value: BigInt.parse("4294967295"),
        datatype: SYBUINT4,
        datalen: 4,
        endValue: [0xFF, 0xFF, 0xFF, 0xFF],
        endDatatype: SYBUINT4,
        dartValue: 4294967295,
      ),
      IntQueryParamTestModel(
        name: "SYBUINT8_MAX",
        value: BigInt.parse("18446744073709551615"),
        datatype: SYBUINT8,
        datalen: 8,
        endValue: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF],
        endDatatype: SYBUINT8,
        dartValue: -1,
      ),
      IntQueryParamTestModel(
        name: "SYBINT1_N_MAX",
        value: BigInt.parse("255"),
        datatype: SYBINTN,
        datalen: 2,
        endValue: [0xFF, 0x00],
        endDatatype: SYBINT2,
        dartValue: 255,
      ),
      IntQueryParamTestModel(
        name: "SYBINT2_N_MAX",
        value: BigInt.parse("32767"),
        datatype: SYBINTN,
        datalen: 2,
        endValue: [0xFF, 0x7F],
        endDatatype: SYBINT2,
        dartValue: 32767,
      ),
      IntQueryParamTestModel(
        name: "SYBINT4_N_MAX",
        value: BigInt.parse("2147483647"),
        datatype: SYBINTN,
        datalen: 4,
        endValue: [0xFF, 0xFF, 0xFF, 0x7F],
        endDatatype: SYBINT4,
        dartValue: 2147483647,
      ),
      IntQueryParamTestModel(
        name: "SYBINT8_N_MAX",
        value: BigInt.parse("9223372036854775807"),
        datatype: SYBINTN,
        datalen: 8,
        endValue: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F],
        endDatatype: SYBINT8,
        dartValue: 9223372036854775807,
      ),
      IntQueryParamTestModel(
        name: "SYBUINT1_N_MAX",
        value: BigInt.parse("255"),
        datatype: SYBUINTN,
        datalen: 1,
        endValue: [0xFF],
        endDatatype: SYBINT1,
        dartValue: 255,
      ),
      IntQueryParamTestModel(
        name: "SYBUINT2_N_MAX",
        value: BigInt.parse("65535"),
        datatype: SYBUINTN,
        datalen: 2,
        endValue: [0xFF, 0xFF],
        endDatatype: SYBUINT2,
        dartValue: 65535,
      ),
      IntQueryParamTestModel(
        name: "SYBUINT4_N_MAX",
        value: BigInt.parse("4294967295"),
        datatype: SYBUINTN,
        datalen: 4,
        endValue: [0xFF, 0xFF, 0xFF, 0xFF],
        endDatatype: SYBUINT4,
        dartValue: 4294967295,
      ),
      IntQueryParamTestModel(
        name: "SYBUINT8_N_MAX",
        value: BigInt.parse("18446744073709551615"),
        datatype: SYBUINTN,
        datalen: 8,
        endValue: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF],
        endDatatype: SYBUINT8,
        dartValue: -1,
      ),
    ];
  });

  tearDown(() async {
    await FreeTDS.afterTest();
  });

  test('Test BigInt QueryParam', () async {
    // Open a connection (test_db should already exist)
    await freetds.connect(
      host: TestUtils.host,
      username: TestUtils.username,
      password: TestUtils.password,
      database: TestUtils.database,
      encryption: TestUtils.encryption,
    );

    for (int i = 0; i < elements.length; i++) {
      var element = elements[i];
      QueryParam v = QueryParam(element.value, datatype: element.datatype);
      expect(v.name, isNull, reason: "Invalid name for element: ${element.name}");
      expect(v.output, 0, reason: "Invalid output for element: ${element.name}");
      expect(v.datatype, element.endDatatype,
          reason: "Invalid datatype for element: ${element.name}"
              " (Expected: ${Connection.getColumnTypeName(element.endDatatype)}, Actual: ${Connection.getColumnTypeName(v.datatype)})");
      expect(v.maxlen, 0, reason: "Invalid maxlen for element: ${element.name}");
      expect(v.scale, null, reason: "Invalid scale for element: ${element.name}");
      expect(v.precision, null, reason: "Invalid precision for element: ${element.name}");
      expect(v.datalen, element.datalen, reason: "Invalid datalen for element: ${element.name}");
      expect(v.getValue(freetds.library, freetds.connection)!.asTypedList(v.datalen), element.endValue, reason: "Invalid value for element: ${element.name}");
    }
  });

  test('Test BigInt QueryParam getData', () async {
    // Open a connection (test_db should already exist)
    await freetds.connect(
      host: TestUtils.host,
      username: TestUtils.username,
      password: TestUtils.password,
      database: TestUtils.database,
      encryption: TestUtils.encryption,
    );

    for (int i = 0; i < elements.length; i++) {
      var element = elements[i] as dynamic;
      var column = calloc<SQL_COLUMN>();
      column.ref.name = (element.name as String).toNativeUtf8();
      column.ref.type = element.endDatatype;
      column.ref.size = element.datalen;
      column.ref.status = calloc<Int32>()..value = 1;

      List<int> data = element.endValue;
      column.ref.data = malloc<Uint8>(data.length);
      column.ref.data.asTypedList(data.length).setAll(0, data);

      var v = Connection.getData(freetds.library, freetds.connection, column, i + 1);
      expect(v.runtimeType, int, reason: "Invalid value type for element: ${element.name}");
      expect(v, element.dartValue as int, reason: "Invalid value for element: ${element.name}");
    }
  });

  test('Test SQL INSERT & SELECT Text', () async {
    await freetds.connect(
      host: TestUtils.host,
      username: TestUtils.username,
      password: TestUtils.password,
      database: TestUtils.database,
      encryption: TestUtils.encryption,
    );

    // Create a table
    await freetds.query("""
    CREATE TABLE #text_test_freetds
    (
      SYBCHAR char(255),
      SYBVARCHAR varchar(255),
      SYBTEXT text,
      SYBLONGCHAR varchar(1024),
    );
    """);

    const String longText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
        'Vestibulum consequat, orci ac laoreet cursus, dolor sem luctus lorem, eget '
        'congue justo nunc quis massa. Nam velit ligula, bibendum a pulvinar id, '
        'aliquam in urna. Donec ultricies lobortis eros, nec auctor dolor semper a. '
        'Vivamus euismod ullamcorper neque. Suspendisse potenti. Class aptent taciti '
        'sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. '
        'Curabitur a scelerisque ligula. Nullam ornare, justo a interdum fermentum, '
        'massa lorem ultrices felis, at lobortis enim diam eget ipsum. Integer nec '
        'tortor eu pede pretium vulputate.';

    // Insert some data
    var insertResult = await freetds.query(
      "INSERT INTO #text_test_freetds (SYBCHAR, SYBVARCHAR, SYBTEXT, SYBLONGCHAR)"
      " VALUES (:SYBCHAR, :SYBVARCHAR, :SYBTEXT, :SYBLONGCHAR)",
      [
        QueryParam(name: "SYBCHAR", "test of a character field"),
        QueryParam(name: "SYBVARCHAR", "test of a character field"),
        QueryParam(name: "SYBTEXT", "test of a character field"),
        QueryParam(name: "SYBLONGCHAR", longText, datatype: SYBLONGCHAR),
      ],
    );
    expect(insertResult.length, equals(1));
    expect(insertResult.last.data.length, equals(0));
    expect(insertResult.last.affectedRows, equals(1));

    // Query the database using a parameterized query
    var results = await freetds.query("SELECT * FROM #text_test_freetds");
    expect(results.length, equals(1));
    expect(results.last.data.length, equals(1));
    expect(results.last.data[0].values.length, equals(4));
    expect(results.last.affectedRows, equals(-1));

    expect(results.last.data[0]["SYBCHAR"], equals("test of a character field"));
    expect(results.last.data[0]["SYBVARCHAR"], equals("test of a character field"));
    expect(results.last.data[0]["SYBTEXT"], equals("test of a character field"));
    expect(results.last.data[0]["SYBLONGCHAR"], equals(longText));
    expect(FreeTDS.lastError, isNull);

    // Drop the test table
    await freetds.query("DROP TABLE #text_test_freetds");
    expect(FreeTDS.lastError, isNull);

    // Finally, close the connection
    await freetds.disconnect();
    expect(FreeTDS.lastError, isNull);
  });

  test('Test SQL INSERT & SELECT Date & Time', () async {
    await freetds.connect(
      host: TestUtils.host,
      username: TestUtils.username,
      password: TestUtils.password,
      database: TestUtils.database,
      encryption: TestUtils.encryption,
    );

    // Create a table
    await freetds.query("""
    CREATE TABLE #date_test_freetds
    (
      SYBMSDATETIMEOFFSET datetimeoffset NULL,
      SYBDATETIME datetime NULL,
      SYBDATETIME4 smalldatetime NULL,
      SYBDATE date NULL,
      SYBTIME time NULL
    );
    """);

    // Insert some data
    var insertResult = await freetds.query(
      "INSERT INTO #date_test_freetds (SYBMSDATETIMEOFFSET, SYBDATETIME, SYBDATETIME4, SYBDATE, SYBTIME)"
      " VALUES (:SYBMSDATETIMEOFFSET, :SYBDATETIME, :SYBDATETIME4, :SYBDATE, :SYBTIME)",
      [
        QueryParam(name: "SYBMSDATETIMEOFFSET", OffsetDateTime(ZoneOffset.fromDuration(Duration(hours: -5)), 2024, 1, 2, 16, 35, 5, 123456789)),
        QueryParam(name: "SYBDATETIME", LocalDateTime.parse("2024-01-02T16:35:05.123456789")),
        QueryParam(name: "SYBDATETIME4", LocalDateTime.parse("2024-01-02T16:35:05.123456789")),
        QueryParam(name: "SYBDATE", LocalDate.parse("2024-01-02")),
        QueryParam(name: "SYBTIME", LocalTime.parse("16:35:05.123456789")),
      ],
    );
    expect(insertResult.length, equals(1));
    expect(insertResult.last.data.length, equals(0));
    expect(insertResult.last.affectedRows, equals(1));

    // Query the database using a parameterized query
    var results = await freetds.query("SELECT * FROM #date_test_freetds");
    expect(results.length, equals(1));
    expect(results.last.data.length, equals(1));
    expect(results.last.data[0].values.length, equals(5));
    expect(results.last.affectedRows, equals(-1));

    expect(results.last.data[0]["SYBMSDATETIMEOFFSET"], equals("2024-01-02 16:35:05.123-05:00"));
    expect(results.last.data[0]["SYBDATETIME"], equals(LocalDateTime.parse("2024-01-02T16:35:05.123456")));
    expect(results.last.data[0]["SYBDATETIME4"], equals(LocalDateTime.parse("2024-01-02T16:35:00")));
    expect(results.last.data[0]["SYBDATE"], equals(LocalDate.parse("2024-01-02")));
    expect(results.last.data[0]["SYBTIME"], equals(LocalTime.parse("16:35:05.123456")));
    expect(FreeTDS.lastError, isNull);

    // Drop the test table
    await freetds.query("DROP TABLE #date_test_freetds");
    expect(FreeTDS.lastError, isNull);

    // Finally, close the connection
    await freetds.disconnect();
    expect(FreeTDS.lastError, isNull);
  });

  test('Test SQL INSERT & SELECT Binary', () async {
    await freetds.connect(
      host: TestUtils.host,
      username: TestUtils.username,
      password: TestUtils.password,
      database: TestUtils.database,
      encryption: TestUtils.encryption,
    );

    // Create a table
    await freetds.query("""
    CREATE TABLE #binary_test_freetds
    (
      SYBBIT_0 bit,
      SYBBIT_1 bit,
      SYBBINARY_TIMESTAMP timestamp,
    );
    """);

    // Insert some data
    var insertResult = await freetds.query(
      "INSERT INTO #binary_test_freetds (SYBBIT_0, SYBBIT_1, SYBBINARY_TIMESTAMP)"
      " VALUES (:SYBBIT_0, :SYBBIT_1, :SYBBINARY_TIMESTAMP)",
      [
        QueryParam(name: "SYBBIT_0", false, datatype: SYBBIT),
        QueryParam(name: "SYBBIT_1", true, datatype: SYBBIT),
        QueryParam(name: "SYBBINARY_TIMESTAMP", "2000-01-01 23:59:59"),
      ],
    );
    expect(insertResult.length, equals(1));
    expect(insertResult.last.data.length, equals(0));
    expect(insertResult.last.affectedRows, equals(1));

    // Query the database using a parameterized query
    var results = await freetds.query("SELECT * FROM #binary_test_freetds");
    expect(results.length, equals(1));
    expect(results.last.data.length, equals(1));
    expect(results.last.data[0].values.length, equals(3));
    expect(results.last.affectedRows, equals(-1));

    expect(results.last.data[0]["SYBBIT_0"], equals(false));
    expect(results.last.data[0]["SYBBIT_1"], equals(true));
    expect(results.last.data[0]["SYBBINARY_TIMESTAMP"], equals(LocalDateTime.parse("2000-01-01T23:59:59")));
    expect(FreeTDS.lastError, isNull);

    // Drop the test table
    await freetds.query("DROP TABLE #binary_test_freetds");
    expect(FreeTDS.lastError, isNull);

    // Finally, close the connection
    await freetds.disconnect();
    expect(FreeTDS.lastError, isNull);
  });

  test('Test SQL INSERT & SELECT Number', () async {
    await freetds.connect(
      host: TestUtils.host,
      username: TestUtils.username,
      password: TestUtils.password,
      database: TestUtils.database,
      encryption: TestUtils.encryption,
    );

    // Create a table
    await freetds.query("""
    CREATE TABLE #number_test_freetds
    (
        SYBINT1 tinyint,
        SYBINT2 smallint,
        SYBINT4 int,
        SYBUINT1 unsigned tinyint,
        SYBUINT2 unsigned smallint,
        SYBUINT4 unsigned int,
        SYBINT1_N tinyint,
        SYBINT2_N smallint,
        SYBINT4_N int,
        SYBUINT1_N unsigned tinyint,
        SYBUINT2_N unsigned smallint,
        SYBUINT4_N unsigned int,
        SYBINT8 bigint,
        SYBUINT8 unsigned bigint,
        SYBINT8_N bigint,
        SYBUINT8_N unsigned bigint,
        SYBFLT8_FLOAT4 float(9),
        SYBFLT8_FLOAT8 float(30),
        SYBFLT8_DOUBLE double,
        SYBREAL real,
        SYBMONEY money,
        SYBMONEY4 smallmoney,
        SYBNUMERIC numeric(8,2),
        SYBNUMERIC15 numeric(15,9),
        SYBDECIMAL decimal(8,2),
        SYBDECIMAL15 decimal(15,9),
    );
    """);

    // Insert some data
    var insertResult = await freetds.query(
      "INSERT INTO #number_test_freetds (SYBINT1, SYBINT2, SYBINT4, SYBUINT1, SYBUINT2, SYBUINT4, SYBINT1_N, SYBINT2_N, SYBINT4_N, SYBUINT1_N,"
      " SYBUINT2_N, SYBUINT4_N, SYBINT8, SYBUINT8, SYBINT8_N, SYBUINT8_N, SYBFLT8_FLOAT4, SYBFLT8_FLOAT8, SYBFLT8_DOUBLE, SYBREAL, SYBMONEY, SYBMONEY4,"
      " SYBNUMERIC, SYBNUMERIC15, SYBDECIMAL, SYBDECIMAL15)"
      " VALUES (:SYBINT1, :SYBINT2, :SYBINT4, :SYBUINT1, :SYBUINT2, :SYBUINT4, :SYBINT1_N, :SYBINT2_N, :SYBINT4_N, :SYBUINT1_N,"
      " :SYBUINT2_N, :SYBUINT4_N, :SYBINT8, :SYBUINT8, :SYBINT8_N, :SYBUINT8_N, :SYBFLT8_FLOAT4, :SYBFLT8_FLOAT8, :SYBFLT8_DOUBLE, :SYBREAL, :SYBMONEY,"
      " :SYBMONEY4, :SYBNUMERIC, :SYBNUMERIC15, :SYBDECIMAL, :SYBDECIMAL15)",
      [
        QueryParam(name: "SYBINT1", 255, datatype: SYBINT1),
        QueryParam(name: "SYBINT2", 255, datatype: SYBINT2),
        QueryParam(name: "SYBINT4", 255, datatype: SYBINT4),
        QueryParam(name: "SYBUINT1", 255, datatype: SYBINT1),
        QueryParam(name: "SYBUINT2", 255, datatype: SYBUINT2),
        QueryParam(name: "SYBUINT4", 255, datatype: SYBUINT4),
        QueryParam(name: "SYBINT1_N", 255, datatype: SYBINTN),
        QueryParam(name: "SYBINT2_N", 255, datatype: SYBINTN),
        QueryParam(name: "SYBINT4_N", 255, datatype: SYBINTN),
        QueryParam(name: "SYBUINT1_N", 255, datatype: SYBUINTN),
        QueryParam(name: "SYBUINT2_N", 255, datatype: SYBUINTN),
        QueryParam(name: "SYBUINT4_N", 255, datatype: SYBUINTN),
        QueryParam(name: "SYBINT8", 374632567765, datatype: SYBINT8),
        QueryParam(name: "SYBUINT8", 374632567765, datatype: SYBUINT8),
        QueryParam(name: "SYBINT8_N", 374632567765, datatype: SYBINTN),
        QueryParam(name: "SYBUINT8_N", 374632567765, datatype: SYBUINTN),
        QueryParam(name: "SYBFLT8_FLOAT4", 1.3, precision: 4, scale: 2, datatype: SYBFLT8),
        QueryParam(name: "SYBFLT8_FLOAT8", 1237.45, precision: 8, scale: 2, datatype: SYBFLT8),
        QueryParam(name: "SYBFLT8_DOUBLE", 1237.45, precision: 8, scale: 2, datatype: SYBFLT8),
        QueryParam(name: "SYBREAL", 1237.45, precision: 8, scale: 2, datatype: SYBREAL),
        QueryParam(name: "SYBMONEY", 1237.45, precision: 8, scale: 2, datatype: SYBMONEY),
        QueryParam(name: "SYBMONEY4", 1237.45, precision: 8, scale: 2, datatype: SYBMONEY4),
        QueryParam(name: "SYBNUMERIC", 947919.25, precision: 8, scale: 2, datatype: SYBNUMERIC),
        QueryParam(name: "SYBNUMERIC15", 567765.374632567, precision: 15, scale: 9, datatype: SYBNUMERIC),
        QueryParam(name: "SYBDECIMAL", 947919.25, precision: 8, scale: 2, datatype: SYBDECIMAL),
        QueryParam(name: "SYBDECIMAL15", 567765.374632567, precision: 15, scale: 9, datatype: SYBDECIMAL),
      ],
    );
    expect(insertResult.length, equals(1));
    expect(insertResult.last.data.length, equals(0));
    expect(insertResult.last.affectedRows, equals(1));

    // Query the database using a parameterized query
    var results = await freetds.query("SELECT * FROM #number_test_freetds");
    expect(results.length, equals(1));
    expect(results.last.data.length, equals(1));
    expect(results.last.data[0].values.length, equals(26));
    expect(results.last.affectedRows, equals(-1));

    expect(results.last.data[0]["SYBINT1"], equals(255));
    expect(results.last.data[0]["SYBINT2"], equals(255));
    expect(results.last.data[0]["SYBINT4"], equals(255));
    expect(results.last.data[0]["SYBUINT1"], equals(255));
    expect(results.last.data[0]["SYBUINT2"], equals(255));
    expect(results.last.data[0]["SYBUINT4"], equals(255));
    expect(results.last.data[0]["SYBINT1_N"], equals(255));
    expect(results.last.data[0]["SYBINT2_N"], equals(255));
    expect(results.last.data[0]["SYBINT4_N"], equals(255));
    expect(results.last.data[0]["SYBUINT1_N"], equals(255));
    expect(results.last.data[0]["SYBUINT2_N"], equals(255));
    expect(results.last.data[0]["SYBUINT4_N"], equals(255));
    expect(results.last.data[0]["SYBINT8"], equals(374632567765));
    expect(results.last.data[0]["SYBUINT8"], equals(374632567765));
    expect(results.last.data[0]["SYBINT8_N"], equals(374632567765));
    expect(results.last.data[0]["SYBUINT8_N"], equals(374632567765));
    expect(results.last.data[0]["SYBFLT8_FLOAT4"], equals(1.3));
    expect(results.last.data[0]["SYBFLT8_FLOAT8"], equals(1237.45));
    expect(results.last.data[0]["SYBFLT8_DOUBLE"], equals(1237.45));
    expect(results.last.data[0]["SYBREAL"], equals(1237.45));
    expect(results.last.data[0]["SYBMONEY"], equals(1237.45));
    expect(results.last.data[0]["SYBMONEY4"], equals(1237.45));
    expect(results.last.data[0]["SYBNUMERIC"], equals(947919.25));
    expect(results.last.data[0]["SYBNUMERIC15"], equals(567765.374632567));
    expect(results.last.data[0]["SYBDECIMAL"], equals(947919.25));
    expect(results.last.data[0]["SYBDECIMAL15"], equals(567765.374632567));
    expect(FreeTDS.lastError, isNull);

    // Drop the test table
    await freetds.query("DROP TABLE #number_test_freetds");
    expect(FreeTDS.lastError, isNull);

    // Finally, close the connection
    await freetds.disconnect();
    expect(FreeTDS.lastError, isNull);
  });

  test('Test SQL INSERT & SELECT Number - Precision overflow', () async {
    await freetds.connect(
      host: TestUtils.host,
      username: TestUtils.username,
      password: TestUtils.password,
      database: TestUtils.database,
      encryption: TestUtils.encryption,
    );

    // Create a table
    await freetds.query("""
    CREATE TABLE #number_overflow_test_freetds
    (
        id INTEGER DEFAULT AUTOINCREMENT PRIMARY KEY,
        SYBFLT8_FLOAT4 float(9),
        SYBFLT8_FLOAT8 float(30),
        SYBFLT8_DOUBLE double,
        SYBREAL real,
        SYBMONEY money,
        SYBMONEY4 smallmoney,
        SYBNUMERIC numeric(8,2),
        SYBNUMERIC15 numeric(15,9),
        SYBDECIMAL decimal(8,2),
        SYBDECIMAL15 decimal(15,9),
    );
    """);

    // Insert some data
    var insertResult = await freetds.query(
      "INSERT INTO #number_overflow_test_freetds (SYBFLT8_FLOAT4, SYBFLT8_FLOAT8, SYBFLT8_DOUBLE, SYBREAL, SYBMONEY, SYBMONEY4, SYBNUMERIC, SYBNUMERIC15, SYBDECIMAL, SYBDECIMAL15)"
      " VALUES (:SYBFLT8_FLOAT4, :SYBFLT8_FLOAT8, :SYBFLT8_DOUBLE, :SYBREAL, :SYBMONEY, :SYBMONEY4, :SYBNUMERIC, :SYBNUMERIC15, :SYBDECIMAL, :SYBDECIMAL15)",
      [
        QueryParam(name: "SYBFLT8_FLOAT4", 1.3, precision: 4, scale: 2, datatype: SYBFLT8),
        QueryParam(name: "SYBFLT8_FLOAT8", 1237.45, precision: 8, scale: 2, datatype: SYBFLT8),
        QueryParam(name: "SYBFLT8_DOUBLE", 1237.45, precision: 8, scale: 2, datatype: SYBFLT8),
        QueryParam(name: "SYBREAL", 1237.45, precision: 8, scale: 2, datatype: SYBREAL),
        QueryParam(name: "SYBMONEY", 1237.45, precision: 8, scale: 2, datatype: SYBMONEY),
        QueryParam(name: "SYBMONEY4", 1237.45, precision: 8, scale: 2, datatype: SYBMONEY4),
        QueryParam(name: "SYBNUMERIC", 947919.259, precision: 8, scale: 2, datatype: SYBNUMERIC),
        QueryParam(name: "SYBNUMERIC15", 567765.3746325679, precision: 15, scale: 9, datatype: SYBNUMERIC),
        QueryParam(name: "SYBDECIMAL", 947919.259, precision: 8, scale: 2, datatype: SYBDECIMAL),
        QueryParam(name: "SYBDECIMAL15", 567765.3746325679, precision: 15, scale: 9, datatype: SYBDECIMAL),
      ],
    );
    expect(insertResult.length, equals(1));
    expect(insertResult.last.data.length, equals(0));
    expect(insertResult.last.affectedRows, equals(1));

    // Insert some data
    insertResult = await freetds.query(
      "INSERT INTO #number_overflow_test_freetds (SYBFLT8_FLOAT4, SYBFLT8_FLOAT8, SYBFLT8_DOUBLE, SYBREAL, SYBMONEY, SYBMONEY4, SYBNUMERIC, SYBNUMERIC15, SYBDECIMAL, SYBDECIMAL15)"
      " VALUES (:SYBFLT8_FLOAT4, :SYBFLT8_FLOAT8, :SYBFLT8_DOUBLE, :SYBREAL, :SYBMONEY, :SYBMONEY4, :SYBNUMERIC, :SYBNUMERIC15, :SYBDECIMAL, :SYBDECIMAL15)",
      [
        QueryParam(name: "SYBFLT8_FLOAT4", 5.123456789, precision: 4, scale: 2, datatype: SYBFLT8),
        QueryParam(name: "SYBFLT8_FLOAT8", 5.123456789, precision: 8, scale: 2, datatype: SYBFLT8),
        QueryParam(name: "SYBFLT8_DOUBLE", 5.123456789, precision: 8, scale: 2, datatype: SYBFLT8),
        QueryParam(name: "SYBREAL", 5.123456789, precision: 8, scale: 7, datatype: SYBREAL),
        QueryParam(name: "SYBMONEY", 5.123456789, precision: 8, scale: 2, datatype: SYBMONEY),
        QueryParam(name: "SYBMONEY4", 5.123456789, precision: 8, scale: 2, datatype: SYBMONEY4),
        QueryParam(name: "SYBNUMERIC", 947919.259, precision: 8, scale: 2, datatype: SYBNUMERIC),
        QueryParam(name: "SYBNUMERIC15", 567765.3746325679, precision: 15, scale: 9, datatype: SYBNUMERIC),
        QueryParam(name: "SYBDECIMAL", 947919.259, precision: 8, scale: 2, datatype: SYBDECIMAL),
        QueryParam(name: "SYBDECIMAL15", 567765.3746325679, precision: 15, scale: 9, datatype: SYBDECIMAL),
      ],
    );
    expect(insertResult.length, equals(1));
    expect(insertResult.last.data.length, equals(0));
    expect(insertResult.last.affectedRows, equals(1));

    // Insert some data
    insertResult = await freetds.query(
      "INSERT INTO #number_overflow_test_freetds (SYBFLT8_FLOAT4, SYBFLT8_FLOAT8, SYBFLT8_DOUBLE, SYBREAL, SYBMONEY, SYBMONEY4, SYBNUMERIC, SYBNUMERIC15, SYBDECIMAL, SYBDECIMAL15)"
      " VALUES (:SYBFLT8_FLOAT4, :SYBFLT8_FLOAT8, :SYBFLT8_DOUBLE, :SYBREAL, :SYBMONEY, :SYBMONEY4, :SYBNUMERIC, :SYBNUMERIC15, :SYBDECIMAL, :SYBDECIMAL15)",
      [
        QueryParam(name: "SYBFLT8_FLOAT4", 1.39, precision: 4, scale: 2, datatype: SYBFLT8),
        QueryParam(name: "SYBFLT8_FLOAT8", 1237.459, precision: 8, scale: 2, datatype: SYBFLT8),
        QueryParam(name: "SYBFLT8_DOUBLE", 1237.459, precision: 8, scale: 2, datatype: SYBFLT8),
        QueryParam(name: "SYBREAL", 1237.459, precision: 8, scale: 2, datatype: SYBREAL),
        QueryParam(name: "SYBMONEY", 1237.459, precision: 8, scale: 2, datatype: SYBMONEY),
        QueryParam(name: "SYBMONEY4", 1237.459, precision: 8, scale: 2, datatype: SYBMONEY4),
        QueryParam(name: "SYBNUMERIC", 947919.259, precision: 8, scale: 2, datatype: SYBNUMERIC),
        QueryParam(name: "SYBNUMERIC15", 567765.3746325679, precision: 15, scale: 9, datatype: SYBNUMERIC),
        QueryParam(name: "SYBDECIMAL", 947919.259, precision: 8, scale: 2, datatype: SYBDECIMAL),
        QueryParam(name: "SYBDECIMAL15", 567765.3746325679, precision: 15, scale: 9, datatype: SYBDECIMAL),
      ],
    );
    expect(insertResult.length, equals(1));
    expect(insertResult.last.data.length, equals(0));
    expect(insertResult.last.affectedRows, equals(1));

    // Insert some data
    insertResult = await freetds.query(
      "INSERT INTO #number_overflow_test_freetds (SYBFLT8_FLOAT4, SYBFLT8_FLOAT8, SYBFLT8_DOUBLE, SYBREAL, SYBMONEY, SYBMONEY4, SYBNUMERIC, SYBNUMERIC15, SYBDECIMAL, SYBDECIMAL15)"
      " VALUES (:SYBFLT8_FLOAT4, :SYBFLT8_FLOAT8, :SYBFLT8_DOUBLE, :SYBREAL, :SYBMONEY, :SYBMONEY4, :SYBNUMERIC, :SYBNUMERIC15, :SYBDECIMAL, :SYBDECIMAL15)",
      [
        QueryParam(name: "SYBFLT8_FLOAT4", 1.39, datatype: SYBFLT8),
        QueryParam(name: "SYBFLT8_FLOAT8", 1237.456789, datatype: SYBFLT8),
        QueryParam(name: "SYBFLT8_DOUBLE", 1237.456789, datatype: SYBFLT8),
        QueryParam(name: "SYBREAL", 1237.456789, datatype: SYBREAL),
        QueryParam(name: "SYBMONEY", 1237.456789, datatype: SYBMONEY),
        QueryParam(name: "SYBMONEY4", 1237.456789, datatype: SYBMONEY4),
        QueryParam(name: "SYBNUMERIC", 947919.259, datatype: SYBNUMERIC),
        QueryParam(name: "SYBNUMERIC15", 567765.3746325679, datatype: SYBNUMERIC),
        QueryParam(name: "SYBDECIMAL", 947919.259, datatype: SYBDECIMAL),
        QueryParam(name: "SYBDECIMAL15", 567765.3746325679, datatype: SYBDECIMAL),
      ],
    );
    expect(insertResult.length, equals(1));
    expect(insertResult.last.data.length, equals(0));
    expect(insertResult.last.affectedRows, equals(1));

    // Query the database using a parameterized query
    var results = await freetds.query("SELECT * FROM #number_overflow_test_freetds");
    expect(results.length, equals(1));
    expect(results.last.data.length, equals(4));
    expect(results.last.data[0].values.length, equals(11));
    expect(results.last.data[1].values.length, equals(11));
    expect(results.last.data[2].values.length, equals(11));
    expect(results.last.data[3].values.length, equals(11));
    expect(results.last.affectedRows, equals(-1));

    expect(results.last.data[0]["SYBFLT8_FLOAT4"], equals(1.3));
    expect(results.last.data[0]["SYBFLT8_FLOAT8"], equals(1237.45));
    expect(results.last.data[0]["SYBFLT8_DOUBLE"], equals(1237.45));
    expect(results.last.data[0]["SYBREAL"], equals(1237.45));
    expect(results.last.data[0]["SYBMONEY"], equals(1237.45));
    expect(results.last.data[0]["SYBMONEY4"], equals(1237.45));
    expect(results.last.data[0]["SYBNUMERIC"], equals(947919.26));
    expect(results.last.data[0]["SYBNUMERIC15"], equals(567765.374632568));
    expect(results.last.data[0]["SYBDECIMAL"], equals(947919.26));
    expect(results.last.data[0]["SYBDECIMAL15"], equals(567765.374632568));

    expect(results.last.data[1]["SYBFLT8_FLOAT4"], equals(5.123457));
    expect(results.last.data[1]["SYBFLT8_FLOAT8"], equals(5.123456789));
    expect(results.last.data[1]["SYBFLT8_DOUBLE"], equals(5.123456789));
    expect(results.last.data[1]["SYBREAL"], equals(5.123457));
    expect(results.last.data[1]["SYBMONEY"], equals(5.1234));
    expect(results.last.data[1]["SYBMONEY4"], equals(5.1234));
    expect(results.last.data[1]["SYBNUMERIC"], equals(947919.26));
    expect(results.last.data[1]["SYBNUMERIC15"], equals(567765.374632568));
    expect(results.last.data[1]["SYBDECIMAL"], equals(947919.26));
    expect(results.last.data[1]["SYBDECIMAL15"], equals(567765.374632568));

    expect(results.last.data[2]["SYBFLT8_FLOAT4"], equals(1.39));
    expect(results.last.data[2]["SYBFLT8_FLOAT8"], equals(1237.459));
    expect(results.last.data[2]["SYBFLT8_DOUBLE"], equals(1237.459));
    expect(results.last.data[2]["SYBREAL"], equals(1237.459));
    expect(results.last.data[2]["SYBMONEY"], equals(1237.459));
    expect(results.last.data[2]["SYBMONEY4"], equals(1237.459));
    expect(results.last.data[2]["SYBNUMERIC"], equals(947919.26));
    expect(results.last.data[2]["SYBNUMERIC15"], equals(567765.374632568));
    expect(results.last.data[2]["SYBDECIMAL"], equals(947919.26));
    expect(results.last.data[2]["SYBDECIMAL15"], equals(567765.374632568));

    expect(results.last.data[3]["SYBFLT8_FLOAT4"], equals(1.39));
    expect(results.last.data[3]["SYBFLT8_FLOAT8"], equals(1237.456789));
    expect(results.last.data[3]["SYBFLT8_DOUBLE"], equals(1237.456789));
    expect(results.last.data[3]["SYBREAL"], equals(1237.457));
    expect(results.last.data[3]["SYBMONEY"], equals(1237.4567));
    expect(results.last.data[3]["SYBMONEY4"], equals(1237.4567));
    expect(results.last.data[3]["SYBNUMERIC"], equals(947919.26));
    expect(results.last.data[3]["SYBNUMERIC15"], equals(567765.374632568));
    expect(results.last.data[3]["SYBDECIMAL"], equals(947919.26));
    expect(results.last.data[3]["SYBDECIMAL15"], equals(567765.374632568));
    expect(FreeTDS.lastError, isNull);

    // Drop the test table
    await freetds.query("TRUNCATE TABLE #number_overflow_test_freetds");
    expect(FreeTDS.lastError, isNull);

    // Drop the test table
    await freetds.query("DROP TABLE #number_overflow_test_freetds");
    expect(FreeTDS.lastError, isNull);

    // Finally, close the connection
    await freetds.disconnect();
    expect(FreeTDS.lastError, isNull);
  });

  test('Test SQL INSERT & SELECT UUID', () async {
    await freetds.connect(
      host: TestUtils.host,
      username: TestUtils.username,
      password: TestUtils.password,
      database: TestUtils.database,
      encryption: TestUtils.encryption,
    );

    // Create a table
    await freetds.query("""
    CREATE TABLE #uuid_test_freetds
    (
        SYBUUID CHAR(36),
    );
    """);

    var uuid = Uuid().v4();

    // Insert some data
    var insertResult = await freetds.query(
      "INSERT INTO #uuid_test_freetds (SYBUUID) VALUES (:SYBUUID);",
      [
        QueryParam(name: "SYBUUID", uuid),
      ],
    );
    expect(insertResult.length, equals(1));
    expect(insertResult.last.data.length, equals(0));
    expect(insertResult.last.affectedRows, equals(1));

    // Query the database using a parameterized query
    var results = await freetds.query("SELECT * FROM #uuid_test_freetds");
    expect(results.length, equals(1));
    expect(results.last.data.length, equals(1));
    expect(results.last.data[0].values.length, equals(1));
    expect(results.last.affectedRows, equals(-1));

    expect(results.last.data[0]["SYBUUID"], equals(uuid));
    expect(FreeTDS.lastError, isNull);

    // Drop the test table
    await freetds.query("DROP TABLE #uuid_test_freetds");
    expect(FreeTDS.lastError, isNull);

    // Finally, close the connection
    await freetds.disconnect();
    expect(FreeTDS.lastError, isNull);
  });

  test('Test SQL INSERT & SELECT Null', () async {
    await freetds.connect(
      host: TestUtils.host,
      username: TestUtils.username,
      password: TestUtils.password,
      database: TestUtils.database,
      encryption: TestUtils.encryption,
    );

    // Create a table
    await freetds.query("""
    CREATE TABLE #null_test_freetds
    (
        SYBNULL INTEGER NULL,
    );
    """);

    // Insert some data
    var insertResult = await freetds.query(
      "INSERT INTO #null_test_freetds (SYBNULL) VALUES (:SYBNULL);",
      [
        QueryParam(name: "SYBNULL", null),
      ],
    );
    expect(insertResult.length, equals(1));
    expect(insertResult.last.data.length, equals(0));
    expect(insertResult.last.affectedRows, equals(1));

    // Query the database using a parameterized query
    var results = await freetds.query("SELECT * FROM #null_test_freetds");
    expect(results.length, equals(1));
    expect(results.last.data.length, equals(1));
    expect(results.last.data[0].values.length, equals(1));
    expect(results.last.affectedRows, equals(-1));

    expect(results.last.data[0]["SYBNULL"], equals(null));
    expect(FreeTDS.lastError, isNull);

    // Drop the test table
    await freetds.query("DROP TABLE #null_test_freetds");
    expect(FreeTDS.lastError, isNull);

    // Finally, close the connection
    await freetds.disconnect();
    expect(FreeTDS.lastError, isNull);
  });
}
