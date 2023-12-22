library freetds.library.model.native;

import 'dart:ffi';

import 'package:freetds/src/library/model/native/tds_login.dart';

base class LOGINREC extends Struct {
  external Pointer<TDSLOGIN> tds_login;
  @Int8()
  external int network_auth;
}
