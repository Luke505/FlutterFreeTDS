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
import 'package:queue/queue.dart' show Queue;

class FreeTDS {
  static const int defaultTimeout = 5;
  static const int defaultMaxTextSize = 4096;

  int timeout = defaultTimeout;
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

  late Library _library;

  static FreeTDSError? lastError;

  static StreamController<FreeTDSError>? errorStream;
  static StreamController<FreeTDSMessage>? messageStream;

  static FreeTDS get instance => _instance ??= FreeTDS._internal();

  FreeTDS._internal() {
    if (Platform.isMacOS || Platform.isIOS || Platform.isWindows) {
      _library = Library();
    } else {
      throw UnsupportedError('FreeTDS is only supported on macOS, iOS and windows.');
    }

    if (_library.dbinit() == FAIL) {
      throw StateError('FreeTDS db init failed.');
    }

    lastError = null;
    setQueue(true);
    setErrorStream(false);
    setMessageStream(false);
    _library.dbmsghandle(Pointer.fromFunction<mhandlefunc_Native>(_handleMessage, TDS_SUCCESS));
    _library.dberrhandle(Pointer.fromFunction<ehandlefunc_Native>(_handleError, CANCEL));
  }

  FreeTDS._test(String libraryPath, bool queue) {
    if (Platform.isMacOS || Platform.isIOS || Platform.isWindows) {
      _library = Library.test(libraryPath);
    } else {
      throw UnsupportedError('FreeTDS is only supported on macOS, iOS and windows.');
    }

    if (_library.dbinit() == FAIL) {
      throw StateError('FreeTDS db init failed.');
    }

    lastError = null;
    setQueue(queue);
    setErrorStream(true);
    setMessageStream(true);

    _library.dbmsghandle(Pointer.fromFunction<mhandlefunc_Native>(_handleMessage, TDS_SUCCESS));
    _library.dberrhandle(Pointer.fromFunction<ehandlefunc_Native>(_handleError, CANCEL));
  }

  @visibleForTesting
  static FreeTDS initTest(String libraryPath, bool queue) {
    _instance = FreeTDS._test(libraryPath, queue);
    return _instance!;
  }

  @visibleForTesting
  Library get library => this._library;

  @visibleForTesting
  Pointer<DBPROCESS> get connection => this._connection;

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

  static Future<void> setMessageStream(bool enable) async {
    if (enable) {
      if (messageStream == null) {
        messageStream = StreamController.broadcast();
      }
    } else if (messageStream != null) {
      try {
        if (!messageStream!.isClosed) {
          await messageStream!.close();
        }
      } catch (_) {}
      messageStream = null;
    }
  }

  bool isConnected() {
    return _library.dbdead(_connection) == 0;
  }

  bool isExecuting() {
    return _executing;
  }

  // region Handler

  // Handles message callback from FreeTDS library.
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

  // Handles error callback from FreeTDS library.
  static int _handleError(Pointer<DBPROCESS> dbproc, int severity, int dberr, int oserr, Pointer<Utf8> dberrstr, Pointer<Utf8> oserrstr) {
    if (oserrstr == nullptr) return CANCEL;

    try {
      var error = FreeTDSError(dberrstr.toDartString(), severity);
      _storeError(error);
    } catch (_) {}

    return CANCEL;
  }

  static void _storeError(FreeTDSError error) {
    lastError = error;
    if (errorStream != null && !errorStream!.isClosed) {
      errorStream!.add(error);
    }
  }

  // endregion

  // region Cleanup

  void _cleanupAfterTable() {
    if (_columns != nullptr) {
      Pointer<SQL_COLUMN> column;
      for (int i = 0; i < _numColumns; i++) {
        try {
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
        } catch (_) {
          break;
        }
      }
      calloc.free(_columns);
      _columns = nullptr;
    }
  }

  void _cleanupAfterExecution() {
    _cleanupAfterTable();
    if (_connection != nullptr) {
      try {
        _library.dbfreebuf(_connection);
      } catch (_) {}
    }
  }

  void _cleanupAfterConnection() {
    _cleanupAfterExecution();
    if (_login != nullptr) {
      try {
        _library.dbloginfree(_login);
      } catch (_) {}
      _login = nullptr;
    }
  }

  // endregion

  // region Action

  Future<void> connect(
      {required String host,
      required String username,
      required String password,
      String? database,
      SYBEncryptionLevel? encryption,
      String? charset = "utf8",
      String? lang,
      String? appName,
      int? version = DBVERSION_100}) async {
    assert(host.isNotEmpty);
    assert(username.isNotEmpty);
    assert(password.isNotEmpty);

    if (_queue != null) {
      await _queue!.add(() async {
        await _connect(
          host: host,
          username: username,
          password: password,
          database: database,
          encryption: encryption,
          charset: charset,
          lang: lang,
          appName: appName,
          version: version,
        );
      });
    } else {
      await _connect(
        host: host,
        username: username,
        password: password,
        database: database,
        encryption: encryption,
        charset: charset,
        lang: lang,
        appName: appName,
        version: version,
      );
    }
  }

  Future<void> _connect(
      {required String host,
      required String username,
      required String password,
      String? database,
      SYBEncryptionLevel? encryption,
      String? charset,
      String? lang,
      String? appName,
      int? version}) async {
    lastError = null;

    if (isConnected()) {
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.pendingConnectionError);
    }

    _login = _library.dblogin();
    if (_login == nullptr) {
      _cleanupAfterConnection();
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
    }

    if (_library.dbsetlname(_login, host.toNativeUtf8(), DBSETHOST) == 0) {
      _cleanupAfterConnection();
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
    }
    if (_library.dbsetlname(_login, username.toNativeUtf8(), DBSETUSER) == 0) {
      _cleanupAfterConnection();
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
    }
    if (_library.dbsetlname(_login, password.toNativeUtf8(), DBSETPWD) == 0) {
      _cleanupAfterConnection();
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
    }

    if (encryption != null) {
      if (_library.dbsetlname(_login, encryption.value.toNativeUtf8(), DBSETENCRYPTION) == 0) {
        _cleanupAfterConnection();
        throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
      }
    }

    if (charset != null) {
      if (_library.dbsetlname(_login, charset.toNativeUtf8(), DBSETCHARSET) == 0) {
        _cleanupAfterConnection();
        throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
      }
    }

    if (lang != null) {
      if (_library.dbsetlname(_login, lang.toNativeUtf8(), DBSETNATLANG) == 0) {
        _cleanupAfterConnection();
        throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
      }
    }

    if (appName != null) {
      if (_library.dbsetlname(_login, appName.toNativeUtf8(), DBSETAPP) == 0) {
        _cleanupAfterConnection();
        throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
      }
    }

    if (version != null) {
      if (_library.dbsetlversion(_login, version) == 0) {
        _cleanupAfterConnection();
        throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
      }
    }

    _library.dbsetlogintime(timeout);

    _connection = _library.dbopen(_login, host.toNativeUtf8());
    if (_connection == nullptr) {
      _cleanupAfterConnection();
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.connectionError);
    }

    if (database != null) {
      _returnCode = _library.dbuse(_connection, database.toNativeUtf8());
      if (_returnCode == FAIL) {
        _cleanupAfterConnection();
        throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.databaseUseError);
      }
    }

    _cleanupAfterConnection();
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
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.noConnectionError);
    }
    if (isExecuting()) {
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.pendingExecutionError);
    }
    _executing = true;
    try {
      _library.dbsettime(timeout);
      if (lastError != null) {
        throw FreeTDSException.fromFreeTDSError(lastError!);
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
          queryParam.ref.value = params[i].getValue(_library, _connection) ?? nullptr;

          if (lastQueryParam == nullptr) {
            queryParams = queryParam;
          } else {
            lastQueryParam.ref.next = queryParam;
          }

          if (loggerLevel.value >= Level.trace.value && logger != null) {
            logger!(
                Level.trace,
                "PARAMETER > Column ${params[i].name ?? (i + 1)}, type: ${queryParam.ref.datatype} (${Connection.getColumnTypeName(queryParam.ref.datatype)}),"
                " datalen: ${queryParam.ref.datalen}, value: ${params[i].getValue(_library, _connection)?.asTypedList(queryParam.ref.datalen)}");
          }

          lastQueryParam = queryParam;
        }
      }

      Pointer<Utf8> sqlUtf8 = sql.toNativeUtf8();
      _returnCode = _library.dbsqlexecparams(_connection, sqlUtf8, queryParams);
      if (_returnCode == FAIL) {
        throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.executeCmdError);
      }
      if (lastError != null) {
        throw FreeTDSException.fromFreeTDSError(lastError!);
      }

      List<FreeTDSExecutionResultTable> tables = [];

      while ((_returnCode = _library.dbresults(_connection)) != NO_MORE_RESULTS) {
        if (lastError != null) {
          throw FreeTDSException.fromFreeTDSError(lastError!);
        }

        FreeTDSExecutionResultTable table = FreeTDSExecutionResultTable();
        tables.add(table);

        if (_returnCode == FAIL) {
          throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.getExecutionResultError);
        }

        table.affectedRows = _library.dbcount(_connection);

        _numColumns = _library.dbnumcols(_connection);
        if (_numColumns == 0) {
          continue;
        }

        _columns = calloc<SQL_COLUMN>(_numColumns);
        if (_columns == nullptr) {
          throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.outOfMemoryError);
        }

        Pointer<SQL_COLUMN> column;
        int rowCode;

        if (lastError != null) {
          throw FreeTDSException.fromFreeTDSError(lastError!);
        }

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
                " bindType: $bindType (${Connection.getColumnBindName(bindType)}), info: ${json.encode(SQLColumn.fromNative(column.ref))}");
          }

          Connection.bind(_library, _connection, column, c, bindType);

          if (lastError != null) {
            throw FreeTDSException.fromFreeTDSError(lastError!);
          }
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
                    logger!(Level.trace, "DATA > Column $columnName, info: ${json.encode(SQLColumn.fromNative(column.ref))}");
                  }

                  value = Connection.getData(_library, _connection, column, i);

                  if (lastError != null) {
                    throw FreeTDSException.fromFreeTDSError(lastError!);
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

      if (lastError != null) {
        throw FreeTDSException.fromFreeTDSError(lastError!);
      }

      _cleanupAfterExecution();
      _executing = false;
      return tables;
    } catch (_) {
      _cleanupAfterExecution();
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
