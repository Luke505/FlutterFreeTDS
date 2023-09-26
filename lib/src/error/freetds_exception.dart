library freetds.exception;

import 'error_message.dart';

class FreeTDSException implements Exception {
  final String message;

  const FreeTDSException(this.message);

  FreeTDSException.fromErrorMessage(ErrorMessage errorMessage)
      : message = errorMessage.message;

  @override
  String toString() {
    return 'FreeTDSException{message: $message}';
  }
}