library freetds.library.model.native;

import 'dart:ffi';

base class DBDATETIMEALL extends Struct {
  @Uint16()
  external int time;
  @Int32()
  external int date;
  @Int16()
  external int offset;
  @Uint16()
  external int time_prec;
  @Uint16()
  external int res;
  @Uint16()
  external int has_time;
  @Uint16()
  external int has_date;
  @Uint16()
  external int has_offset;
}
