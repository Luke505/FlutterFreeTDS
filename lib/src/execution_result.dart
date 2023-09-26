library freetds.execution_result;

import 'dart:convert';

class FreeTDSExecutionResultTable {
  int affectedRows = 0;
  List<String> columns = [];
  List<Map<String, dynamic>> data = [];

  @override
  String toString() {
    return 'FreeTDSExecutionResultTable{affectedRows: $affectedRows, columns: $columns, data: $data}';
  }

  Map<String, dynamic> toJson() {
    return {
      "affectedRows": affectedRows,
      "columns": json.encode(columns),
      "data": json.encode(data),
    };
  }
}