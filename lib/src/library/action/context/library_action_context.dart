library freetds.library.action.context;

import "dart:ffi";

import "package:freetds/src/library/library.dart";
import "package:freetds/src/library/model/model.dart";
import "package:logger/logger.dart";

class LibraryActionContext {
  Library library;
  Pointer<LOGINREC> login;
  int timeout;
  Pointer<DBPROCESS> connection;
  Level loggerLevel;
  Function(Level, String)? logger;

  LibraryActionContext({
    required this.library,
    required this.login,
    required this.timeout,
    required this.connection,
    required this.loggerLevel,
    required this.logger,
  });
}
