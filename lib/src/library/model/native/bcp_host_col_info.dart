library freetds.library.model.native;

import 'dart:ffi';

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
