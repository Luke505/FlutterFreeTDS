library freetds.library.model.native;

import 'dart:ffi';

base class TDSAUTHENTICATION extends Struct {
  external Pointer<Uint8> packet;
  @Int32()
  external int packet_len;
  @Uint16()
  external int msg_type;
}
