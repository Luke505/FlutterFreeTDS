library freetds.library.model.native;

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:freetds/src/library/model/native/tds_param_info.dart';

base class TDSDYNAMIC extends Struct {
  external Pointer<TDSDYNAMIC> next;
  @Int32()
  external int ref_count;
  @Int32()
  external int num_id;
  @Array(30)
  external Array<Uint8> id;
  @Int8()
  external int emulated;
  @Int8()
  external int defer_close;
  external Pointer<TDSPARAMINFO> res_info;
  external Pointer<TDSPARAMINFO> params;
  external Pointer<Utf8> query;
}
