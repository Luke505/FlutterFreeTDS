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

  /*void intValue(int? value, {int dataType = 0}) {
    if (value == null) {
      nullValue(dataType: dataType);
      return;
    }

    List<int> byteArray;

    if (dataType == 0 || dataType == SYBINTN) {
      byteArray = List.generate(8, (n) => (value >> (8 * n)) & 0xFF, growable: true);

      for (int i = 7; i > 0; i--) {
        if (byteArray[i] == 0xFF && byteArray[i - 1] & 0x80 != 0
            || byteArray[i] == 0x00 && byteArray[i - 1] & 0x80 == 0) {
          byteArray.removeLast();
        } else {
          break;
        }
      }

      if (byteArray.length == 1) {
        dataType = SYBINT1;
      } else if (byteArray.length == 2) {
        dataType = SYBINT2;
      } else if (byteArray.length <= 4) {
        bool addZeros = byteArray.last & 0x80 == 0;
        while (byteArray.length < 4) {
          byteArray.add(addZeros ? 0x00 : 0xFF);
        }

        dataType = SYBINT4;
      } else {
        bool addZeros = byteArray.last & 0x80 == 0;
        while (byteArray.length < 8) {
          byteArray.add(addZeros ? 0x00 : 0xFF);
        }

        dataType = SYBINT8;
      }
    } else {
      switch (dataType) {
        case SYBINT1:
          int resizedValue = (value & 0x7f) - (value & 0x80);
          byteArray = List<int>.filled(1, 0);
          byteArray[0] = resizedValue & 0xff;
          break;
        case SYBINT2:
          int resizedValue = (value & 0x7fff) - (value & 0x8000);
          byteArray = List<int>.filled(4, 0);
          byteArray[0] = resizedValue & 0xff;
          byteArray[1] = (resizedValue >> 8) & 0xff;
          break;
        case SYBINT4:
          int resizedValue = (value & 0x7fffffff) - (value & 0x80000000);
          byteArray = List<int>.filled(4, 0);
          byteArray[0] = resizedValue & 0xff;
          byteArray[1] = (resizedValue >> 8) & 0xff;
          byteArray[2] = (resizedValue >> 16) & 0xff;
          byteArray[3] = (resizedValue >> 24) & 0xff;
          break;
        case SYBINT8:
          byteArray = Int64(value).toBytes();
          break;
        default:
          throw ArgumentError("Invalid dataType");
      }
    }

    switch (dataType) {
      case SYBINT1:
        this.datalen = 1;
        break;
      case SYBINT2:
        this.datalen = 2;
        break;
      case SYBINT4:
        this.datalen = 4;
        break;
      case SYBINT8:
        this.datalen = 8;
        break;
      default:
        throw ArgumentError("Invalid dataType");
    }

    final Pointer<Uint8> result = malloc<Uint8>(byteArray.length);
    final Uint8List array = result.asTypedList(byteArray.length);
    for (int i = 0; i < array.length; i++) {
      array[i] = byteArray[i];
    }

    this.value = result;
    this.datatype = dataType;
  }

  void decimalValue(double? value) {
    if (value == null) {
      nullValue(dataType: SYBVARCHAR);
      return;
    }
    stringValue(Decimal.parse(value.toString()).toString());
    this.datatype = SYBVARCHAR;
  }*/

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