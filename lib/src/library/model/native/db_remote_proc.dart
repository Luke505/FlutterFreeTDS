library freetds.library.model.native;

import 'dart:ffi';

import 'package:freetds/src/library/model/native/db_remote_proc_param.dart';

base class DBREMOTE_PROC extends Struct {
  external Pointer<DBREMOTE_PROC> next;
  external Pointer<Void> name;
  @Int16()
  external int options;
  external Pointer<DBREMOTE_PROC_PARAM> param_list;
}
