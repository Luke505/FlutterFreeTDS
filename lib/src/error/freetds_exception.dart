library freetds.exception;

import 'package:freetds/src/communication/freetds_error.dart';
import 'package:freetds/src/error/freetds_error_message.dart';

class FreeTDSException implements Exception {
  final String message;

  const FreeTDSException(this.message);

  FreeTDSException.fromErrorMessage(FreeTDSErrorMessage errorMessage) : message = errorMessage.message;

  FreeTDSException.fromFreeTDSError(FreeTDSError error) : message = error.error;

  @override
  String toString() => 'FreeTDSException{message: $message}';

  Map<String, dynamic> toJson() => {
        "message": this.message,
      };
}