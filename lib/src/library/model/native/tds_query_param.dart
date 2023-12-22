library freetds.library.model.native;

import 'dart:ffi';

import 'package:ffi/ffi.dart';

base class TDSQUERYPARAM extends Struct {
  external Pointer<TDSQUERYPARAM> next;
  external Pointer<Utf8> name;
  @Int32()
  external int output;
  @Int32()
  external int datatype;
  @Int32()
  external int maxlen;
  @Int32()
  external int scale;
  @Int32()
  external int precision;
  @Int32()
  external int datalen;
  external Pointer<Uint8> value;
}
