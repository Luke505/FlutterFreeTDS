library freetds.library.model.native;

import 'dart:ffi';

base class DBREMOTE_PROC_PARAM extends Struct {
  external Pointer<DBREMOTE_PROC_PARAM> next;
  external Pointer<Void> name;
  @Uint8()
  external int status;
  @Int32()
  external int type;
  @Int64()
  external int maxlen;
  @Int64()
  external int datalen;
  external Pointer<Uint8> value;
}
