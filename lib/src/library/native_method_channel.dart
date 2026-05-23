library freetds.library;

import "dart:convert";
import "dart:io";

import "package:flutter/services.dart";
import "package:freetds/freetds.dart";
import "package:freetds/src/library/action/model/native/native_method_channel_query_param.dart";

class NativeMethodChannel {
  late MethodChannel _methodChannel;

  NativeMethodChannel() {
    if (Platform.isAndroid) {
      _methodChannel = MethodChannel("freetds");
    } else {
      throw UnsupportedError("FreeTDS is only supported on macOS, iOS and windows.");
    }
  }

  Future<void> connect({
    required int timeout,
    required String host,
    required String username,
    required String password,
    String? database, //
  }) async => await _methodChannel.invokeMethod("connect", {"timeout": timeout, "host": host, "user": username, "password": password, "database": database});

  Future<bool> isConnected({required int timeout}) async => await _methodChannel.invokeMethod("isConnected", {"timeout": timeout});

  Future<List<FreeTDSExecutionResultTable>> query({
    required String sql,
    List<NativeMethodChannelQueryParam>? params, //
  }) async {
    Map<dynamic, dynamic> nativeMethodResult = await _methodChannel.invokeMethod("query", {"sql": sql, "params": jsonEncode(params)});

    final result = FreeTDSExecutionResultTable(
      affectedRows: nativeMethodResult["affectedRows"]! as int,
      columns: (nativeMethodResult["columns"]! as List<dynamic>).map((c) => c as String).toList(),
      data: (jsonDecode(nativeMethodResult["data"]! as String) as List<dynamic>).map((r) => r as Map<String, dynamic>).toList(), //
    );

    return List.of([result], growable: false);
  }

  Future<void> disconnect() async => await _methodChannel.invokeMethod("disconnect");
}
