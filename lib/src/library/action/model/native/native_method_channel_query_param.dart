library freetds.query_param;

import "dart:convert";

import "package:freetds/src/query_param.dart";

class NativeMethodChannelQueryParam {
  String? name;
  dynamic value;

  NativeMethodChannelQueryParam(this.value, {this.name});

  NativeMethodChannelQueryParam.fromQueryParam(QueryParam param) {
    this.name = param.name;
    this.value = param.value;
  }

  @override
  String toString() => "NativeMethodChannelQueryParam{name: $name, value: $value}";

  Map<String, dynamic> toJson() => {"name": this.name, "value": this.value};
}
