library freetds.library.model.native;

import 'dart:ffi';

import 'package:ffi/ffi.dart';

base class TDSENV extends Struct {
  @Int32()
  external int block_size;
  external Pointer<Utf8> language;
  external Pointer<Utf8> charset;
  external Pointer<Utf8> database;
}
