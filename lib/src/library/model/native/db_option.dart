library freetds.library.model.native;

import 'dart:ffi';

import 'package:freetds/src/library/model/native/alias.dart';
import 'package:freetds/src/library/model/native/db_string.dart';

base class DBOPTION extends Struct {
  external Pointer<TDS_CHAR> text;
  external Pointer<DBSTRING> param;
  @Int8()
  external int factive;
}
