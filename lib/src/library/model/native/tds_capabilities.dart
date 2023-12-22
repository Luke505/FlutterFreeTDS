library freetds.library.model.native;

import 'dart:ffi';

import 'package:freetds/src/library/model/native/tds_capability_type.dart';

base class TDS_CAPABILITIES extends Struct {
  @Array(2)
  external Array<TDS_CAPABILITY_TYPE> types;
}
