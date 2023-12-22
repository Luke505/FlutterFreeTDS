library freetds.library.model.native;

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:freetds/src/library/model/native/alias.dart';
import 'package:freetds/src/library/model/native/bcp_col_data.dart';
import 'package:freetds/src/library/model/native/tds_column_funcs.dart';

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
