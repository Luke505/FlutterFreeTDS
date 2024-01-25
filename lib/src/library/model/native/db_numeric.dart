library freetds.library.model.native;

import 'dart:ffi';

base class DBNUMERIC extends Struct {
  @Uint8()
  external int precision;
  @Uint8()
  external int scale;
  @Array(33)
  external Array<Uint8> array;
}
