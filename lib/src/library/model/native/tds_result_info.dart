library freetds.library.model.native;

import 'dart:ffi';

import 'package:freetds/src/library/model/native/tds_column.dart';
import 'package:freetds/src/library/model/native/tds_socket.dart';

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
