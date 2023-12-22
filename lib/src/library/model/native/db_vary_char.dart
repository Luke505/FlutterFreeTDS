library freetds.library.model.native;

import 'dart:ffi';

base class DBVARYCHAR extends Struct {
  @Int16()
  external int len;
  @Array(256)
  external Array<Int8> dstr_s;
}
