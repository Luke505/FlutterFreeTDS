import 'dart:ffi';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freetds/freetds.dart';
import 'package:freetds/src/library/model/native/db_error.dart';
import 'package:logger/logger.dart';

class TestUtils {
  static const String host = "0.0.0.0:2638";
  static const String username = "dba";
  static const String password = "sql";
  static const String database = "test";
  static const SYBEncryptionLevel? encryption = null;

  static final Logger logger = Logger(
    level: Level.all,
    output: ConsoleOutput(),
    printer: SimplePrinter(
      colors: true,
      printTime: true,
    ),
    filter: ProductionFilter(),
  );

  static Future<void> setUpTest() async {
    String libraryPath = (goldenFileComparator as LocalFileComparator).basedir.path + "../";

    if (Platform.isMacOS) {
      libraryPath = 'macos/FreeTDS-macOS.framework/FreeTDS-macOS';
    } else if (Platform.isWindows) {
      libraryPath = 'windows/sybdb.dll';
    } else {
      throw UnsupportedError('FreeTDS tests are only supported on macOS and windows.');
    }

    await FreeTDS.openForTest(libraryPath);

    FreeTDS.logger = (Level level, String msg) => logger.log(level, msg);
    FreeTDS.errorStream!.stream.listen((event) {
      logger.e(event);
    });
    FreeTDS.messageStream!.stream.listen((event) {
      logger.d(event);
    });
  }

  static Future<void> tearDownTest() async {
    await FreeTDS.close();
  }

  static void expectNoError() {
    Pointer<DBERROR> lastError = FreeTDS.library!.dbgetlasterror();
    expect(lastError, isNot(nullptr));
    expect(
      lastError.ref.dberrstr,
      equals(nullptr),
      reason: "Unexpected error: ${lastError.ref.dberrstr != nullptr ? lastError.ref.dberrstr.toDartString() : nullptr},"
          " with severity: ${lastError.ref.severity}",
    );
    expect(lastError.ref.severity, equals(-1));
  }

  static void expectError(String error, int severity) {
    Pointer<DBERROR> lastError = FreeTDS.library!.dbgetlasterror();
    expect(lastError, isNot(nullptr));
    expect(lastError.ref.dberrstr, isNot(nullptr));
    expect(lastError.ref.dberrstr.toDartString(), equals(error));
    expect(lastError.ref.severity, equals(severity));
  }

  static void assertListEquality(List actual, List expected) {
    expect(ListEquality().equals(actual, expected), isTrue, reason: "Expected: $expected\n  Actual: $actual\nAre not equals");
  }
}
