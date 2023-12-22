library freetds.library.model.native;

import 'dart:ffi';

import 'package:freetds/src/library/model/native/alias.dart';
import 'package:freetds/src/library/model/native/tds_connection.dart';
import 'package:freetds/src/library/model/native/tds_cursor.dart';
import 'package:freetds/src/library/model/native/tds_dynamic.dart';
import 'package:freetds/src/library/model/native/tds_login.dart';
import 'package:freetds/src/library/model/native/tds_packet.dart';
import 'package:freetds/src/library/model/native/tds_param_info.dart';
import 'package:freetds/src/library/model/native/tds_result_info.dart';

base class TDSSOCKET extends Struct {
  external Pointer<TDSCONNECTION> conn;
  external Pointer parent;
  external Pointer<Uint8> in_buf;
  external Pointer<Uint8> out_buf;
  @Uint32()
  external int out_buf_max;
  @Uint32()
  external int in_pos;
  @Uint32()
  external int out_pos;
  @Uint32()
  external int in_len;
  @Uint8()
  external int in_flag;
  @Uint8()
  external int out_flag;
  @Uint32()
  external int frozen;
  external Pointer<TDSPACKET> frozen_packets;
  external Pointer<TDSPACKET> recv_packet;
  external Pointer<TDSPACKET> send_packet;
  external Pointer<TDSRESULTINFO> current_results;
  external Pointer<TDSRESULTINFO> res_info;
  @Uint32()
  external int num_comp_info;
  external Pointer<Pointer<TDSCOMPUTEINFO>> comp_info;
  external Pointer<TDSPARAMINFO> param_info;
  external Pointer<TDSCURSOR> cur_cursor;
  @Uint8()
  external int bulk_query;
  @Uint8()
  external int has_status;
  @Uint8()
  external int in_row;
  @Uint8()
  external int in_cancel;
  @Int32()
  external int ret_status;
  @Int32()
  external int state;
  @Int32()
  external int query_timeout;
  @Int64()
  external int rows_affected;
  external Pointer<TDSDYNAMIC> cur_dyn;
  external Pointer<TDSLOGIN> login;
  @Int32()
  external int current_op;
  @Int32()
  external int option_value;
  external Pointer wire_mtx;
}
