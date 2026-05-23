library freetds.library.action;

import "dart:convert";
import "dart:ffi";

import "package:ffi/ffi.dart";
import "package:freetds/freetds.dart";
import "package:freetds/src/library/action/context/library_action_context.dart";
import "package:freetds/src/library/action/model/library/library_query_param.dart";
import "package:freetds/src/library/model/model.dart";
import "package:freetds/src/utils/connection_utils.dart";
import "package:logger/logger.dart";

class LibraryAction {
  static Pointer<SQL_COLUMN> _columns = nullptr;
  static int _numColumns = 0;

  // region Cleanup

  static void _cleanupAfterTable() {
    if (_columns != nullptr) {
      Pointer<SQL_COLUMN> column;
      for (int i = 0; i < _numColumns; i++) {
        try {
          column = _columns + (i);
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

  static void _cleanupAfterExecution({required LibraryActionContext context}) {
    _cleanupAfterTable();
    if (context.connection != nullptr) {
      try {
        context.library.dbfreebuf(context.connection);
      } catch (_) {}
    }
  }

  static void _cleanupAfterConnection({required LibraryActionContext context}) {
    _cleanupAfterExecution(context: context);
    if (context.login != nullptr) {
      try {
        context.library.dbloginfree(context.login);
      } catch (_) {}
      context.login = nullptr;
    }
  }

  // endregion

  static Future<void> connect({
    required LibraryActionContext context,
    required String host,
    required String username,
    required String password,
    String? database,
    SYBEncryptionLevel? encryption,
    String? charset = "utf8",
    String? lang,
    String? appName,
    int? version = DBVERSION_100,
  }) async {
    context.library.dbgetlasterror().ref.dberrstr = nullptr;
    context.library.dbgetlasterror().ref.severity = -1;

    if (await isConnected(context)) {
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.pendingConnectionError);
    }

    context.login = context.library.dblogin();
    if (context.login == nullptr) {
      _cleanupAfterConnection(context: context);
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
    }

    if (context.library.dbsetlname(context.login, host.toNativeUtf8(), DBSETHOST) == 0) {
      _cleanupAfterConnection(context: context);
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
    }
    if (context.library.dbsetlname(context.login, username.toNativeUtf8(), DBSETUSER) == 0) {
      _cleanupAfterConnection(context: context);
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
    }
    if (context.library.dbsetlname(context.login, password.toNativeUtf8(), DBSETPWD) == 0) {
      _cleanupAfterConnection(context: context);
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
    }

    if (encryption != null) {
      if (context.library.dbsetlname(context.login, encryption.value.toNativeUtf8(), DBSETENCRYPTION) == 0) {
        _cleanupAfterConnection(context: context);
        throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
      }
    }

    if (charset != null) {
      if (context.library.dbsetlname(context.login, charset.toNativeUtf8(), DBSETCHARSET) == 0) {
        _cleanupAfterConnection(context: context);
        throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
      }
    }

    if (lang != null) {
      if (context.library.dbsetlname(context.login, lang.toNativeUtf8(), DBSETNATLANG) == 0) {
        _cleanupAfterConnection(context: context);
        throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
      }
    }

    if (appName != null) {
      if (context.library.dbsetlname(context.login, appName.toNativeUtf8(), DBSETAPP) == 0) {
        _cleanupAfterConnection(context: context);
        throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
      }
    }

    if (version != null) {
      if (context.library.dbsetlversion(context.login, version) == 0) {
        _cleanupAfterConnection(context: context);
        throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.initError);
      }
    }

    context.library.dbsetlogintime(context.timeout);

    context.connection = context.library.dbopen(context.login, host.toNativeUtf8());
    if (context.connection == nullptr) {
      _cleanupAfterConnection(context: context);
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.connectionError);
    }

    if (database != null) {
      int returnCode = context.library.dbuse(context.connection, database.toNativeUtf8());
      if (returnCode == FAIL) {
        _cleanupAfterConnection(context: context);
        throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.databaseUseError);
      }
    }

    _cleanupAfterConnection(context: context);
  }

  static Future<bool> isConnected(LibraryActionContext context) async => context.library.dbdead(context.connection) == 0;

  static Future<List<FreeTDSExecutionResultTable>> query({required LibraryActionContext context, required String sql, List<LibraryQueryParam>? params}) async {
    context.library.dbgetlasterror().ref.dberrstr = nullptr;
    context.library.dbgetlasterror().ref.severity = -1;

    try {
      context.library.dbsettime(context.timeout);
      Pointer<DBERROR> lastError = context.library.dbgetlasterror();
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
          queryParam.ref.value = params[i].getValue(context.library, context.connection) ?? nullptr;

          if (lastQueryParam == nullptr) {
            queryParams = queryParam;
          } else {
            lastQueryParam.ref.next = queryParam;
          }

          if (context.loggerLevel.value >= Level.trace.value && context.logger != null) {
            context.logger!(
              Level.trace,
              "PARAMETER > Column ${params[i].name ?? (i + 1)}, type: ${queryParam.ref.datatype} (${Connection.getColumnTypeName(queryParam.ref.datatype)}),"
              " datalen: ${queryParam.ref.datalen}, value: ${params[i].getValue(context.library, context.connection)?.asTypedList(queryParam.ref.datalen)}",
            );
          }

          lastQueryParam = queryParam;
        }
      }

      Pointer<Utf8> sqlUtf8 = sql.toNativeUtf8();
      int returnCode = context.library.dbsqlexecparams(context.connection, sqlUtf8, queryParams);
      if (returnCode == FAIL) {
        throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.executeCmdError);
      }
      lastError = context.library.dbgetlasterror();
      if (lastError != nullptr && lastError.ref.dberrstr != nullptr) {
        throw FreeTDSException.fromFreeTDSError(FreeTDSError.fromDBError(lastError.ref));
      }

      List<FreeTDSExecutionResultTable> tables = [];

      while ((returnCode = context.library.dbresults(context.connection)) != NO_MORE_RESULTS) {
        lastError = context.library.dbgetlasterror();
        if (lastError != nullptr && lastError.ref.dberrstr != nullptr) {
          throw FreeTDSException.fromFreeTDSError(FreeTDSError.fromDBError(lastError.ref));
        }

        FreeTDSExecutionResultTable table = FreeTDSExecutionResultTable();
        tables.add(table);

        if (returnCode == FAIL) {
          throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.getExecutionResultError);
        }

        table.affectedRows = context.library.dbcount(context.connection);

        _numColumns = context.library.dbnumcols(context.connection);
        if (_numColumns == 0) {
          continue;
        }

        _columns = calloc<SQL_COLUMN>(_numColumns);
        if (_columns == nullptr) {
          throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.outOfMemoryError);
        }

        Pointer<SQL_COLUMN> column;
        int rowCode;

        lastError = context.library.dbgetlasterror();
        if (lastError != nullptr && lastError.ref.dberrstr != nullptr) {
          throw FreeTDSException.fromFreeTDSError(FreeTDSError.fromDBError(lastError.ref));
        }

        for (int columnIndex = 0; columnIndex < _numColumns; columnIndex++) {
          int c = columnIndex + 1;
          column = _columns + (columnIndex);
          column.ref.name = context.library.dbcolname(context.connection, c);
          column.ref.type = context.library.dbcoltype(context.connection, c);
          column.ref.size = context.library.dbcollen(context.connection, c);

          final columnName = column.ref.name != nullptr ? column.ref.name.cast<Utf8>().toDartString() : "";
          table.columns.add(columnName);

          int bindType = Connection.getBindAndUpdate(column);

          if (context.loggerLevel.value >= Level.trace.value && context.logger != null) {
            context.logger!(
              Level.trace,
              "TYPE > Column $columnName, type: ${column.ref.type} (${Connection.getColumnTypeName(column.ref.type)}),"
              " bindType: $bindType (${Connection.getColumnBindName(bindType)}), info: ${json.encode(SQLColumn.fromNative(column.ref))}",
            );
          }

          Connection.bind(context.library, context.connection, column, c, bindType);

          lastError = context.library.dbgetlasterror();
          if (lastError != nullptr && lastError.ref.dberrstr != nullptr) {
            throw FreeTDSException.fromFreeTDSError(FreeTDSError.fromDBError(lastError.ref));
          }
        }
        while ((rowCode = context.library.dbnextrow(context.connection)) != NO_MORE_ROWS) {
          switch (rowCode) {
            case REG_ROW:
              Map<String, dynamic> row = {};
              for (int i = 0; i < _numColumns; i++) {
                column = _columns + (i);
                final columnName = column.ref.name != nullptr ? column.ref.name.cast<Utf8>().toDartString() : "";
                dynamic value;
                if (column.ref.status.value != -1) {
                  if (context.loggerLevel.value >= Level.trace.value && context.logger != null) {
                    context.logger!(Level.trace, "DATA > Column $columnName, info: ${json.encode(SQLColumn.fromNative(column.ref))}");
                  }

                  value = Connection.getData(context.library, context.connection, column, i);

                  lastError = context.library.dbgetlasterror();
                  if (lastError != nullptr && lastError.ref.dberrstr != nullptr) {
                    throw FreeTDSException.fromFreeTDSError(FreeTDSError.fromDBError(lastError.ref));
                  }

                  if (context.loggerLevel.value >= Level.trace.value && context.logger != null) {
                    context.logger!(Level.trace, "DATA > Column $columnName, ${value != null ? "value: $value" : "value IS NULL"}");
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

      lastError = context.library.dbgetlasterror();
      if (lastError != nullptr && lastError.ref.dberrstr != nullptr) {
        throw FreeTDSException.fromFreeTDSError(FreeTDSError.fromDBError(lastError.ref));
      }

      _cleanupAfterExecution(context: context);
      return tables;
    } catch (_) {
      _cleanupAfterExecution(context: context);
      rethrow;
    }
  }

  static Future<void> disconnect({required LibraryActionContext context}) async {
    context.library.dbgetlasterror().ref.dberrstr = nullptr;
    context.library.dbgetlasterror().ref.severity = -1;
    _cleanupAfterConnection(context: context);
    if (context.connection != nullptr) {
      context.library.dbclose(context.connection);
      context.connection = nullptr;
    }
  }

  static Future<void> close({required LibraryActionContext context}) async {
    context.library.dbexit();
  }
}
