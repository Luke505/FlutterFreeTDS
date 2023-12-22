library freetds.library.model.native;

import 'dart:ffi';

import 'package:freetds/src/library/model/native/tds_locale.dart';

base class TDSCONTEXT extends Struct {
  external Pointer<TDSLOCALE> locale;
  external Pointer<Void> parent;
  @Int32()
  external int money_use_2_digits;
}
