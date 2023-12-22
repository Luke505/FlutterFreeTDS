library freetds.library.model.native;

import 'dart:ffi';

import 'package:freetds/src/library/model/native/alias.dart';
import 'package:freetds/src/library/model/native/bcp_host_col_info.dart';

base class BCP_HOSTFILEINFO extends Struct {
  external Pointer<TDS_CHAR> hostfile;
  external Pointer<TDS_CHAR> errorfile;
  external Pointer bcp_errfileptr;
  @Int32()
  external int host_colcount;
  external Pointer<Pointer<BCP_HOSTCOLINFO>> host_columns;
  @Int32()
  external int firstrow;
  @Int32()
  external int lastrow;
  @Int32()
  external int maxerrs;
  @Int32()
  external int batch;
}
