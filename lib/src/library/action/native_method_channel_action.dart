library freetds.library.action;

import "package:freetds/freetds.dart";
import "package:freetds/src/library/action/context/native_method_channel_action_context.dart";
import "package:freetds/src/library/action/model/native/native_method_channel_query_param.dart";

class NativeMethodChannelAction {
  static Future<void> connect({
    required NativeMethodChannelActionContext context,
    required String host,
    required String username,
    required String password,
    String? database, //
  }) async => context.nativeMethodChannel.connect(
    timeout: context.timeout,
    host: host,
    username: username,
    password: password,
    database: database, //
  );

  static Future<bool> isConnected(NativeMethodChannelActionContext context) async => context.nativeMethodChannel.isConnected(timeout: context.timeout);

  static Future<List<FreeTDSExecutionResultTable>> query({required NativeMethodChannelActionContext context, required String sql, List<NativeMethodChannelQueryParam>? params}) async =>
      context.nativeMethodChannel.query(sql: sql, params: params);

  static Future<void> disconnect({required NativeMethodChannelActionContext context}) async => context.nativeMethodChannel.disconnect();

  static Future<void> close({required NativeMethodChannelActionContext context}) async {}
}
