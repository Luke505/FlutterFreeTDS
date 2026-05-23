library freetds.freetds;

import "dart:async";
import "dart:ffi";
import "dart:io" show Platform;

import "package:ffi/ffi.dart";
import "package:flutter/foundation.dart";
import "package:freetds/src/communication/freetds_error.dart";
import "package:freetds/src/communication/freetds_message.dart";
import "package:freetds/src/constants.dart";
import "package:freetds/src/error/freetds_error_message.dart";
import "package:freetds/src/error/freetds_exception.dart";
import "package:freetds/src/execution_result.dart";
import "package:freetds/src/library/action/context/library_action_context.dart";
import "package:freetds/src/library/action/context/native_method_channel_action_context.dart";
import "package:freetds/src/library/action/library_action.dart";
import "package:freetds/src/library/action/model/library/library_query_param.dart";
import "package:freetds/src/library/action/model/native/native_method_channel_query_param.dart";
import "package:freetds/src/library/action/native_method_channel_action.dart";
import "package:freetds/src/library/library.dart";
import "package:freetds/src/library/model/functions.dart";
import "package:freetds/src/library/model/model.dart";
import "package:freetds/src/library/native_method_channel.dart";
import "package:freetds/src/query_param.dart";
import "package:logger/logger.dart";

class FreeTDS {
  static const int defaultTimeout = 5;
  static const int defaultMaxTextSize = 4096;

  static int timeout = defaultTimeout;
  static int maxTextSize = defaultMaxTextSize;

  static Pointer<LOGINREC> _login = nullptr;
  static Pointer<DBPROCESS> _connection = nullptr;

  static Level loggerLevel = Level.trace;
  static Function(Level, String)? logger;

  static Library? _library;
  static NativeMethodChannel? _nativeMethodChannel;

  static StreamController<FreeTDSError>? errorStream;
  static StreamController<FreeTDSMessage>? messageStream;

  static Future<void> open() async {
    if (Platform.isMacOS || Platform.isIOS || Platform.isWindows) {
      _library = Library();

      if (_library!.dbinit() == FAIL) {
        throw StateError("FreeTDS db init failed.");
      }

      _library!.dbgetlasterror().ref.dberrstr = nullptr;
      await closeErrorStream();
      await closeMessageStream();
      await setMessageHandler(nullptr);
      await setErrorHandler(nullptr);
    } else if (Platform.isAndroid) {
      _nativeMethodChannel = NativeMethodChannel();
    } else {
      throw UnsupportedError("FreeTDS is only supported on macOS, iOS and windows.");
    }
  }

  static Future<void> setMessageHandler(Pointer<NativeFunction<mhandlefunc_Native>> handler) async {
    _library!.dbmsghandle(handler);
  }

  static Future<void> setErrorHandler(Pointer<NativeFunction<ehandlefunc_Native>> handler) async {
    _library!.dberrhandle(handler);
  }

  static Future<void> openErrorStream() async {
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

  static bool isInitialized() => _library != null || _nativeMethodChannel != null;

  static Future<bool> isConnected() async {
    if (!isInitialized()) {
      return false;
    }

    if (_library != null) {
      return await LibraryAction.isConnected(
        LibraryActionContext(
          library: _library!,
          login: _login,
          timeout: timeout,
          connection: _connection,
          loggerLevel: loggerLevel,
          logger: logger, //
        ),
      );
    } else if (_nativeMethodChannel != null) {
      return await NativeMethodChannelAction.isConnected(
        NativeMethodChannelActionContext(
          nativeMethodChannel: _nativeMethodChannel!,
          timeout: timeout,
          loggerLevel: loggerLevel,
          logger: logger, //
        ),
      );
    } else {
      return false;
    }
  }

  // region Test

  @visibleForTesting
  static Future<void> openForTest(String? libraryPath) async {
    if (Platform.isMacOS || Platform.isIOS || Platform.isWindows) {
      _library = Library(libraryPath);

      if (_library!.dbinit() == FAIL) {
        throw StateError("FreeTDS db init failed.");
      }

      _library!.dbgetlasterror().ref.dberrstr = nullptr;
      _library!.dbgetlasterror().ref.severity = -1;
      await openErrorStream();
      openMessageStream();
      await setMessageHandler(Pointer.fromFunction<mhandlefunc_Native>(_handleMessage, TDS_SUCCESS));
      await setErrorHandler(Pointer.fromFunction<ehandlefunc_Native>(_handleError, CANCEL));
    } else if (Platform.isAndroid) {
      _nativeMethodChannel = NativeMethodChannel();
    } else {
      throw UnsupportedError("FreeTDS is only supported on macOS, iOS and windows.");
    }
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

  // region Action

  static Future<void> connect({
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
    assert(host.isNotEmpty);
    assert(username.isNotEmpty);
    assert(password.isNotEmpty);

    if (_library != null) {
      var context = LibraryActionContext(
        library: _library!,
        login: _login,
        timeout: timeout,
        connection: _connection,
        loggerLevel: loggerLevel,
        logger: logger, //
      );

      await LibraryAction.connect(
        context: context,
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

      _connection = context.connection;
      _login = context.login;
    } else if (_nativeMethodChannel != null) {
      var context = NativeMethodChannelActionContext(
        nativeMethodChannel: _nativeMethodChannel!,
        timeout: timeout,
        loggerLevel: loggerLevel,
        logger: logger, //
      );

      await NativeMethodChannelAction.connect(
        context: context,
        host: host,
        username: username,
        password: password,
        database: database, //
      );
    } else {
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.notInitializedError);
    }
  }

  static Future<List<FreeTDSExecutionResultTable>> query(String sql, [List<QueryParam>? params]) async {
    assert(sql.isNotEmpty);

    if (!await FreeTDS.isConnected()) {
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.noConnectionError);
    }

    List<FreeTDSExecutionResultTable> result;

    if (_library != null) {
      var context = LibraryActionContext(
        library: _library!,
        login: _login,
        timeout: timeout,
        connection: _connection,
        loggerLevel: loggerLevel,
        logger: logger, //
      );

      result = await LibraryAction.query(context: context, sql: sql, params: params?.map((param) => LibraryQueryParam.fromQueryParam(param)).toList());

      _connection = context.connection;
      _login = context.login;
    } else if (_nativeMethodChannel != null) {
      var context = NativeMethodChannelActionContext(
        nativeMethodChannel: _nativeMethodChannel!,
        timeout: timeout,
        loggerLevel: loggerLevel,
        logger: logger, //
      );

      result = await NativeMethodChannelAction.query(context: context, sql: sql, params: params?.map((param) => NativeMethodChannelQueryParam.fromQueryParam(param)).toList());
    } else {
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.notInitializedError);
    }

    return result;
  }

  static Future<List<FreeTDSExecutionResultTable>> libraryQuery(String sql, [List<LibraryQueryParam>? params]) async {
    assert(sql.isNotEmpty);

    if (!await FreeTDS.isConnected()) {
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.noConnectionError);
    }

    List<FreeTDSExecutionResultTable> result;

    if (_library != null) {
      var context = LibraryActionContext(
        library: _library!,
        login: _login,
        timeout: timeout,
        connection: _connection,
        loggerLevel: loggerLevel,
        logger: logger, //
      );

      result = await LibraryAction.query(context: context, sql: sql, params: params);

      _connection = context.connection;
      _login = context.login;
    } else {
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.notInitializedError);
    }

    return result;
  }

  static Future<void> disconnect() async {
    if (_library != null) {
      var context = LibraryActionContext(
        library: _library!,
        login: _login,
        timeout: timeout,
        connection: _connection,
        loggerLevel: loggerLevel,
        logger: logger, //
      );

      await LibraryAction.disconnect(context: context);

      _connection = context.connection;
      _login = context.login;
    } else if (_nativeMethodChannel != null) {
      var context = NativeMethodChannelActionContext(
        nativeMethodChannel: _nativeMethodChannel!,
        timeout: timeout,
        loggerLevel: loggerLevel,
        logger: logger, //
      );

      await NativeMethodChannelAction.disconnect(context: context);
    } else {
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.notInitializedError);
    }
  }

  static Future<void> close() async {
    await FreeTDS.disconnect();

    if (_library != null) {
      var context = LibraryActionContext(
        library: _library!,
        login: _login,
        timeout: timeout,
        connection: _connection,
        loggerLevel: loggerLevel,
        logger: logger, //
      );

      await LibraryAction.close(context: context);

      _connection = context.connection;
      _login = context.login;
    } else if (_nativeMethodChannel != null) {
      var context = NativeMethodChannelActionContext(
        nativeMethodChannel: _nativeMethodChannel!,
        timeout: timeout,
        loggerLevel: loggerLevel,
        logger: logger, //
      );

      await NativeMethodChannelAction.close(context: context);
    } else {
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.notInitializedError);
    }

    await FreeTDS.closeErrorStream();
    await FreeTDS.closeMessageStream();
  }

  // endregion
}
