library freetds.library.model.native;

import 'dart:ffi';

import 'package:freetds/src/library/model/native/tds_errno_message_flags.dart';
import 'package:freetds/src/library/model/native/tds_iconv_dir.dart';

base class TDSICONVINFO extends Struct {
  external TDSICONVDIR to;
  external TDSICONVDIR from;
  @Uint32()
  external int flags;
  external TDS_ERRNO_MESSAGE_FLAGS suppress;
}
