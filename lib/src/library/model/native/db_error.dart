library freetds.library.model.native;

import 'dart:ffi';

import 'package:ffi/ffi.dart';

base class DBERROR extends Struct {
  external Pointer<Utf8> dberrstr;
  @Int32()
  external int severity;
}
