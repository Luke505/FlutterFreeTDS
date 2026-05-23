library freetds.library.action.context;

import "package:freetds/src/library/native_method_channel.dart";
import "package:logger/logger.dart";

class NativeMethodChannelActionContext {
  NativeMethodChannel nativeMethodChannel;
  int timeout;
  Level loggerLevel;
  Function(Level, String)? logger;

  NativeMethodChannelActionContext({
    required this.nativeMethodChannel,
    required this.timeout,
    required this.loggerLevel,
    required this.logger, //
  });
}
