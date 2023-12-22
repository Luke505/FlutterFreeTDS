library freetds.library.model.native;

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:freetds/src/library/model/native/db_numeric.dart';
import 'package:freetds/src/library/model/native/tds_iconv_info.dart';
import 'package:freetds/src/library/model/native/tds_result_info.dart';

typedef DBDECIMAL = DBNUMERIC;

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
