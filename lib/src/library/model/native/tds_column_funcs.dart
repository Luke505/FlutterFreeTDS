library freetds.library.model.native;

import 'dart:ffi';

import 'package:freetds/src/library/model/native/tds_column.dart';
import 'package:freetds/src/library/model/native/tds_socket.dart';

base class TDSCOLUMNFUNCS extends Struct {
  external Pointer<NativeFunction<TDS_FUNC_GET_INFO>> get_info;
  external Pointer<NativeFunction<TDS_FUNC_GET_DATA>> get_data;
  external Pointer<NativeFunction<TDS_FUNC_ROW_LEN>> row_len;
  external Pointer<NativeFunction<TDS_FUNC_PUT_INFO>> put_info;
  external Pointer<NativeFunction<TDS_FUNC_PUT_DATA>> put_data;
}

typedef TDS_FUNC_GET_INFO = int Function(Pointer<TDSSOCKET> tds, Pointer<TDSCOLUMN> col);
typedef TDS_FUNC_GET_DATA = int Function(Pointer<TDSSOCKET> tds, Pointer<TDSCOLUMN> col);
typedef TDS_FUNC_ROW_LEN = int Function(Pointer<TDSCOLUMN> col);
typedef TDS_FUNC_PUT_INFO = int Function(Pointer<TDSSOCKET> tds, Pointer<TDSCOLUMN> col);
typedef TDS_FUNC_PUT_DATA = int Function(Pointer<TDSSOCKET> tds, Pointer<TDSCOLUMN> col, int bcp7);
