library freetds.query_param;

import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:ffi/ffi.dart';
import 'package:freetds/src/constants.dart';

class QueryParam {
  String? name;
  int output = 0;
  int datatype = 0;
  int maxlen = 0;
  int scale = 0;
  int precision = 0;
  int datalen = 0;
  Pointer<Uint8>? value;

  QueryParam(dynamic value, {this.name, this.output = 0, this.datatype = 0, this.maxlen = 0, this.precision = 0, this.datalen = 0}) {
    if (value == null) {
      nullValue(dataType: this.datatype);
    } else if (value is double) {
      stringValue(Decimal.parse(value.toString()).toString(), dataType: SYBVARCHAR);
    } else if (value is int) {
      stringValue(BigInt.from(value).toString(), dataType: SYBVARCHAR);
    } else {
      stringValue(value, dataType: this.datatype == 0 ? SYBVARCHAR : this.datatype);
    }
  }

  QueryParam.custom({this.name, this.output = 0, this.datatype = 0, this.maxlen = 0, this.scale = 0,
    this.precision = 0, this.datalen = 0, this.value});

  void nullValue({int dataType = 0}) {
    if (dataType == 0) {
      this.datatype = SYBVARBINARY;
    } else {
      this.datatype = dataType;
    }
    value = null;
  }

  void stringValue(String? value, {int dataType = 0}) {
    if (value == null) {
      nullValue(dataType: dataType);
      return;
    }
    final units = utf8.encode(value);
    final Pointer<Uint8> result = malloc<Uint8>(units.length + 1);
    final Uint8List nativeString = result.asTypedList(units.length + 1);
    nativeString.setAll(0, units);
    nativeString[units.length] = 0;
    this.value = result;
    this.datalen = value.length;
    if (dataType != 0) {
      this.datatype = dataType;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "output": output,
      "datatype": datatype,
      "maxlen": maxlen,
      "scale": scale,
      "precision": precision,
      "datalen": datalen,
      "value": value?.asTypedList(datalen)
    };
  }
}