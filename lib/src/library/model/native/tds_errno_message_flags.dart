library freetds.library.model.native;

import 'dart:ffi';

base class TDS_ERRNO_MESSAGE_FLAGS extends Struct {
  @Uint32()
  external int e2big;
  @Uint32()
  external int eilseq;
  @Uint32()
  external int einval;
}
