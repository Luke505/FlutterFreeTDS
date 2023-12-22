library freetds.library.model.native;

import 'dart:ffi';

base class DBMONEY extends Struct {
  @Int32()
  external int mnyhigh;
  @Uint32()
  external int mnylow;
}
