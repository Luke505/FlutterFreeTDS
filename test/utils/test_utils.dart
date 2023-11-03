import "dart:ffi";
import "dart:io";

import "package:ffi/ffi.dart";
import "package:flutter_test/flutter_test.dart";
import "package:freetds/freetds.dart";
import "package:logger/logger.dart";

class TestUtils {
  static const host = "127.0.0.1:2638";
  static const username = "dba";
  static const password = "sql";
  static const database = "test";
  static const encryption = SYBEncryptionLevel.REQUIRE;

  static final Logger logger = Logger(
    level: Level.all,
    output: ConsoleOutput(),
    printer: PrettyPrinter(
      colors: true,
      methodCount: 0,
      printTime: true,
      printEmojis: true,
      errorMethodCount: 15,
      noBoxingByDefault: true,
    ),
    filter: ProductionFilter(),
  );

  // Handles message callback from FreeTDS library.
  static int handleMessage(
    Pointer<DBPROCESS> dbproc,
    int msgno,
    int msgstate,
    int severity,
    Pointer<Utf8> msgtext,
    Pointer<Utf8> srvname,
    Pointer<Utf8> procname,
    int line,
  ) {
    logger.d("Message{msgno: $msgno, msgstate: $msgstate, severity: $severity}: ${msgtext.toDartString()}"
        " (srvname: $srvname, procname: $procname, line: $line)");
    return CANCEL;
  }

  static FreeTDS setUpTest() {
    String libraryPath = (goldenFileComparator as LocalFileComparator).basedir.path + "../";

    if (Platform.isMacOS) {
      libraryPath = 'macos/FreeTDSKit.framework/FreeTDSKit';
    } else if (Platform.isIOS) {
      libraryPath = 'ios/FreeTDSKit.framework/FreeTDSKit';
    } else if (Platform.isWindows) {
      libraryPath = 'windows/sybdb.dll';
    } else {
      throw UnsupportedError('FreeTDS is only supported on macOS, iOS and windows.');
    }

    FreeTDS.initTest(libraryPath, false, true, TestUtils.logger);
    FreeTDS freetds = FreeTDS.instance;
    freetds.library.dbmsghandle(Pointer.fromFunction<mhandlefunc_Native>(TestUtils.handleMessage, CANCEL));
    return freetds;
  }
}
