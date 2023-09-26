library freetds.freetds;

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io' show Platform;

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:freetds/src/constants.dart';
import 'package:logger/logger.dart';
import 'package:queue/queue.dart' show Queue;

import 'communication/freetds_error.dart';
import 'error/error_message.dart';
import 'error/freetds_exception.dart';
import 'execution_result.dart';
import 'library.dart';
import 'query_param.dart';
import 'utils/connection_utils.dart';

class FreeTDS {
  static const int defaultTimeout = 5;
  static const String defaultCharset = "UTF-8";
  static const int defaultMaxTextSize = 4096;

  int timeout = defaultTimeout;
  String charset = defaultCharset;
  int maxTextSize = defaultMaxTextSize;

  Pointer<LOGINREC> _login = nullptr;
  Pointer<DBPROCESS> _connection = nullptr;
  Pointer<SQL_COLUMN> _columns = nullptr;
  int _numColumns = 0;
  int? _returnCode;

  bool _executing = false;

  static Level loggerLevel = Level.trace;
  static Function(Level, String)? logger;

  static Queue? _queue;
  static FreeTDS? _instance;
  late FreeTDS_library _library;

  static FreeTDSError? lastError;
  static StreamController<FreeTDSError>? errorStream;
  //StreamController<FreeTDSMessage> messageStream = StreamController.broadcast();

  static FreeTDS get instance => _instance ??= FreeTDS._internal();

  FreeTDS._internal() {
    if (Platform.isMacOS || Platform.isIOS) {
      _library = FreeTDS_library();
    } else {
      throw UnsupportedError('FreeTDS is only supported on iOS and macOS.');
    }

    if (_library.dbinit() == FAIL) {
      throw StateError('FreeTDS db init failed.');
    }

    lastError = null;
    setQueue(true);
    setErrorStream(false);
    _library.dberrhandle(Pointer.fromFunction<ehandlefunc_Native>(_handleError, CANCEL));
    //_library.dbmsghandle(Pointer.fromFunction<mhandlefunc_Native>(_handleMessage, CANCEL));
  }

  FreeTDS._test(String libraryPath) {
    if (Platform.isMacOS || Platform.isIOS) {
      _library = FreeTDS_library.test(libraryPath);
    } else {
      throw UnsupportedError('FreeTDS is only supported on iOS and macOS.');
    }

    if (_library.dbinit() == FAIL) {
      throw StateError('FreeTDS db init failed.');
    }

    lastError = null;
    setQueue(true);
    setErrorStream(true);
    _library.dberrhandle(Pointer.fromFunction<ehandlefunc_Native>(_handleError, CANCEL));
    //_library.dbmsghandle(Pointer.fromFunction<mhandlefunc_Native>(_handleMessage, CANCEL));
  }

  @visibleForTesting
  static void initTest(String libraryPath, Logger logger) {
    _instance = FreeTDS._test(libraryPath);

    FreeTDS.logger = (Level level, String msg) => logger.log(level, msg);
    errorStream!.stream.listen((event) {
      logger.e(event);
    });
  }

  @visibleForTesting
  static Future<void> afterTest() async {
    try {
      instance._library.dbexit();
    } catch (_) {}
    try {
      await setQueue(false);
    } catch (_) {}
    try {
      await setErrorStream(false);
    } catch (_) {}
  }

  static Future<void> setQueue(bool enable) async {
    if (enable) {
      if (_queue == null) {
        _queue = Queue();
      }
    } else if (_queue != null) {
      try {
        _queue!.cancel();
      } catch (_) {}
      _queue = null;
    }
  }

  static Future<void> setErrorStream(bool enable) async {
    if (enable) {
      if (errorStream == null) {
        errorStream = StreamController.broadcast();
      }
    } else if (errorStream != null) {
      try {
        if (!errorStream!.isClosed) {
          await errorStream!.close();
        }
      } catch (_) {}
      errorStream = null;
    }
  }

  bool isConnected() {
    return _library.dbdead(_connection) == 0;
  }

  bool isExecuting() {
    return _executing;
  }

  // ignore: unused_element
  void _dealloc() {
    lastError = null;
    _library.dbexit();
  }

  // region Handler

  // Handles message callback from FreeTDS library.
  // ignore: unused_element
  static int _handleMessage(Pointer<DBPROCESS> dbproc, int msgno, int msgstate, int severity, Pointer<Utf8> msgtext, Pointer<Utf8> srvname,
      Pointer<Utf8> procname, int line) {
    return CANCEL;
  }

  // Handles error callback from FreeTDS library.
  static int _handleError(Pointer<DBPROCESS> dbproc, int severity, int dberr, int oserr, Pointer<Utf8> dberrstr, Pointer<Utf8> oserrstr) {
    try {
      var error = FreeTDSError(dberrstr.toDartString(), dberr, severity);
      lastError = error;
      if (errorStream != null && !errorStream!.isClosed) {
        errorStream!.add(error);
      }
    } catch (_) {}

    if (instance._library.dbdead(dbproc) != 0 && (dbproc == nullptr || dbproc.ref.msdblib == 0)) {
      return EXIT;
    }

    if (dbproc == nullptr || dbproc.ref.msdblib == 0) {
      switch (dberr) {
        case EXTIME:
          return EXIT;
        default:
          break;
      }
    }

    return CANCEL;
  }

  // endregion

  // region Cleanup

  void _cleanupAfterTable() {
    if (_columns != nullptr) {
      Pointer<SQL_COLUMN> column;
      for (int i = 0; i < _numColumns; i++) {
        column = _columns.elementAt(i);
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
      }
      calloc.free(_columns);
      _columns = nullptr;
    }
  }

  void _cleanupAfterExecution() {
    _cleanupAfterTable();
    if (_connection != nullptr) {
      _library.dbfreebuf(_connection);
    }
  }

  void _cleanupAfterConnection() {
    _cleanupAfterExecution();
    if (_login != nullptr) {
      _library.dbloginfree(_login);
      _login = nullptr;
    }
  }

  // endregion

  // region Action

  Future<void> connect({required String host, required String username, required String password, String? database}) async {
    assert(host.isNotEmpty);
    assert(username.isNotEmpty);
    assert(password.isNotEmpty);

    if (_queue != null) {
      await _queue!.add(() async {
        await _connect(host: host, username: username, password: password, database: database);
      });
    } else {
      await _connect(host: host, username: username, password: password, database: database);
    }
  }

  Future<void> _connect({required String host, required String username, required String password, String? database}) async {
    lastError = null;

    if (isConnected()) {
      throw FreeTDSException.fromErrorMessage(ErrorMessage.pendingConnectionError);
    }

    _login = _library.dblogin();
    if (_login == nullptr) {
      throw FreeTDSException.fromErrorMessage(ErrorMessage.initError);
    }

    _library.dbsetlname(_login, username.toNativeUtf8(), DBSETUSER);
    _library.dbsetlname(_login, password.toNativeUtf8(), DBSETPWD);
    _library.dbsetlname(_login, host.toNativeUtf8(), DBSETHOST);
    _library.dbsetlname(_login, charset.toNativeUtf8(), DBSETCHARSET);

    _library.dbsetlogintime(timeout);

    _connection = _library.dbopen(_login, host.toNativeUtf8());
    if (_connection == nullptr) {
      throw FreeTDSException.fromErrorMessage(ErrorMessage.connectionError);
    }

    if (database != null) {
      _returnCode = _library.dbuse(_connection, database.toNativeUtf8());
      if (_returnCode == FAIL) {
        throw FreeTDSException.fromErrorMessage(ErrorMessage.databaseUseError);
      }
    }
  }

  Future<List<FreeTDSExecutionResultTable>> query(String sql, [List<QueryParam>? params]) async {
    assert(sql.isNotEmpty);

    if (_queue != null) {
      return await _queue!.add(() async {
        return await _query(sql, params);
      });
    } else {
      return await _query(sql, params);
    }
  }

  Future<List<FreeTDSExecutionResultTable>> _query(String sql, [List<QueryParam>? params]) async {
    lastError = null;

    if (!isConnected()) {
      throw FreeTDSException.fromErrorMessage(ErrorMessage.noConnectionError);
    }
    if (isExecuting()) {
      throw FreeTDSException.fromErrorMessage(ErrorMessage.pendingExecutionError);
    }
    _executing = true;
    try {
      _library.dbsettime(timeout);

      Pointer<TDSQUERYPARAM> queryParams = nullptr,
          lastQueryParam = nullptr;

      if (params != null) {
        for (int i = 0; i < params.length; i++) {
          Pointer<TDSQUERYPARAM> queryParam = calloc<TDSQUERYPARAM>();
          if (queryParam == nullptr) {
            throw FreeTDSException.fromErrorMessage(ErrorMessage.outOfMemoryError);
          }

          queryParam.ref.name = params[i].name?.toNativeUtf8() ?? (i + 1).toString().toNativeUtf8();
          queryParam.ref.output = params[i].output;
          queryParam.ref.datatype = params[i].datatype;
          queryParam.ref.maxlen = params[i].maxlen;
          queryParam.ref.scale = params[i].scale;
          queryParam.ref.precision = params[i].precision;
          queryParam.ref.datalen = params[i].datalen;
          queryParam.ref.value = params[i].value ?? nullptr;

          if (lastQueryParam == nullptr) {
            queryParams = queryParam;
          } else {
            lastQueryParam.ref.next = queryParam;
          }

          lastQueryParam = queryParam;
        }
      }

      Pointer<Utf8> sqlUtf8 = sql.toNativeUtf8();
      _returnCode = _library.dbsqlexecparams(_connection, sqlUtf8, queryParams);
      if (_returnCode == FAIL) {
        throw FreeTDSException.fromErrorMessage(ErrorMessage.executeCmdError);
      }

      List<FreeTDSExecutionResultTable> tables = [];

      while ((_returnCode = _library.dbresults(_connection)) != NO_MORE_RESULTS) {
        FreeTDSExecutionResultTable table = FreeTDSExecutionResultTable();
        tables.add(table);

        if (_returnCode == FAIL) {
          throw FreeTDSException.fromErrorMessage(ErrorMessage.getExecutionResultError);
        }

        table.affectedRows = _library.dbcount(_connection);

        _numColumns = _library.dbnumcols(_connection);
        if (_numColumns == 0) {
          continue;
        }

        _columns = calloc<SQL_COLUMN>(_numColumns);
        if (_columns == nullptr) {
          throw FreeTDSException.fromErrorMessage(ErrorMessage.outOfMemoryError);
        }

        Pointer<SQL_COLUMN> column;
        int rowCode;

        for (int columnIndex = 0; columnIndex < _numColumns; columnIndex++) {
          int c = columnIndex + 1;
          column = _columns.elementAt(columnIndex);

          column.ref.name = _library.dbcolname(_connection, c);
          column.ref.type = _library.dbcoltype(_connection, c);
          column.ref.size = _library.dbcollen(_connection, c);

          final columnName = column.ref.name != nullptr ? column.ref.name.cast<Utf8>().toDartString() : "";
          table.columns.add(columnName);

          int bindType = Connection.getBindAndUpdate(column);

          if (loggerLevel.value >= Level.trace.value && logger != null) {
            logger!(
                Level.trace,
                "TYPE > Column $columnName, type: ${column.ref.type} (${Connection.getColumnTypeName(column.ref.type)}),"
                    " bindType: $bindType (${Connection.getColumnBindName(bindType)}), info: ${json.encode(SQL_COLUMN_Dart.fromNative(column.ref))}");
          }

          Connection.bind(_library, _connection, column, c, bindType);
        }
        while ((rowCode = _library.dbnextrow(_connection)) != NO_MORE_ROWS) {
          switch (rowCode) {
            case REG_ROW:
              Map<String, dynamic> row = {};
              for (int i = 0; i < _numColumns; i++) {
                column = _columns.elementAt(i);
                final columnName = column.ref.name != nullptr ? column.ref.name.cast<Utf8>().toDartString() : "";
                dynamic value;
                if (column.ref.status.value != -1) {
                  if (loggerLevel.value >= Level.trace.value && logger != null) {
                    logger!(Level.trace, "DATA > Column $columnName, info: ${json.encode(SQL_COLUMN_Dart.fromNative(column.ref))}");
                  }

                  value = Connection.getData(_library, _connection, column);

                  if (loggerLevel.value >= Level.trace.value && logger != null) {
                    logger!(Level.trace, "DATA > Column $columnName, ${value != null ? "value: $value" : "value IS NULL"}");
                  }
                }
                row[columnName] = value;
              }
              table.data.add(row);
              break;
            case BUF_FULL:
              throw FreeTDSException.fromErrorMessage(ErrorMessage.bufferFullError);
            case FAIL:
              throw FreeTDSException.fromErrorMessage(ErrorMessage.unknownError);
            default:
          }
        }

        _cleanupAfterTable();
      }

      _executing = false;
      return tables;
    } catch (_) {
      _executing = false;
      rethrow;
    }
  }

  Future<void> disconnect() async {
    if (_queue != null) {
      await _queue!.add(() async {
        await _disconnect();
      });
    } else {
      await _disconnect();
    }
  }

  Future<void> _disconnect() async {
    lastError = null;
    _cleanupAfterConnection();
    if (_connection != nullptr) {
      _library.dbclose(_connection);
      _connection = nullptr;
    }
  }

// endregion
}
