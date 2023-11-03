library freetds.execution_result;

import 'dart:convert';

class FreeTDSExecutionResultTable {
  int affectedRows = 0;
  List<String> columns = [];
  List<Map<String, dynamic>> data = [];

  FreeTDSExecutionResultTable({int? affectedRows, List<String>? columns, List<Map<String, dynamic>>? data}) {
    this.affectedRows = affectedRows ?? 0;
    this.columns = columns ?? [];
    this.data = data ?? [];
  }

  @override
  String toString() {
    return 'FreeTDSExecutionResultTable{affectedRows: $affectedRows, columns: $columns, data: $data}';
  }

  Map<String, dynamic> toJson() => {
        "affectedRows": this.affectedRows,
        "columns": jsonEncode(this.columns),
        "data": jsonEncode(this.data),
      };
}
