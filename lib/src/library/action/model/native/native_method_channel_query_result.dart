library freetds.query_param;

import "dart:convert";

class NativeMethodChannelQueryResult {
  int affectedRows = 0;
  List<String> columns = [];
  String data;

  NativeMethodChannelQueryResult({int? affectedRows, List<String>? columns, required this.data}) {
    this.affectedRows = affectedRows ?? 0;
    this.columns = columns ?? [];
  }

  @override
  String toString() => "NativeMethodChannelQueryResult{affectedRows: $affectedRows, columns: $columns, data: $data}";

  Map<String, dynamic> toJson() => {"affectedRows": this.affectedRows, "columns": jsonEncode(this.columns), "data": this.data};
}
