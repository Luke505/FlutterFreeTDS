library freetds.library.model.native;

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:freetds/src/library/model/native/alias.dart';
import 'package:freetds/src/library/model/native/tds_result_info.dart';

base class TDSBCPINFO extends Struct {
  external Pointer<Utf8> hint;
  external Pointer<Void> parent;
  external Pointer<Utf8> tablename;
  external Pointer<TDS_CHAR> insert_stmt;
  @Int32()
  external int direction;
  @Int32()
  external int identity_insert_on;
  @Int32()
  external int xfer_init;
  @Int32()
  external int bind_count;
  external Pointer<TDSRESULTINFO> bindinfo;
}
