library freetds.query_param;

class QueryParam {
  String? name;
  int? datatype;
  dynamic value;

  QueryParam(this.value, {this.name, this.datatype});

  @override
  String toString() => "QueryParam{name: $name, value: $value, datatype: $datatype}";
}