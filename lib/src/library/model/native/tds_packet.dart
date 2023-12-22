library freetds.library.model.native;

import 'dart:ffi';

base class TDSPACKET extends Struct {
  external Pointer<TDSPACKET> next;
  @Uint16()
  external int sid;
  @Uint32()
  external int data_len;
  @Uint32()
  external int capacity;
  @Uint8()
  external int buf;
}
