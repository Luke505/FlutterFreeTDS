library freetds.library.model.native;

import 'dart:ffi';

base class NULLREP extends Struct {
  external Pointer<Void> bindval;
  @IntPtr()
  external int len;
}
