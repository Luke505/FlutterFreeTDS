library freetds.library.model.native;

import 'dart:ffi';

base class DSTR extends Struct {
  @IntPtr()
  external int dstr_size;
  @Array(1)
  external Array<Uint8> dstr_s;
}
