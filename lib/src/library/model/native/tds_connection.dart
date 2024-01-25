library freetds.library.model.native;

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:freetds/src/library/model/native/alias.dart';
import 'package:freetds/src/library/model/native/tds_authentication.dart';
import 'package:freetds/src/library/model/native/tds_capabilities.dart';
import 'package:freetds/src/library/model/native/tds_context.dart';
import 'package:freetds/src/library/model/native/tds_cursor.dart';
import 'package:freetds/src/library/model/native/tds_dynamic.dart';
import 'package:freetds/src/library/model/native/tds_env.dart';
import 'package:freetds/src/library/model/native/tds_packet.dart';
import 'package:freetds/src/library/model/native/tds_poll_wake_up.dart';

base class TDSCONNECTION extends Struct {
  @Uint16()
  external int tds_version;
  @Uint32()
  external int product_version;
  external Pointer<Utf8> product_name;
  @Int32()
  external int s;
  external TDSPOLLWAKEUP wakeup;
  external Pointer<TDSCONTEXT> tds_ctx;
  external TDSENV env;
  external Pointer<TDSCURSOR> cursors;
  external Pointer<TDSDYNAMIC> dyns;
  @Int32()
  external int char_conv_count;
  external Pointer<Pointer<TDSICONV>> char_convs;
  @Array(5)
  external Array<Uint8> collation;
  @Array(8)
  external Array<Uint8> tds72_transaction;
  external TDS_CAPABILITIES capabilities;
  @Uint32()
  external int use_iconv;
  @Uint32()
  external int tds71rev1;
  @Uint32()
  external int pending_close;
  @Uint32()
  external int encrypt_single_packet;
  @Int32()
  external int list_mtx;
  @Uint32()
  external int num_cached_packets;
  external Pointer<TDSPACKET> packet_cache;
  @Int32()
  external int spid;
  @Int32()
  external int client_spid;
  external Pointer<Void> tls_session;
  external Pointer<Void> tls_ctx;
  external Pointer<TDSAUTHENTICATION> authentication;
  external Pointer<Utf8> server;
}
