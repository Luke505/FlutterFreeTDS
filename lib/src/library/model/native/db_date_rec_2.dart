library freetds.library.model.native;

import 'dart:ffi';

base class DBDATEREC2 extends Struct {
  @Int32()
  external int dateyear;
  @Int32()
  external int quarter;
  @Int32()
  external int datemonth;
  @Int32()
  external int datedmonth;
  @Int32()
  external int datedyear;
  @Int32()
  external int week;
  @Int32()
  external int datedweek;
  @Int32()
  external int datehour;
  @Int32()
  external int dateminute;
  @Int32()
  external int datesecond;
  @Int32()
  external int datensecond;
  @Int32()
  external int datetzone;
}
