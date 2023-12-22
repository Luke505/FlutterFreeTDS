library freetds.library.model.native;

import 'dart:ffi';

base class DBTYPEINFO extends Struct {
  @Int32()
  external int precision;
  @Int32()
  external int scale;
}
