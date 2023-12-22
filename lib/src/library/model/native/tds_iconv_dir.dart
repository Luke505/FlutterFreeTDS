library freetds.library.model.native;

import 'dart:ffi';

import 'package:freetds/src/library/model/native/tds_encoding.dart';

base class TDSICONVDIR extends Struct {
  external TDS_ENCODING charset;
  external Pointer<Void> cd;
}
