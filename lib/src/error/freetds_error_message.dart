library freetds.error_message;

enum FreeTDSErrorMessage {
  initError("Attempting to initialize failed."),
  connectionError("Attempting to connect failed."),
  sendCmdError("Attempting to send command failed."),
  executeCmdError("Attempting to execute last command failed."),
  getExecutionResultError("Attempting to get last command result failed."),
  outOfMemoryError("Attempting to allocate memory space failed."),
  bindResultColumnError("Attempting to bind result column failed."),
  bindNullColumnError("Attempting to bind null column failed."),
  databaseUseError("Attempting to use specified schema failed."),
  pendingConnectionError("Attempting to connect while a connection is active."),
  noConnectionError("Attempting to execute while not connected."),
  pendingExecutionError("Attempting to execute while a command is in progress."),
  rowIgnoreMessage("Ignoring unknown row type"),
  bufferFullError("Buffer Full"),
  unknownError("Unknown Error");

  final String message;

  const FreeTDSErrorMessage(this.message);

  @override
  String toString() => this.message;

  String toJson() => this.message;

  FreeTDSErrorMessage fromJson(String value) => FreeTDSErrorMessage.values.firstWhere((it) => it.message == value);
}