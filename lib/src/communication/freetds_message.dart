library freetds.message;

class FreeTDSMessage {
  final String message;
  final int severity;

  const FreeTDSMessage(this.message, this.severity);

  @override
  String toString() => 'FreeTDSMessage{message: $message, severity: $severity}';

  Map<String, dynamic> toJson() => {
        "message": this.message,
        "severity": this.severity,
      };
}
