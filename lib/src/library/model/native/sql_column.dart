library freetds.library.model.native;

import 'dart:ffi';

import 'package:ffi/ffi.dart';

base class SQL_COLUMN extends Struct {
  external Pointer<Utf8> name;
  @Int32()
  external int type;
  @Int32()
  external int size;
  external Pointer<Int32> status;
  external Pointer<Uint8> data;
}
