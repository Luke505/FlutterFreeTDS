library freetds.library.model.native;

import 'dart:ffi';

base class DBMONEY4 extends Struct {
  @Int32()
  external int mny4;
}
