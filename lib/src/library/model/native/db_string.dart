library freetds.library.model.native;

import 'dart:ffi';

base class DBSTRING extends Struct {
  external Pointer<Uint8> strtext;
  @Int32()
  external int strtotlen;
  external Pointer<DBSTRING> strnext;
}
