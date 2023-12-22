library freetds.library.model.native;

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:freetds/src/library/model/native/tds_result_info.dart';

base class TDSCURSOR extends Struct {
  external Pointer<TDSCURSOR> next;
  @Int32()
  external int ref_count;
  external Pointer<Utf8> cursor_name;
  @Int32()
  external int cursor_id;
  @Int8()
  external int options;
  @Int8()
  external int defer_close;
  external Pointer<Utf8> query;
  @Int32()
  external int cursor_rows;
  @Int32()
  external int status;
  @Int16()
  external int srv_status;
  external Pointer<TDSRESULTINFO> res_info;
  @Int32()
  external int type;
  @Int32()
  external int concurrency;
}
