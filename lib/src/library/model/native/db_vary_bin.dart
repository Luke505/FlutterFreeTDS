library freetds.library.model.native;

import 'dart:ffi';

base class DBVARYBIN extends Struct {
  @Int16()
  external int len;
  @Array(256)
  external Array<Uint8> dstr_s;
}
