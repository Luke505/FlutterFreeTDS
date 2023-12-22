library freetds.library.model.native;

import 'dart:ffi';

import 'package:freetds/src/constants.dart';
import 'package:freetds/src/library/model/native/bcp_host_file_info.dart';
import 'package:freetds/src/library/model/native/db_option.dart';
import 'package:freetds/src/library/model/native/db_proc_row_buf.dart';
import 'package:freetds/src/library/model/native/db_remote_proc.dart';
import 'package:freetds/src/library/model/native/db_string.dart';
import 'package:freetds/src/library/model/native/db_type_info.dart';
import 'package:freetds/src/library/model/native/null_rep.dart';
import 'package:freetds/src/library/model/native/tds_bcp_info.dart';
import 'package:freetds/src/library/model/native/tds_socket.dart';

base class DBPROCESS extends Struct {
  external Pointer<TDSSOCKET> tds_socket;
  @Uint8()
  external int row_type;
  external DBPROC_ROWBUF row_buf;
  @Int8()
  external int noautofree;
  @Int8()
  external int more_results;
  @Int32()
  external int dbresults_state;
  @Int32()
  external int dbresults_retcode;
  external Pointer<Void> user_data;
  external Pointer<Uint8> dbbuf;
  @Int32()
  external int dbbufsz;
  @Int32()
  external int command_state;
  @Int32()
  external int text_size;
  @Int32()
  external int text_sent;
  external DBTYPEINFO typeinfo;
  @Uint8()
  external int avail_flag;
  external Pointer<DBOPTION> dbopts;
  external Pointer<DBSTRING> dboptcmd;
  external Pointer<BCP_HOSTFILEINFO> hostfileinfo;
  external Pointer<TDSBCPINFO> bcpinfo;
  external Pointer<DBREMOTE_PROC> rpc;
  @Int16()
  external int envchange_rcv;
  @Array(DBMAXNAME + 1)
  external Array<Int8> dbcurdb;
  @Array(DBMAXNAME + 1)
  external Array<Int8> servcharset;
  external Pointer ftos;
  external Pointer<NativeFunction<Void Function()>> chkintr;
  external Pointer<NativeFunction<Void Function()>> hndlintr;
  @Int8()
  external int msdblib;
  @Int32()
  external int ntimeouts;
  @Array(MAXBINDTYPES)
  external Array<NULLREP> nullreps;
}
