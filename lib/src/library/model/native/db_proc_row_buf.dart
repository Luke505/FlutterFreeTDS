library freetds.library.model.native;

import 'dart:ffi';

base class DBPROC_ROWBUF extends Struct {
  @Int32()
  external int received;
  @Int32()
  external int head;
  @Int32()
  external int tail;
  @Int32()
  external int current;
  @Int32()
  external int capacity;
  external Pointer<Void> rows;
}
