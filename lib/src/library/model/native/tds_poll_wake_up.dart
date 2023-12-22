library freetds.library.model.native;

import 'dart:ffi';

base class TDSPOLLWAKEUP extends Struct {
  @Int32()
  external int s_signal;
  @Int32()
  external int s_signaled;
}
