library freetds.query_param;

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

  QueryParam(dynamic value, {this.name, this.output = 0, this.datatype = 0, this.maxlen = 0, this.scale = 0, this.precision = 0, this.datalen = 0}) {
    if (value == null) {
      nullValue(dataType: this.datatype);
    } else if (value is String) {
      stringValue(value, dataType: this.datatype == 0 ? SYBVARCHAR : this.datatype);
    } else if (value is int) {
      stringValue(BigInt.from(value).toString(), dataType: SYBVARCHAR);
    } else if (value is double) {
      stringValue(Decimal.parse(value.toString()).toString(), dataType: SYBVARCHAR);
    } else if (value is BigInt) {
      intValue(value, dataType: this.datatype == 0 ? SYBINTN : this.datatype);
    } else if (value is Uint8List) {
      uIntValue(value, dataType: this.datatype == 0 ? SYBVARBINARY : this.datatype);
    } else {
      throw UnsupportedError("Unsupported type: ${value.runtimeType}");
    }
  }

  QueryParam.custom({this.name, this.output = 0, this.datatype = 0, this.maxlen = 0, this.scale = 0, this.precision = 0, this.datalen = 0, this.value});

  void nullValue({int dataType = 0}) {
    if (dataType == 0) {
      this.datatype = SYBVARBINARY;
    } else {
      this.datatype = dataType;
    }
    value = null;
  }

  void stringValue(String value, {int dataType = SYBVARCHAR}) {
    this.value = value.toNativeUtf8().cast();
    this.datalen = value.length;
    this.datatype = dataType;
  }

  void intValue(BigInt value, {int dataType = SYBINTN}) {
    List<int> byteArray;

    if (dataType == SYBINTN || dataType == SYBUINTN) {
      bool isUnsigned = dataType == SYBUINTN;
      byteArray = List.generate(8, (n) => (((value >> (8 * n)) & BigInt.from(0xFF)).toInt()), growable: true);

      for (int i = 7; i > 0; i--) {
        if (!isUnsigned && (byteArray[i] == 0xFF && byteArray[i - 1] & 0x80 != 0 || byteArray[i] == 0x00 && byteArray[i - 1] & 0x80 == 0)) {
          byteArray.removeLast();
        } else if (isUnsigned && byteArray[i] == 0x00) {
          byteArray.removeLast();
        } else {
          break;
        }
      }

      bool addZeros = byteArray.last & 0x80 == 0;
      while (byteArray.length < 8 && ![1, 2, 4, 8].contains(byteArray.length)) {
        byteArray.add(addZeros ? 0x00 : 0xFF);
      }

      if (byteArray.length == 1) {
        dataType = SYBINT1;
      } else if (byteArray.length == 2) {
        dataType = dataType == SYBINTN ? SYBINT2 : SYBUINT2;
      } else if (byteArray.length == 4) {
        dataType = dataType == SYBINTN ? SYBINT4 : SYBUINT4;
      } else {
        dataType = dataType == SYBINTN ? SYBINT8 : SYBUINT8;
      }
    } else {
      switch (dataType) {
        case SYBINT1:
        case SYBUINT1:
          if (dataType == SYBUINT1 && value & BigInt.from(0x80) != BigInt.from(0x80)) {
            dataType = SYBINT1;
          }
          byteArray = List<int>.filled(1, 0);
          byteArray[0] = (value & BigInt.from(0xff)).toInt();
          break;
        case SYBINT2:
        case SYBUINT2:
          int resizedValue = ((value & BigInt.from(0x7fff)) - (value & BigInt.from(0x8000))).toInt();
          byteArray = List<int>.filled(2, 0);
          byteArray[0] = resizedValue & 0xff;
          byteArray[1] = (resizedValue >> 8) & 0xff;
          break;
        case SYBINT4:
        case SYBUINT4:
          int resizedValue = ((value & BigInt.from(0x7fffffff)) - (value & BigInt.from(0x80000000))).toInt();
          byteArray = List<int>.filled(4, 0);
          byteArray[0] = resizedValue & 0xff;
          byteArray[1] = (resizedValue >> 8) & 0xff;
          byteArray[2] = (resizedValue >> 16) & 0xff;
          byteArray[3] = (resizedValue >> 24) & 0xff;
          break;
        case SYBINT8:
        case SYBUINT8:
          byteArray = List.generate(8, (n) => (((value >> (8 * n)) & BigInt.from(0xFF)).toInt()), growable: true);
          break;
        default:
          throw ArgumentError("Invalid dataType");
      }
    }

    switch (dataType) {
      case SYBINT1:
      case SYBUINT1:
        this.datalen = 1;
        break;
      case SYBINT2:
      case SYBUINT2:
        this.datalen = 2;
        break;
      case SYBINT4:
      case SYBUINT4:
        this.datalen = 4;
        break;
      case SYBINT8:
      case SYBUINT8:
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

  void uIntValue(Uint8List value, {int dataType = SYBVARBINARY}) {
    final Pointer<Uint8> result = malloc<Uint8>(value.length);
    result.asTypedList(value.length).setAll(0, value);

    this.value = result;
    this.datalen = value.length;
    this.datatype = dataType;
  }

  @override
  String toString() => 'QueryParam{name: $name, output: $output, datatype: $datatype, maxlen: $maxlen, scale: $scale,'
      ' precision: $precision, datalen: $datalen, value: $value}';

  Map<String, dynamic> toJson() =>
      {"name": name, "output": output, "datatype": datatype, "maxlen": maxlen,
      "scale": scale,
      "precision": precision,
      "datalen": datalen,
      "value": value?.asTypedList(datalen)
    };
}