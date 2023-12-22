library freetds.library.model.native;

import 'dart:ffi';

import 'package:ffi/ffi.dart';

base class TDSLOCALE extends Struct {
  external Pointer<Utf8> language;
  external Pointer<Utf8> server_charset;
  external Pointer<Utf8> date_fmt;
}
