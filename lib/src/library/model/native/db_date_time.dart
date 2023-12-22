library freetds.library.model.native;

import 'dart:ffi';

base class DBDATETIME extends Struct {
  @Int32()
  external int dtdays;
  @Int32()
  external int dttime;
}
