library freetds.library;

import 'dart:ffi';
import 'dart:io' show Platform;

import 'package:ffi/ffi.dart';

import 'constants.dart';
import 'utils/connection_utils.dart';

/// SQLClient

base class DBSTRING extends Struct {
  external Pointer<Uint8> strtext;
  @Int32()
  external int strtotlen;
  external Pointer<DBSTRING> strnext;
}

base class DBTYPEINFO extends Struct {
  @Int32()
  external int precision;
  @Int32()
  external int scale;
}

base class DBVARYCHAR extends Struct {
  @Int16()
  external int len;
  @Array(256)
  external Array<Int8> dstr_s;
}

base class DBVARYBIN extends Struct {
  @Int16()
  external int len;
  @Array(256)
  external Array<Uint8> dstr_s;
}

base class DBNUMERIC extends Struct {
  @Uint8()
  external int precision;
  @Uint8()
  external int scale;
  @Uint8()
  external int len;
  @Array(33)
  external Array<Uint8> array;
}
typedef DBDECIMAL = DBNUMERIC;

base class DBMONEY extends Struct {
  @Int32()
  external int mnyhigh;
  @Uint32()
  external int mnylow;
}

base class DBMONEY4 extends Struct {
  @Int32()
  external int mny4;
}

base class DBDATETIME extends Struct {
  @Int32()
  external int dtdays;
  @Int32()
  external int dttime;
}

base class DBDATETIME4 extends Struct {
  @Uint16()
  external int days;
  @Uint16()
  external int minutes;
}

base class DBDATETIMEALL extends Struct {
  @Uint16()
  external int time;
  @Int32()
  external int date;
  @Int16()
  external int offset;
  @Uint16()
  external int time_prec;
  @Uint16()
  external int res;
  @Uint16()
  external int has_time;
  @Uint16()
  external int has_date;
  @Uint16()
  external int has_offset;
}

/// Sybase

base class DBDATEREC extends Struct {
  @Int32()
  external int dateyear;
  @Int32()
  external int quarter;
  @Int32()
  external int datemonth;
  @Int32()
  external int datedmonth;
  @Int32()
  external int datedyear;
  @Int32()
  external int week;
  @Int32()
  external int datedweek;
  @Int32()
  external int datehour;
  @Int32()
  external int dateminute;
  @Int32()
  external int datesecond;
  @Int32()
  external int datemsecond;
  @Int32()
  external int datetzone;
}

base class DBDATEREC2 extends Struct {
  @Int32()
  external int dateyear;
  @Int32()
  external int quarter;
  @Int32()
  external int datemonth;
  @Int32()
  external int datedmonth;
  @Int32()
  external int datedyear;
  @Int32()
  external int week;
  @Int32()
  external int datedweek;
  @Int32()
  external int datehour;
  @Int32()
  external int dateminute;
  @Int32()
  external int datesecond;
  @Int32()
  external int datensecond;
  @Int32()
  external int datetzone;
}

/// CS

base class CS_PARAM extends Struct {
  external Pointer<CS_PARAM> next;
  external Pointer<Utf8> name;
  @Int32()
  external int status;
  @Int32()
  external int datatype;
  @Int32()
  external int maxlen;
  @Int32()
  external int scale;
  @Int32()
  external int precision;
  external Pointer<Int32> datalen;
  external Pointer<Int16> ind;
  external Pointer<Uint8> value;
  @Int32()
  external int param_by_value;
  @Int32()
  external int datalen_value;
  @Int16()
  external int indicator_value;
}

/// TDS

base class DSTR extends Struct {
  @IntPtr()
  external int dstr_size;
  @Array(1)
  external Array<Uint8> dstr_s;
}

typedef TDS_SYS_SOCKET = int;
typedef TDS_UCHAR = Uint8;
typedef TDS_USMALLINT = Uint16;
typedef TDS_UINT = Uint32;
typedef TDS_INT = Int32;
typedef TDS_LONG = Int64;
typedef TDS_INT8 = Int64;
typedef TDS_CHAR = Utf8;
typedef TDS_BOOL = Uint8;
typedef TDS_TINYINT = Uint8;
typedef TDS_SMALLINT = Int16;
typedef TDS_UINT8 = Uint64;
typedef TDS_INTPTR = IntPtr;
typedef TDS_REAL = Float;
typedef TDS_FLOAT = Double;


typedef TDSCOMPUTEINFO = TDSRESULTINFO;
typedef TDSICONV = TDSICONVINFO;

// C Struct Definitions

base class TDSPACKET extends Struct {
  external Pointer<TDSPACKET> next;
  @Uint16()
  external int sid;
  @Uint32()
  external int data_len;
  @Uint32()
  external int capacity;
  @Uint8()
  external int buf;
}


base class TDSLOCALE extends Struct {
  external Pointer<Utf8> language;
  external Pointer<Utf8> server_charset;
  external Pointer<Utf8> date_fmt;
}

base class TDSCONTEXT extends Struct {
  external Pointer<TDSLOCALE> locale;
  external Pointer<Void> parent;
  @Int32()
  external int money_use_2_digits;
}

base class TDSAUTHENTICATION extends Struct {
  external Pointer<Uint8> packet;
  @Int32()
  external int packet_len;
  @Uint16()
  external int msg_type;
}

base class TDSPOLLWAKEUP extends Struct {
  @Int32()
  external int s_signal;
  @Int32()
  external int s_signaled;
}

base class TDSCONNECTION extends Struct {
  @Uint8()
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

typedef TDS_FUNC_GET_INFO = int Function(Pointer<TDSSOCKET> tds, Pointer<TDSCOLUMN> col);
typedef TDS_FUNC_GET_DATA = int Function(Pointer<TDSSOCKET> tds, Pointer<TDSCOLUMN> col);
typedef TDS_FUNC_ROW_LEN = int Function(Pointer<TDSCOLUMN> col);
typedef TDS_FUNC_PUT_INFO = int Function(Pointer<TDSSOCKET> tds, Pointer<TDSCOLUMN> col);
typedef TDS_FUNC_PUT_DATA = int Function(Pointer<TDSSOCKET> tds, Pointer<TDSCOLUMN> col, int bcp7);

base class TDSCOLUMNFUNCS extends Struct {
  external Pointer<NativeFunction<TDS_FUNC_GET_INFO>> get_info;
  external Pointer<NativeFunction<TDS_FUNC_GET_DATA>> get_data;
  external Pointer<NativeFunction<TDS_FUNC_ROW_LEN>> row_len;
  external Pointer<NativeFunction<TDS_FUNC_PUT_INFO>> put_info;
  external Pointer<NativeFunction<TDS_FUNC_PUT_DATA>> put_data;
}

/// BCPCOLDATA struct
base class BCPCOLDATA extends Struct {
  external Pointer<TDS_UCHAR> data;
  @Int32()
  external int datalen;
  @Uint8()
  external int is_null;
}

/// TDS_ENCODING struct
base class TDS_ENCODING extends Struct {
  external Pointer<Utf8> name;
  @Uint8()
  external int min_bytes_per_char;
  @Uint8()
  external int max_bytes_per_char;
  @Uint8()
  external int canonic;
}

/// TDS_ERRNO_MESSAGE_FLAGS struct
base class TDS_ERRNO_MESSAGE_FLAGS extends Struct {
  @Uint32()
  external int e2big;
  @Uint32()
  external int eilseq;
  @Uint32()
  external int einval;
}

/// TDSICONVDIR struct
base class TDSICONVDIR extends Struct {
  external TDS_ENCODING charset;
  external Pointer<Void> cd;
}

/// tdsiconvinfo struct
base class TDSICONVINFO extends Struct {
  external TDSICONVDIR to;
  external TDSICONVDIR from;
  @Uint32()
  external int flags;
  external TDS_ERRNO_MESSAGE_FLAGS suppress;
}

base class TDSCOLUMN extends Struct {
  external Pointer<TDSCOLUMNFUNCS> funcs;
  @Int32()
  external int column_usertype;
  @Int32()
  external int column_flags;
  @Int32()
  external int column_size;

  @Uint8()
  external int column_type;
  @Int8()
  external int column_varint_size;
  @Int8()
  external int column_prec;
  @Int8()
  external int column_scale;
  @Uint8()
  external int on_server_column_type;
  @Int32()
  external int on_server_column_size;
  external Pointer<TDSICONV> char_conv;
  external Pointer<Utf8> table_name;
  external Pointer<Utf8> column_name;
  external Pointer<Utf8> table_column_name;
  external Pointer<Uint8> column_data;
  external Pointer<Void> column_data_free;
  @Uint8()
  external int column_nullable;
  @Uint8()
  external int column_writeable;
  @Uint8()
  external int column_identity;
  @Uint8()
  external int column_key;
  @Uint8()
  external int column_hidden;
  @Uint8()
  external int column_output;
  @Uint8()
  external int column_timestamp;
  @Uint8()
  external int column_computed;
  @Array(5)
  external Array<Uint8> column_collation;
  @Int16()
  external int column_operand;
  @Int8()
  external int column_operator;
  @Int32()
  external int column_cur_size;
  @Int16()
  external int column_bindtype;
  @Int16()
  external int column_bindfmt;
  @Uint32()
  external int column_bindlen;
  external Pointer<Int16> column_nullbind;
  external Pointer<Uint8> column_varaddr;
  external Pointer<Int32> column_lenbind;
  @Int32()
  external int column_textpos;
  @Int32()
  external int column_text_sqlgetdatapos;
  @Int8()
  external int column_text_sqlputdatainfo;
  @Uint8()
  external int column_iconv_left;
  @Array(9)
  external Array<Uint8> column_iconv_buf;
  external Pointer<BCPCOLDATA> bcp_column_data;
  @Int32()
  external int bcp_prefix_len;
  @Int32()
  external int bcp_term_len;
  external Pointer<Int8> bcp_terminator;
}

base class TDSRESULTINFO extends Struct {
  external Pointer<Pointer<TDSCOLUMN>> columns;
  @Uint16()
  external int num_cols;
  @Uint16()
  external int computeid;
  @Int32()
  external int ref_count;
  external Pointer<TDSSOCKET> attached_to;
  external Pointer<Uint8> current_row;
  external Pointer<Void> row_free;
  @Int32()
  external int row_size;
  external Pointer<Int16> bycolumns;
  @Uint16()
  external int by_cols;
  @Int8()
  external int rows_exist;
  @Int8()
  external int more_results;
}

base class TDSCURSOR extends Struct {
  external Pointer<TDSCURSOR> next;
  @Int32()
  external int ref_count;
  external Pointer<Utf8> cursor_name;
  @Int32()
  external int cursor_id;
  @Int8()
  external int options;
  @Int8()
  external int defer_close;
  external Pointer<Utf8> query;
  @Int32()
  external int cursor_rows;
  @Int32()
  external int status;
  @Int16()
  external int srv_status;
  external Pointer<TDSRESULTINFO> res_info;
  @Int32()
  external int type;
  @Int32()
  external int concurrency;
}

base class TDSENV extends Struct {
  @Int32()
  external int block_size;
  external Pointer<Utf8> language;
  external Pointer<Utf8> charset;
  external Pointer<Utf8> database;
}

base class TDSPARAMINFO extends Struct {
  external Pointer<Pointer<TDSCOLUMN>> columns;
  @Uint16()
  external int num_cols;
  @Uint16()
  external int computeid;
  @Int32()
  external int ref_count;
  external Pointer<TDSSOCKET> attached_to;
  external Pointer<Uint8> current_row;
  external Pointer rowFree;
  @Int32()
  external int rowSize;
  external Pointer<Int16> byColumns;
  @Uint16()
  external int byCols;
  @Int8()
  external int rowsExist;
  @Int8()
  external int moreResults;
}

base class TDSDYNAMIC extends Struct {
  external Pointer<TDSDYNAMIC> next;
  @Int32()
  external int ref_count;
  @Int32()
  external int num_id;
  @Array(30)
  external Array<Uint8> id;
  @Int8()
  external int emulated;
  @Int8()
  external int defer_close;
  external Pointer<TDSPARAMINFO> res_info;
  external Pointer<TDSPARAMINFO> params;
  external Pointer<Utf8> query;
}

base class TDSBCPINFO extends Struct {
  external Pointer<Utf8> hint;
  external Pointer<Void> parent;
  external Pointer<Utf8> tablename;
  external Pointer<TDS_CHAR> insert_stmt;
  @Int32()
  external int direction;
  @Int32()
  external int identity_insert_on;
  @Int32()
  external int xfer_init;
  @Int32()
  external int bind_count;
  external Pointer<TDSRESULTINFO> bindinfo;
}

base class TDS_CAPABILITY_TYPE extends Struct {
  @Uint8()
  external int type;

  @Uint8()
  external int len;

  @Array(14)
  external Array<Uint8> values;
}

base class TDS_CAPABILITIES extends Struct {
  @Array(2)
  external Array<TDS_CAPABILITY_TYPE> types;
}

base class TDSLOGIN extends Struct {
  external Pointer<Utf8> server_name;
  @Int32()
  external int port;
  @Uint16()
  external int tds_version;
  @Int32()
  external int block_size;
  external Pointer<Utf8> language;
  external Pointer<Utf8> server_charset;
  @Int32()
  external int connect_timeout;
  external Pointer<Utf8> client_host_name;
  external Pointer<Utf8> server_host_name;
  external Pointer<Utf8> server_realm_name;
  external Pointer<Int8> server_spn;
  external Pointer<Int8> db_filename;
  external Pointer<Int8> cafile;
  external Pointer<Int8> crlfile;
  external Pointer<Int8> openssl_ciphers;
  external Pointer<Int8> app_name;
  external Pointer<Utf8> user_name;
  external Pointer<Utf8> password;
  external Pointer<Int8> new_password;
  external Pointer<Int8> library;
  @Uint8()
  external int encryption_level;
  @Int32()
  external int query_timeout;
  external TDS_CAPABILITIES capabilities;
  external Pointer<Int8> client_charset;
  external Pointer<Int8> database;
  external Pointer<Int32> ip_addrs;
  external Pointer<Int8> instance_name;
  external Pointer<Int8> dump_file;
  @Int32()
  external int debug_flags;
  @Int32()
  external int text_size;
  external Pointer<Int8> routing_address;
  @Uint16()
  external int routing_port;
  @Uint8()
  external int option_flag2;
  @Uint32()
  external int bulk_copy;
  @Uint32()
  external int suppress_language;
  @Uint32()
  external int gssapi_use_delegation;
  @Uint32()
  external int mutual_authentication;
  @Uint32()
  external int use_ntlmv2;
  @Uint32()
  external int use_ntlmv2_specified;
  @Uint32()
  external int use_lanman;
  @Uint32()
  external int mars;
  @Uint32()
  external int use_utf16;
  @Uint32()
  external int use_new_password;
  @Uint32()
  external int valid_configuration;
  @Uint32()
  external int check_ssl_hostname;
  @Uint32()
  external int readonly_intent;
  @Uint32()
  external int enable_tls_v1;
  @Uint32()
  external int server_is_valid;
}

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

/// dblib

/// Define the struct tds_dblib_loginrec
base class LOGINREC extends Struct {
  external Pointer<TDSLOGIN> tds_login;
  @Int8()
  external int network_auth;
}

/// Define the DBPROC_ROWBUF struct
base class DBPROC_ROWBUF extends Struct {
  @Int32()
  external int received;
  @Int32()
  external int head;
  @Int32()
  external int tail;
  @Int32()
  external int current;
  @Int32()
  external int capacity;
  external Pointer<Void> rows;
}

/// Define the BCP_HOSTCOLINFO struct
base class BCP_HOSTCOLINFO extends Struct {
  @Int32()
  external int host_column;
  @Int32()
  external int datatype;
  @Int32()
  external int prefix_len;
  @Int64()
  external int column_len;
  external Pointer<Void> terminator;
  @Int32()
  external int term_len;
  @Int32()
  external int tab_colnum;
  @Int32()
  external int column_error;
}

/// Define the BCP_HOSTFILEINFO struct
base class BCP_HOSTFILEINFO extends Struct {
  external Pointer<TDS_CHAR> hostfile;
  external Pointer<TDS_CHAR> errorfile;
  external Pointer bcp_errfileptr;
  @Int32()
  external int host_colcount;
  external Pointer<Pointer<BCP_HOSTCOLINFO>> host_columns;
  @Int32()
  external int firstrow;
  @Int32()
  external int lastrow;
  @Int32()
  external int maxerrs;
  @Int32()
  external int batch;
}

/// Define the struct DBREMOTE_PROC_PARAM
base class DBREMOTE_PROC_PARAM extends Struct {
  external Pointer<DBREMOTE_PROC_PARAM> next;
  external Pointer<Void> name;
  @Uint8()
  external int status;
  @Int32()
  external int type;
  @Int64()
  external int maxlen;
  @Int64()
  external int datalen;
  external Pointer<Uint8> value;
}

/// Define the struct DBREMOTE_PROC
base class DBREMOTE_PROC extends Struct {
  external Pointer<DBREMOTE_PROC> next;
  external Pointer<Void> name;
  @Int16()
  external int options;
  external Pointer<DBREMOTE_PROC_PARAM> param_list;
}

/// Define the struct dboption
base class DBOPTION extends Struct {
  external Pointer<TDS_CHAR> text;
  external Pointer<DBSTRING> param;
  @Int8()
  external int factive;
}

/// Define the struct NULLREP
base class NULLREP extends Struct {
  external Pointer<Void> bindval;
  @IntPtr()
  external int len;
}

/// Define the struct tds_dblib_dbprocess
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

base class TDSQUERYPARAM extends Struct {
  external Pointer<TDSQUERYPARAM> next;
  external Pointer<Utf8> name;
  @Int32()
  external int output;
  @Int32()
  external int datatype;
  @Int32()
  external int maxlen;
  @Int32()
  external int scale;
  @Int32()
  external int precision;
  @Int32()
  external int datalen;
  external Pointer<Uint8> value;
}

/// sybdb

// Function pointer types for C functions
typedef dbgetuserdata_Native = Pointer<Uint8> Function(Pointer<DBPROCESS> dbproc);
typedef dbhasretstat_Native = Int32 Function(Pointer<DBPROCESS> dbproc);
typedef dbinit_Native = Int32 Function();
typedef dbiordesc_Native = Int32 Function(Pointer<DBPROCESS> dbproc);
typedef ehandlefunc_Native = Int32 Function(Pointer<DBPROCESS> dbproc, Int32 severity, Int32 dberr, Int32 oserr, Pointer<Utf8> dberrstr, Pointer<Utf8> oserrstr);
typedef dberrhandle_Native = Void Function(Pointer<NativeFunction<ehandlefunc_Native>> handler);
typedef dbexit_Native = Void Function();
typedef dbfirstrow_Native = Int32 Function(Pointer<DBPROCESS> dbproc);
typedef mhandlefunc_Native = Int32 Function(Pointer<DBPROCESS> dbproc, Int64 msgno, Int32 msgstate, Int32 severity, Pointer<Utf8> msgtext, Pointer<Utf8> srvname, Pointer<Utf8> proc, Int32 line);
typedef dbmsghandle_Native = Void Function(Pointer<NativeFunction<mhandlefunc_Native>> handler);
typedef dbname_Native = Pointer<Utf8> Function(Pointer<DBPROCESS> dbproc);
typedef status_Native = Int32 Function(Pointer<DBPROCESS> dbproc);
typedef dbnextrow_Native = Int32 Function(Pointer<DBPROCESS> dbproc);
typedef dbnullbind_Native = Int32 Function(Pointer<DBPROCESS> dbproc, Int32 column, Pointer<Int32> indicator);
typedef dbnumalts_Native = Int32 Function(Pointer<DBPROCESS> dbproc, Int32 computeid);
typedef dbnumcols_Native = Int32 Function(Pointer<DBPROCESS> dbproc);
typedef dbnumcompute_Native = Int32 Function(Pointer<DBPROCESS> dbprocess);
typedef dbnumrets_Native = Int32 Function(Pointer<DBPROCESS> dbproc);
typedef tdsdbopen_Native = Pointer<DBPROCESS> Function(Pointer<LOGINREC> login, Pointer<Utf8> server, Int32 msdblib);
typedef dbopen_Native = Pointer<DBPROCESS> Function(Pointer<LOGINREC> login, Pointer<Utf8> server);
typedef dbclose_Native = Void Function(Pointer<DBPROCESS> dbproc);
typedef dbloginfree_Native = Void Function(Pointer<LOGINREC> login);
typedef dbfreebuf_Native = Void Function(Pointer<DBPROCESS> dbproc);
typedef dbdead_Native = Uint8 Function(Pointer<DBPROCESS> dbproc);
typedef dbsetlname_Native = Int32 Function(Pointer<LOGINREC> login, Pointer<Utf8> value, Int32 which);
typedef dblogin_Native = Pointer<LOGINREC> Function();
typedef dbsetlogintime_Native = Int32 Function(Int32 seconds);
typedef dbuse_Native = Int32 Function(Pointer<DBPROCESS> dbproc, Pointer<Utf8> name);
typedef dbsqlexec_Native = Int32 Function(Pointer<DBPROCESS> dbproc);
typedef dbresults_Native = Int32 Function(Pointer<DBPROCESS> dbproc);
typedef dbcolname_Native = Pointer<Utf8> Function(Pointer<DBPROCESS> dbproc, Int32 column);
typedef dbcoltype_Native = Int32 Function(Pointer<DBPROCESS> dbproc, Int32 column);
typedef dbcollen_Native = Int32 Function(Pointer<DBPROCESS> dbproc, Int32 column);
typedef dbbind_Native = Int32 Function(Pointer<DBPROCESS> dbproc, Int32 column, Int32 vartype, Int32 varlen, Pointer<Uint8> varaddr);
typedef dbanydatecrack_Native = Int32 Function(Pointer<DBPROCESS> dbproc, Pointer<DBDATEREC2> di, Int32 type, Pointer<Void> data);
typedef dbconvert_Native = Int32 Function(Pointer<DBPROCESS> dbproc, Int32 srctype, Pointer<Uint8> src, Int32 srclen, Int32 desttype, Pointer<Uint8> dest, Int32 destlen);
typedef dbdatecrack_Native = Int32 Function(Pointer<DBPROCESS> dbproc, Pointer<DBDATEREC> di, Pointer<DBDATETIME> dt);
typedef dbsettime_Native = Int32 Function(Int32 seconds);
typedef dbcmd_Native = Int32 Function(Pointer<DBPROCESS> dbproc, Pointer<Utf8> cmdstring);
typedef dbcount_Native = Int32 Function(Pointer<DBPROCESS> dbproc);
typedef dbsqlsend_Native = Int32 Function(Pointer<DBPROCESS> dbproc);
typedef dbsqlok_Native = Int32 Function(Pointer<DBPROCESS> dbproc);
typedef dbsqlexecparams_Native = Int32 Function(Pointer<DBPROCESS> dbproc, Pointer<Utf8> query, Pointer<TDSQUERYPARAM> params);

// Dart function pointer types
typedef dbgetuserdata_Dart = Pointer<Uint8> Function(Pointer<DBPROCESS> dbproc);
typedef dbhasretstat_Dart = int Function(Pointer<DBPROCESS> dbproc);
typedef dbinit_Dart = int Function();
typedef dbiordesc_Dart = int Function(Pointer<DBPROCESS> dbproc);
typedef dberrhandle_Dart = void Function(Pointer<NativeFunction<ehandlefunc_Native>> handler);
typedef dbexit_Dart = void Function();
typedef dbfirstrow_Dart = int Function(Pointer<DBPROCESS> dbproc);
typedef dbmsghandle_Dart = void Function(Pointer<NativeFunction<mhandlefunc_Native>> handler);
typedef dbname_Dart = Pointer<Utf8> Function(Pointer<DBPROCESS> dbproc);
typedef status_Dart = int Function(Pointer<DBPROCESS> dbproc);
typedef dbnextrow_Dart = int Function(Pointer<DBPROCESS> dbproc);
typedef dbnullbind_Dart = int Function(Pointer<DBPROCESS> dbproc, int column, Pointer<Int32> indicator);
typedef dbnumalts_Dart = int Function(Pointer<DBPROCESS> dbproc, int computeid);
typedef dbnumcols_Dart = int Function(Pointer<DBPROCESS> dbproc);
typedef dbnumcompute_Dart = int Function(Pointer<DBPROCESS> dbprocess);
typedef dbnumrets_Dart = int Function(Pointer<DBPROCESS> dbproc);
typedef tdsdbopen_Dart = Pointer<DBPROCESS> Function(Pointer<LOGINREC> login, Pointer<Utf8> server, int msdblib);
typedef dbopen_Dart = Pointer<DBPROCESS> Function(Pointer<LOGINREC> login, Pointer<Utf8> server);
typedef dbclose_Dart = void Function(Pointer<DBPROCESS> dbproc);
typedef dbloginfree_Dart = void Function(Pointer<LOGINREC> login);
typedef dbfreebuf_Dart = void Function(Pointer<DBPROCESS> dbproc);
typedef dbdead_Dart = int Function(Pointer<DBPROCESS> dbproc);
typedef dbsetlname_Dart = int Function(Pointer<LOGINREC> login, Pointer<Utf8> value, int which);
typedef dblogin_Dart = Pointer<LOGINREC> Function();
typedef dbsetlogintime_Dart = int Function(int seconds);
typedef dbuse_Dart = int Function(Pointer<DBPROCESS> dbproc, Pointer<Utf8> name);
typedef dbsqlexec_Dart = int Function(Pointer<DBPROCESS> dbproc);
typedef dbresults_Dart = int Function(Pointer<DBPROCESS> dbproc);
typedef dbcolname_Dart = Pointer<Utf8> Function(Pointer<DBPROCESS> dbproc, int column);
typedef dbcoltype_Dart = int Function(Pointer<DBPROCESS> dbproc, int column);
typedef dbcollen_Dart = int Function(Pointer<DBPROCESS> dbproc, int column);
typedef dbbind_Dart = int Function(Pointer<DBPROCESS> dbproc, int column, int vartype, int varlen, Pointer<Uint8> varaddr);
typedef dbanydatecrack_Dart = int Function(Pointer<DBPROCESS> dbproc, Pointer<DBDATEREC2> di, int type, Pointer<Void> data);
typedef dbconvert_Dart = int Function(Pointer<DBPROCESS> dbproc, int srctype, Pointer<Uint8> src, int srclen, int desttype, Pointer<Uint8> dest, int destlen);
typedef dbdatecrack_Dart = int Function(Pointer<DBPROCESS> dbproc, Pointer<DBDATEREC> di, Pointer<DBDATETIME> dt);
typedef dbsettime_Dart = int Function(int seconds);
typedef dbcmd_Dart = int Function(Pointer<DBPROCESS> dbproc, Pointer<Utf8> cmdstring);
typedef dbcount_Dart = int Function(Pointer<DBPROCESS> dbproc);
typedef dbsqlsend_Dart = int Function(Pointer<DBPROCESS> dbproc);
typedef dbsqlok_Dart = int Function(Pointer<DBPROCESS> dbproc);
typedef dbsqlexecparams_Dart = int Function(Pointer<DBPROCESS> dbproc, Pointer<Utf8> query, Pointer<TDSQUERYPARAM> params);

base class SQL_COLUMN extends Struct {
  external Pointer<Utf8> name;
  @Int32()
  external int type;
  @Int32()
  external int size;
  external Pointer<Int32> status;
  external Pointer<Uint8> data;
}

class SQL_COLUMN_Dart {
  late String? name;
  late int type;
  late String? typeName;
  late int size;
  late int? status;
  late dynamic data;

  SQL_COLUMN_Dart.fromNative(SQL_COLUMN column) {
    if (column.name != nullptr) {
      name = column.name.toDartString();
    } else {
      name = null;
    }
    type = column.type;
    typeName = Connection.getColumnTypeName(column.type);
    size = column.size;
    if (column.data != nullptr) {
      status = column.status.value;
    } else {
      status = null;
    }
    if (column.data != nullptr) {
      data = column.data.asTypedList(column.size);
    } else {
      data = null;
    }
  }

  Map<String, dynamic> toJson() {
    return {"name": name, "type": type, "typeName": typeName, "size": size, "status": status, "data": data};
  }
}

class FreeTDS_library {
  late DynamicLibrary _library;

  FreeTDS_library() {
    if (Platform.isMacOS || Platform.isIOS) {
      _library = DynamicLibrary.open('FreeTDSKit.framework/FreeTDSKit');
      _loadLibraryFunctions();
    } else if (Platform.isWindows) {
      _library = DynamicLibrary.open('sybdb.dll');
      _loadLibraryFunctions();
    } else {
      throw UnsupportedError('FreeTDS is only supported on iOS and macOS.');
    }
  }

  FreeTDS_library.test(String libraryPath) {
    _library = DynamicLibrary.open(libraryPath);
    _loadLibraryFunctions();
  }

  late dbgetuserdata_Dart dbgetuserdata;
  late dbhasretstat_Dart dbhasretstat;
  late dbinit_Dart dbinit;
  late dbiordesc_Dart dbiordesc;

  late dbexit_Dart dbexit;
  late dbfirstrow_Dart dbfirstrow;

  late dberrhandle_Dart dberrhandle;
  late dbmsghandle_Dart dbmsghandle;
  late dbname_Dart dbname;
  late dbnextrow_Dart dbnextrow;
  late dbnullbind_Dart dbnullbind;
  late dbnumalts_Dart dbnumalts;
  late dbnumcols_Dart dbnumcols;
  late dbnumcompute_Dart dbnumcompute;
  late dbnumrets_Dart dbnumrets;
  late tdsdbopen_Dart tdsdbopen;
  late dbopen_Dart dbopen;
  late dbclose_Dart dbclose;
  late dbloginfree_Dart dbloginfree;
  late dbfreebuf_Dart dbfreebuf;
  late dbdead_Dart dbdead;
  late dbsetlname_Dart dbsetlname;
  late dblogin_Dart dblogin;
  late dbsetlogintime_Dart dbsetlogintime;
  late dbuse_Dart dbuse;
  late dbsqlexec_Dart dbsqlexec;
  late dbresults_Dart dbresults;
  late dbcolname_Dart dbcolname;
  late dbcoltype_Dart dbcoltype;
  late dbcollen_Dart dbcollen;
  late dbbind_Dart dbbind;
  late dbanydatecrack_Dart dbanydatecrack;
  late dbconvert_Dart dbconvert;
  late dbdatecrack_Dart dbdatecrack;
  late dbsettime_Dart dbsettime;
  late dbcmd_Dart dbcmd;
  late dbcount_Dart dbcount;
  late dbsqlsend_Dart dbsqlsend;
  late dbsqlok_Dart dbsqlok;
  late dbsqlexecparams_Dart dbsqlexecparams;

  void _loadLibraryFunctions() {
    dbgetuserdata = _library.lookupFunction<dbgetuserdata_Native, dbgetuserdata_Dart>('dbgetuserdata');
    dbhasretstat = _library.lookupFunction<dbhasretstat_Native, dbhasretstat_Dart>('dbhasretstat');
    dbinit = _library.lookupFunction<dbinit_Native, dbinit_Dart>('dbinit');
    dbiordesc = _library.lookupFunction<dbiordesc_Native, dbiordesc_Dart>('dbiordesc');
    dberrhandle = _library.lookupFunction<dberrhandle_Native, dberrhandle_Dart>('dberrhandle');
    dbexit = _library.lookupFunction<dbexit_Native, dbexit_Dart>('dbexit');
    dbfirstrow = _library.lookupFunction<dbfirstrow_Native, dbfirstrow_Dart>('dbfirstrow');
    dbmsghandle = _library.lookupFunction<dbmsghandle_Native, dbmsghandle_Dart>('dbmsghandle');
    dbname = _library.lookupFunction<dbname_Native, dbname_Dart>('dbname');
    dbnextrow = _library.lookupFunction<dbnextrow_Native, dbnextrow_Dart>('dbnextrow');
    dbnullbind = _library.lookupFunction<dbnullbind_Native, dbnullbind_Dart>('dbnullbind');
    dbnumalts = _library.lookupFunction<dbnumalts_Native, dbnumalts_Dart>('dbnumalts');
    dbnumcols = _library.lookupFunction<dbnumcols_Native, dbnumcols_Dart>('dbnumcols');
    dbnumcompute = _library.lookupFunction<dbnumcompute_Native, dbnumcompute_Dart>('dbnumcompute');
    dbnumrets = _library.lookupFunction<dbnumrets_Native, dbnumrets_Dart>('dbnumrets');
    tdsdbopen = _library.lookupFunction<tdsdbopen_Native, tdsdbopen_Dart>('tdsdbopen');
    dbopen = _library.lookupFunction<dbopen_Native, dbopen_Dart>('dbopen');
    dbclose = _library.lookupFunction<dbclose_Native, dbclose_Dart>('dbclose');
    dbloginfree = _library.lookupFunction<dbloginfree_Native, dbloginfree_Dart>('dbloginfree');
    dbfreebuf = _library.lookupFunction<dbfreebuf_Native, dbfreebuf_Dart>('dbfreebuf');
    dbdead = _library.lookupFunction<dbdead_Native, dbdead_Dart>('dbdead');
    dbsetlname = _library.lookupFunction<dbsetlname_Native, dbsetlname_Dart>('dbsetlname');
    dblogin = _library.lookupFunction<dblogin_Native, dblogin_Dart>('dblogin');
    dbsetlogintime = _library.lookupFunction<dbsetlogintime_Native, dbsetlogintime_Dart>('dbsetlogintime');
    dbuse = _library.lookupFunction<dbuse_Native, dbuse_Dart>('dbuse');
    dbsqlexec = _library.lookupFunction<dbsqlexec_Native, dbsqlexec_Dart>('dbsqlexec');
    dbresults = _library.lookupFunction<dbresults_Native, dbresults_Dart>('dbresults');
    dbcolname = _library.lookupFunction<dbcolname_Native, dbcolname_Dart>('dbcolname');
    dbcoltype = _library.lookupFunction<dbcoltype_Native, dbcoltype_Dart>('dbcoltype');
    dbcollen = _library.lookupFunction<dbcollen_Native, dbcollen_Dart>('dbcollen');
    dbbind = _library.lookupFunction<dbbind_Native, dbbind_Dart>('dbbind');
    dbanydatecrack = _library.lookupFunction<dbanydatecrack_Native, dbanydatecrack_Dart>('dbanydatecrack');
    dbconvert = _library.lookupFunction<dbconvert_Native, dbconvert_Dart>('dbconvert');
    dbdatecrack = _library.lookupFunction<dbdatecrack_Native, dbdatecrack_Dart>('dbdatecrack');
    dbsettime = _library.lookupFunction<dbsettime_Native, dbsettime_Dart>('dbsettime');
    dbcmd = _library.lookupFunction<dbcmd_Native, dbcmd_Dart>('dbcmd');
    dbcount = _library.lookupFunction<dbcount_Native, dbcount_Dart>('dbcount');
    dbsqlsend = _library.lookupFunction<dbsqlsend_Native, dbsqlsend_Dart>('dbsqlsend');
    dbsqlok = _library.lookupFunction<dbsqlok_Native, dbsqlok_Dart>('dbsqlok');
    dbsqlexecparams = _library.lookupFunction<dbsqlexecparams_Native, dbsqlexecparams_Dart>('dbsqlexecparams');
  }
}