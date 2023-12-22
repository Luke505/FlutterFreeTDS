library freetds.error;

class FreeTDSError {
  final String error;
  final int severity;

  const FreeTDSError(this.error, this.severity);

  @override
  String toString() => 'FreeTDSError{error: $error, severity: $severity}';

  Map<String, dynamic> toJson() => {
        "error": this.error,
        "severity": this.severity,
      };
}