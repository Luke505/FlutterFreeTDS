import "dart:ffi";
import "dart:io";

import 'package:collection/collection.dart';
import "package:ffi/ffi.dart";
import "package:flutter_test/flutter_test.dart";
import "package:freetds/freetds.dart";
import "package:logger/logger.dart";

class TestUtils {
  static const host = "192.168.1.174:2638";
  static const username = "dba";
  static const password = "sql";
  static const database = "test";
  static const encryption = SYBEncryptionLevel.REQUIRE;

  static final Logger logger = Logger(
    level: Level.all,
    output: ConsoleOutput(),
    printer: SimplePrinter(
      colors: true,
      printTime: true,
    ),
    filter: ProductionFilter(),
  );

  static FreeTDS setUpTest() {
    String libraryPath = (goldenFileComparator as LocalFileComparator).basedir.path + "../";

    if (Platform.isMacOS) {
      libraryPath = 'macos/FreeTDS.framework/FreeTDS';
    } else if (Platform.isIOS) {
      libraryPath = 'ios/FreeTDS.framework/FreeTDS';
    } else if (Platform.isWindows) {
      libraryPath = 'windows/sybdb.dll';
    } else {
      throw UnsupportedError('FreeTDS is only supported on macOS, iOS and windows.');
    }

    FreeTDS freetds = FreeTDS.initTest(libraryPath, false);

    FreeTDS.logger = (Level level, String msg) => logger.log(level, msg);
    FreeTDS.errorStream!.stream.listen((event) {
      logger.e(event);
    });
    FreeTDS.messageStream!.stream.listen((event) {
      logger.d(event);
    });

    return freetds;
  }

  static double convertDoubleToReal(double d, FreeTDS freetds) {
    String doubleStr = d.toStringAsPrecision(20);
    int fromDataType = SYBCHAR;
    int toDataType = SYBREAL;
    final Pointer<Uint8> result = malloc<Uint8>();
    var dbConvertResult = freetds.library.dbconvert(freetds.connection, fromDataType, doubleStr.toNativeUtf8().cast(), doubleStr.length, toDataType, result.cast(), -1);
    if (dbConvertResult < 0) {
      throw ArgumentError("Invalid");
    }
    return result.cast<Float>().value;
  }

  static void assertListEquality(List actual, List expected) {
    expect(ListEquality().equals(actual, expected), isTrue, reason: "Expected: $expected\n  Actual: $actual\nAre not equals");
  }
}
