library freetds.library.model.native;

import 'dart:ffi';

import 'package:freetds/src/library/model/native/alias.dart';

base class BCPCOLDATA extends Struct {
  external Pointer<TDS_UCHAR> data;
  @Int32()
  external int datalen;
  @Uint8()
  external int is_null;
}
