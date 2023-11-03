library freetds.error;

class FreeTDSError {
  final String error;
  final int code;
  final int severity;

  const FreeTDSError(this.error, this.code, this.severity);

  @override
  String toString() {
    return 'FreeTDSError{error: $error, code: $code, severity: $severity}';
  }

  Map<String, dynamic> toJson() => {
        "error": this.error,
        "code": this.code,
        "severity": this.severity,
      };
}