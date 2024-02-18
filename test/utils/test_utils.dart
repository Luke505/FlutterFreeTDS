import "dart:io";

import 'package:collection/collection.dart';
import "package:flutter_test/flutter_test.dart";
import "package:freetds/freetds.dart";
import "package:logger/logger.dart";

class TestUtils {
  static const host = "0.0.0.0:2638";
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

  static void assertListEquality(List actual, List expected) {
    expect(ListEquality().equals(actual, expected), isTrue, reason: "Expected: $expected\n  Actual: $actual\nAre not equals");
  }
}
