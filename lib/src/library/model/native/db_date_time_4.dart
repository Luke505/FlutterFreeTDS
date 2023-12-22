library freetds.library.model.native;

import 'dart:ffi';

base class DBDATETIME4 extends Struct {
  @Uint16()
  external int days;
  @Uint16()
  external int minutes;
}
