library freetds.library.model.native;

import 'dart:ffi';

import 'package:ffi/ffi.dart';

base class TDS_ENCODING extends Struct {
  external Pointer<Utf8> name;
  @Uint8()
  external int min_bytes_per_char;
  @Uint8()
  external int max_bytes_per_char;
  @Uint8()
  external int canonic;
}
