library freetds.library.model.native;

import 'dart:ffi';

base class TDS_CAPABILITY_TYPE extends Struct {
  @Uint8()
  external int type;

  @Uint8()
  external int len;

  @Array(14)
  external Array<Uint8> values;
}
