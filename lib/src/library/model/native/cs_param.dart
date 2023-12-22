library freetds.library.model.native;

import 'dart:ffi';

import 'package:ffi/ffi.dart';

base class CS_PARAM extends Struct {
  external Pointer<CS_PARAM> next;
  external Pointer<Utf8> name;
  @Int32()
  external int status;
  @Int32()
  external int datatype;
  @Int32()
  external int maxlen;
  @Int32()
  external int scale;
  @Int32()
  external int precision;
  external Pointer<Int32> datalen;
  external Pointer<Int16> ind;
  external Pointer<Uint8> value;
  @Int32()
  external int param_by_value;
  @Int32()
  external int datalen_value;
  @Int16()
  external int indicator_value;
}
