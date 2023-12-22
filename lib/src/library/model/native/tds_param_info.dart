library freetds.library.model.native;

import 'dart:ffi';

import 'package:freetds/src/library/model/native/tds_column.dart';
import 'package:freetds/src/library/model/native/tds_socket.dart';

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
