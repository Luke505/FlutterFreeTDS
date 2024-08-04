library freetds.freetds;

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io' show Platform;

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:freetds/src/communication/freetds_error.dart';
import 'package:freetds/src/communication/freetds_message.dart';
import 'package:freetds/src/constants.dart';
import 'package:freetds/src/error/freetds_error_message.dart';
import 'package:freetds/src/error/freetds_exception.dart';
import 'package:freetds/src/execution_result.dart';
import 'package:freetds/src/library/library.dart';
import 'package:freetds/src/library/model/functions.dart';
import 'package:freetds/src/library/model/model.dart';
import 'package:freetds/src/query_param.dart';
import 'package:freetds/src/utils/connection_utils.dart';
import 'package:logger/logger.dart';

class FreeTDS {
  static const int defaultTimeout = 5;
  static const int defaultMaxTextSize = 4096;

  static int timeout = defaultTimeout;
  static int maxTextSize = defaultMaxTextSize;

  static Pointer<LOGINREC> _login = nullptr;
  static Pointer<DBPROCESS> _connection = nullptr;
  static Pointer<SQL_COLUMN> _columns = nullptr;
  static int _numColumns = 0;

  static Level loggerLevel = Level.trace;
  static Function(Level, String)? logger;

  static Library? _library;

  static StreamController<FreeTDSError>? errorStream;
  static StreamController<FreeTDSMessage>? messageStream;

  static Future<void> open() async {
    if (Platform.isMacOS || Platform.isIOS || Platform.isWindows) {
      _library = Library();
    } else {
      throw UnsupportedError('FreeTDS is only supported on macOS, iOS and windows.');
    }

    if (_library!.dbinit() == FAIL) {
      throw StateError('FreeTDS db init failed.');
    }

    _library!.dbgetlasterror().ref.dberrstr = nullptr;
    await closeErrorStream();
    await closeMessageStream();
    setMessageHandler(nullptr);
    setErrorHandler(nullptr);
  }

  static void setMessageHandler(Pointer<NativeFunction<mhandlefunc_Native>> handler) async {
    _library!.dbmsghandle(handler);
  }

  static void setErrorHandler(Pointer<NativeFunction<ehandlefunc_Native>> handler) async {
    _library!.dberrhandle(handler);
  }

  static void openErrorStream() async {
    if (errorStream == null) {
      errorStream = StreamController.broadcast();
    }
  }

  static Future<void> closeErrorStream() async {
    if (errorStream != null) {
      try {
        if (!(errorStream?.isClosed ?? true)) {
          await errorStream?.close();
        }
      } catch (_) {}
      errorStream = null;
    }
  }

  static void openMessageStream() {
    if (messageStream == null) {
      messageStream = StreamController.broadcast();
    }
  }

  static Future<void> closeMessageStream() async {
    if (messageStream != null) {
      try {
        if (!(messageStream?.isClosed ?? true)) {
          await messageStream?.close();
        }
      } catch (_) {}
      messageStream = null;
    }
  }

  static bool isInitialized() => _library != null;

  static bool isConnected() => isInitialized() && _library!.dbdead(_connection) == 0;

  // region Test

  @visibleForTesting
  static Future<void> openForTest(String libraryPath) async {
    if (Platform.isMacOS || Platform.isIOS || Platform.isWindows) {
      _library = Library(libraryPath);
    } else {
      throw UnsupportedError('FreeTDS is only supported on macOS, iOS and windows.');
    }

    if (_library!.dbinit() == FAIL) {
      throw StateError('FreeTDS db init failed.');
    }

    _library!.dbgetlasterror().ref.dberrstr = nullptr;
    _library!.dbgetlasterror().ref.severity = -1;
    openErrorStream();
    openMessageStream();
    setMessageHandler(Pointer.fromFunction<mhandlefunc_Native>(_handleMessage, TDS_SUCCESS));
    setErrorHandler(Pointer.fromFunction<ehandlefunc_Native>(_handleError, CANCEL));
  }

  @visibleForTesting
  static Library? get library => _library;

  @visibleForTesting
  static Pointer<DBPROCESS> get connection => _connection;

  // endregion

  // region Handler

  // Handles message callback from FreeTDS _library.
  static int _handleMessage(Pointer<DBPROCESS> dbproc, int msgno, int msgstate, int severity, Pointer<Utf8> msgtext, Pointer<Utf8> srvname, Pointer<Utf8> procname, int line) {
    try {
      if (severity > 10) {
        var error = FreeTDSError(msgtext.toDartString(), severity);
        _storeError(error);
      } else {
        if (messageStream != null && !messageStream!.isClosed) {
          var message = FreeTDSMessage(msgtext.toDartString(), severity);
          messageStream!.add(message);
        }
      }
    } catch (_) {}

    return TDS_SUCCESS;
  }

  // Handles error callback from FreeTDS _library.
  static int _handleError(Pointer<DBPROCESS> dbproc, int severity, int dberr, int oserr, Pointer<Utf8> dberrstr, Pointer<Utf8> oserrstr) {
    if (oserrstr == nullptr) return CANCEL;

    try {
      var error = FreeTDSError(dberrstr.toDartString(), severity);
      _storeError(error);
    } catch (_) {}

    return CANCEL;
  }

  static void _storeError(FreeTDSError error) {
    _library!.dbgetlasterror().ref.dberrstr = error.error.toNativeUtf8();
    _library!.dbgetlasterror().ref.severity = error.severity;
    if (errorStream != null && !errorStream!.isClosed) {
      errorStream!.add(error);
    }
  }

  // endregion

  // region Cleanup

  static void _cleanupAfterTable() {
    if (_columns != nullptr) {
      Pointer<SQL_COLUMN> column;
      for (int i = 0; i < _numColumns; i++) {
        try {
          column = _columns+(i);
          if (column != nullptr) {
            if (column.ref.data != nullptr) {
              calloc.free(column.ref.data);
              column.ref.data = nullptr;
            }
            if (column.ref.status != nullptr) {
              calloc.free(column.ref.status);
              column.ref.status = nullptr;
            }
          }
        } catch (_) {
          break;
        }
      }
      calloc.free(_columns);
      _columns = nullptr;
    }
  }

  static void _cleanupAfterExecution() {
    _cleanupAfterTable();
    if (_connection != nullptr) {
      try {
        _library!.dbfreebuf(_connection);
      } catch (_) {}
    }
  }

  static void _cleanupAfterConnection() {
    _cleanupAfterExecution();
    if (_login != nullptr) {
      try {
        _library!.dbloginfree(_login);
      } catch (_) {}
      _login = nullptr;
    }
  }

  // endregion

  // region Action

  static void connect(
      {required String host,
      required String username,
      required String password,
      String? database,
      SYBEncryptionLevel? encryption,
      String? charset = "utf8",
      String? lang,
      String? appName,
      int? version = DBVERSION_100}) {
    assert(host.isNotEmpty);
    assert(username.isNotEmpty);
    assert(password.isNotEmpty);

    _library!.dbgetlasterror().ref.dberrstr = nullptr;
    _library!.dbgetlasterror().ref.severity = -1;

    if (isConnected()) {
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.pendingConnectionError);
    }

    _login = _library!.dblogin();
    if (_login == nullptr) {
      _cleanupAfterConnection();
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
    }

    if (_library!.dbsetlname(_login, host.toNativeUtf8(), DBSETHOST) == 0) {
      _cleanupAfterConnection();
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
    }
    if (_library!.dbsetlname(_login, username.toNativeUtf8(), DBSETUSER) == 0) {
      _cleanupAfterConnection();
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
    }
    if (_library!.dbsetlname(_login, password.toNativeUtf8(), DBSETPWD) == 0) {
      _cleanupAfterConnection();
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
    }

    if (encryption != null) {
      if (_library!.dbsetlname(_login, encryption.value.toNativeUtf8(), DBSETENCRYPTION) == 0) {
        _cleanupAfterConnection();
        throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
      }
    }

    if (charset != null) {
      if (_library!.dbsetlname(_login, charset.toNativeUtf8(), DBSETCHARSET) == 0) {
        _cleanupAfterConnection();
        throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
      }
    }

    if (lang != null) {
      if (_library!.dbsetlname(_login, lang.toNativeUtf8(), DBSETNATLANG) == 0) {
        _cleanupAfterConnection();
        throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
      }
    }

    if (appName != null) {
      if (_library!.dbsetlname(_login, appName.toNativeUtf8(), DBSETAPP) == 0) {
        _cleanupAfterConnection();
        throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
      }
    }

    if (version != null) {
      if (_library!.dbsetlversion(_login, version) == 0) {
        _cleanupAfterConnection();
        throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
      }
    }

    _library!.dbsetlogintime(timeout);

    _connection = _library!.dbopen(_login, host.toNativeUtf8());
    if (_connection == nullptr) {
      _cleanupAfterConnection();
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.connectionError);
    }

    if (database != null) {
      int returnCode = _library!.dbuse(_connection, database.toNativeUtf8());
      if (returnCode == FAIL) {
        _cleanupAfterConnection();
        throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.databaseUseError);
      }
    }

    _cleanupAfterConnection();
  }

  static List<FreeTDSExecutionResultTable> query(String sql, [List<QueryParam>? params]) {
    assert(sql.isNotEmpty);

    if (!FreeTDS.isConnected()) {
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.noConnectionError);
    }

    _library!.dbgetlasterror().ref.dberrstr = nullptr;
    _library!.dbgetlasterror().ref.severity = -1;

    try {
      _library!.dbsettime(timeout);
      Pointer<DBERROR> lastError = _library!.dbgetlasterror();
      if (lastError != nullptr && lastError.ref.dberrstr != nullptr) {
        throw FreeTDSException.fromFreeTDSError(FreeTDSError.fromDBError(lastError.ref));
      }

      Pointer<TDSQUERYPARAM> queryParams = nullptr, lastQueryParam = nullptr;

      if (params != null) {
        for (int i = 0; i < params.length; i++) {
          Pointer<TDSQUERYPARAM> queryParam = calloc<TDSQUERYPARAM>();
          if (queryParam == nullptr) {
            throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.outOfMemoryError);
          }

          queryParam.ref.name = params[i].name?.toNativeUtf8() ?? (i + 1).toString().toNativeUtf8();
          queryParam.ref.output = params[i].output;
          queryParam.ref.datatype = params[i].datatype;
          queryParam.ref.maxlen = params[i].maxlen;
          queryParam.ref.scale = params[i].scale ?? 0;
          queryParam.ref.precision = params[i].precision ?? 0;
          queryParam.ref.datalen = params[i].datalen;
          queryParam.ref.value = params[i].getValue(_library!, _connection) ?? nullptr;

          if (lastQueryParam == nullptr) {
            queryParams = queryParam;
          } else {
            lastQueryParam.ref.next = queryParam;
          }

          if (loggerLevel.value >= Level.trace.value && logger != null) {
            logger!(
                Level.trace,
                "PARAMETER > Column ${params[i].name ?? (i + 1)}, type: ${queryParam.ref.datatype} (${Connection.getColumnTypeName(queryParam.ref.datatype)}),"
                " datalen: ${queryParam.ref.datalen}, value: ${params[i].getValue(_library!, _connection)?.asTypedList(queryParam.ref.datalen)}");
          }

          lastQueryParam = queryParam;
        }
      }

      Pointer<Utf8> sqlUtf8 = sql.toNativeUtf8();
      int returnCode = _library!.dbsqlexecparams(_connection, sqlUtf8, queryParams);
      if (returnCode == FAIL) {
        throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.executeCmdError);
      }
      lastError = _library!.dbgetlasterror();
      if (lastError != nullptr && lastError.ref.dberrstr != nullptr) {
        throw FreeTDSException.fromFreeTDSError(FreeTDSError.fromDBError(lastError.ref));
      }

      List<FreeTDSExecutionResultTable> tables = [];

      while ((returnCode = _library!.dbresults(_connection)) != NO_MORE_RESULTS) {
        lastError = _library!.dbgetlasterror();
        if (lastError != nullptr && lastError.ref.dberrstr != nullptr) {
          throw FreeTDSException.fromFreeTDSError(FreeTDSError.fromDBError(lastError.ref));
        }

        FreeTDSExecutionResultTable table = FreeTDSExecutionResultTable();
        tables.add(table);

        if (returnCode == FAIL) {
          throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.getExecutionResultError);
        }

        table.affectedRows = _library!.dbcount(_connection);

        _numColumns = _library!.dbnumcols(_connection);
        if (_numColumns == 0) {
          continue;
        }

        _columns = calloc<SQL_COLUMN>(_numColumns);
        if (_columns == nullptr) {
          throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.outOfMemoryError);
        }

        Pointer<SQL_COLUMN> column;
        int rowCode;

        lastError = _library!.dbgetlasterror();
        if (lastError != nullptr && lastError.ref.dberrstr != nullptr) {
          throw FreeTDSException.fromFreeTDSError(FreeTDSError.fromDBError(lastError.ref));
        }

        for (int columnIndex = 0; columnIndex < _numColumns; columnIndex++) {
          int c = columnIndex + 1;
          column = _columns+(columnIndex);
          column.ref.name = _library!.dbcolname(_connection, c);
          column.ref.type = _library!.dbcoltype(_connection, c);
          column.ref.size = _library!.dbcollen(_connection, c);

          final columnName = column.ref.name != nullptr ? column.ref.name.cast<Utf8>().toDartString() : "";
          table.columns.add(columnName);

          int bindType = Connection.getBindAndUpdate(column);

          if (loggerLevel.value >= Level.trace.value && logger != null) {
            logger!(
                Level.trace,
                "TYPE > Column $columnName, type: ${column.ref.type} (${Connection.getColumnTypeName(column.ref.type)}),"
                " bindType: $bindType (${Connection.getColumnBindName(bindType)}), info: ${json.encode(SQLColumn.fromNative(column.ref))}");
          }

          Connection.bind(_library!, _connection, column, c, bindType);

          lastError = _library!.dbgetlasterror();
          if (lastError != nullptr && lastError.ref.dberrstr != nullptr) {
            throw FreeTDSException.fromFreeTDSError(FreeTDSError.fromDBError(lastError.ref));
          }
        }
        while ((rowCode = _library!.dbnextrow(_connection)) != NO_MORE_ROWS) {
          switch (rowCode) {
            case REG_ROW:
              Map<String, dynamic> row = {};
              for (int i = 0; i < _numColumns; i++) {
                column = _columns+(i);
                final columnName = column.ref.name != nullptr ? column.ref.name.cast<Utf8>().toDartString() : "";
                dynamic value;
                if (column.ref.status.value != -1) {
                  if (loggerLevel.value >= Level.trace.value && logger != null) {
                    logger!(Level.trace, "DATA > Column $columnName, info: ${json.encode(SQLColumn.fromNative(column.ref))}");
                  }

                  value = Connection.getData(_library!, _connection, column, i);

                  lastError = _library!.dbgetlasterror();
                  if (lastError != nullptr && lastError.ref.dberrstr != nullptr) {
                    throw FreeTDSException.fromFreeTDSError(FreeTDSError.fromDBError(lastError.ref));
                  }

                  if (loggerLevel.value >= Level.trace.value && logger != null) {
                    logger!(Level.trace, "DATA > Column $columnName, ${value != null ? "value: $value" : "value IS NULL"}");
                  }
                }
                row[columnName] = value;
              }
              table.data.add(row);
              break;
            case BUF_FULL:
              throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.bufferFullError);
            case FAIL:
              throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.unknownError);
            default:
          }
        }

        _cleanupAfterTable();
      }

      lastError = _library!.dbgetlasterror();
      if (lastError != nullptr && lastError.ref.dberrstr != nullptr) {
        throw FreeTDSException.fromFreeTDSError(FreeTDSError.fromDBError(lastError.ref));
      }

      _cleanupAfterExecution();
      return tables;
    } catch (_) {
      _cleanupAfterExecution();
      rethrow;
    }
  }

  static void disconnect() {
    _library!.dbgetlasterror().ref.dberrstr = nullptr;
    _library!.dbgetlasterror().ref.severity = -1;
    _cleanupAfterConnection();
    if (_connection != nullptr) {
      _library!.dbclose(_connection);
      _connection = nullptr;
    }
  }

  static Future<void> close() async {
    FreeTDS.disconnect();
    _library!.dbexit();
    await FreeTDS.closeErrorStream();
    await FreeTDS.closeMessageStream();
  }

// endregion
}
