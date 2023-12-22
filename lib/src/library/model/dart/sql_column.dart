library freetds.library.model.dart;

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:freetds/src/library/model/native/sql_column.dart';
import 'package:freetds/src/utils/connection_utils.dart';

class SQLColumn {
  late String? name;
  late int type;
  late String? typeName;
  late int size;
  late int? status;
  late dynamic data;

  SQLColumn.fromNative(SQL_COLUMN column) {
    if (column.name != nullptr) {
      name = column.name.toDartString();
    } else {
      name = null;
    }
    type = column.type;
    typeName = Connection.getColumnTypeName(column.type);
    size = column.size;
    if (column.data != nullptr) {
      status = column.status.value;
    } else {
      status = null;
    }
    if (column.data != nullptr) {
      data = column.data.asTypedList(column.size);
    } else {
      data = null;
    }
  }

  @override
  String toString() => 'SQLColumn{name: $name, type: $type, typeName: $typeName, size: $size, status: $status, data: $data}';

  Map<String, dynamic> toJson() => {"name": name, "type": type, "typeName": typeName, "size": size, "status": status, "data": data};
}
