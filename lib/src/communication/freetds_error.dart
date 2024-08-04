library freetds.error;

import 'package:ffi/ffi.dart';
import 'package:freetds/src/library/model/native/db_error.dart';

class FreeTDSError {
  final String error;
  final int severity;

  const FreeTDSError(this.error, this.severity);

  FreeTDSError.fromDBError(DBERROR dbError) :
        error = dbError.dberrstr.toDartString(),
        severity = dbError.severity;

  @override
  String toString() => 'FreeTDSError{error: $error, severity: $severity}';

  Map<String, dynamic> toJson() => {
        "error": this.error,
        "severity": this.severity,
      };
}