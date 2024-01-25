library freetds.query_param;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:ffi/ffi.dart';
import 'package:fixnum/fixnum.dart';
import 'package:freetds/src/constants.dart';
import 'package:freetds/src/library/library.dart';
import 'package:freetds/src/library/model/model.dart';
import 'package:tempo/tempo.dart';

class QueryParam {
  String? name;
  int output = 0;
  int datatype = 0;
  int maxlen = 0;
  int? scale;
  int? precision;
  int datalen = 0;
  Pointer<Uint8>? Function(Library library, Pointer<DBPROCESS> connection)? _value;

  QueryParam(dynamic value, {this.name, this.output = 0, this.datatype = 0, this.maxlen = 0, this.scale, this.precision, this.datalen = 0}) {
    if (value == null) {
      _nullValue();
    } else if (value is String) {
      _stringValue(value);
    } else if (value is int) {
      _intValue(BigInt.from(value));
    } else if (value is BigInt) {
      _intValue(value);
    } else if (value is double) {
      _doubleValue(Decimal.parse(value.toStringAsFixed(20)));
    } else if (value is Decimal) {
      _doubleValue(value);
    } else if (value is Uint8List || value is Int8List) {
      _uInt8ListValue(value);
    } else if (value is LocalDateTime || value is LocalDate || value is LocalTime || value is OffsetDateTime) {
      _stringValue(value.toString());
    } else if (value is bool) {
      _uInt8ListValue(Uint8List.fromList([value ? 1 : 0]));
    } else {
      throw UnsupportedError("Unsupported type: ${value.runtimeType}");
    }
  }

  QueryParam.custom(
      {this.name,
      this.output = 0,
      this.datatype = 0,
      this.maxlen = 0,
      this.scale = 0,
      this.precision = 0,
      this.datalen = 0,
      Pointer<Uint8>? Function(Library library, Pointer<DBPROCESS> connection)? value})
      : this._value = value;

  QueryParam.nullValue({this.name, this.output = 0, this.datatype = 0, this.maxlen = 0, this.scale = 0, this.precision = 0, this.datalen = 0}) {
    _nullValue();
  }

  Pointer<Uint8>? getValue(Library library, Pointer<DBPROCESS> connection) {
    if (this._value != null) {
      return this._value!(library, connection);
    } else {
      return null;
    }
  }

  void _nullValue() {
    if (this.datatype == 0) {
      this.datatype = SYBVARBINARY;
    }

    this._value = null;
    this.datalen = 0;
    this.maxlen = 0;
    this.scale = null;
    this.precision = null;
  }

  void _stringValue(String data) {
    if (this.datatype == 0) {
      this.datatype = SYBVARCHAR;
    }

    this._value = (_, __) => data.toNativeUtf8().cast();
    this.datalen = data.length;
    this.maxlen = 0;
    this.scale = null;
    this.precision = null;
  }

  void _doubleValue(Decimal data) {
    if ([0, SYBNUMERIC, SYBDECIMAL].contains(this.datatype)) {
      this.datatype = SYBFLT8;
    }

    if (this.datatype == SYBFLTN) {
      this.datatype = SYBFLT8;
    } else if (this.datatype == SYBMONEYN) {
      this.datatype = SYBMONEY;
    }

    if (precision == null) {
      precision = data.precision;
    }
    if (scale == null) {
      scale = data.scale;
    }

    double doubleData = data.toDouble();

    switch (this.datatype) {
      case SYBFLT8:
        final Pointer<Uint8> result = malloc<Uint8>(8);
        result.asTypedList(8).setAll(0, (ByteData(8)..setFloat64(0, doubleData)).buffer.asUint8List().reversed);
        this.datalen = 8;
        this.datatype = SYBFLT8;
        this._value = (_, __) => result;
        break;
      case SYBREAL:
        final Pointer<Uint8> result = malloc<Uint8>(4);
        result.asTypedList(4).setAll(0, (ByteData(4)..setFloat32(0, doubleData)).buffer.asUint8List().reversed);
        this.datalen = 4;
        this._value = (_, __) => result;
        break;
      case SYBMONEY:
        this.datalen = 8;
        if (doubleData > (Int64.MAX_VALUE.toInt() / 10000) || doubleData < (Int64.MIN_VALUE.toInt() / 10000)) {
          throw ArgumentError("Overflow");
        }

        var doubleToIntData = Int64((doubleData * 10000).toInt()).toInt();
        var byteDate = ByteData(8)..setInt64(0, doubleToIntData);
        final Pointer<DBMONEY> result = malloc<DBMONEY>();
        result.ref.mnyhigh = byteDate.buffer.asByteData(0, 4).getInt32(0);
        result.ref.mnylow = byteDate.buffer.asByteData(4, 4).getInt32(0);
        this._value = (_, __) => result.cast();
        break;
      case SYBMONEY4:
        this.datalen = 4;
        if (doubleData > (Int32.MAX_VALUE.toInt() / 10000) || doubleData < (Int32.MIN_VALUE.toInt() / 10000)) {
          throw ArgumentError("Overflow");
        }

        var doubleToIntData = Int32((doubleData * 10000).toInt()).toInt();
        var byteDate = ByteData(4)..setInt32(0, doubleToIntData);
        final Pointer<DBMONEY4> result = malloc<DBMONEY4>();
        result.ref.mny4 = byteDate.buffer.asByteData(0, 4).getInt32(0);
        this._value = (_, __) => result.cast();
        break;
      default:
        throw ArgumentError("Invalid data type");
    }
    this.maxlen = 0;
  }

  void _intValue(BigInt data) {
    List<int> byteArray;

    if (this.datatype == 0) {
      this.datatype = SYBINTN;
    } else if (this.datatype == SYBUINT1) {
      throw ArgumentError("Invalid data type");
    }

    if (this.datatype == SYBINTN || this.datatype == SYBUINTN) {
      bool isUnsigned = this.datatype == SYBUINTN;
      byteArray = List.generate(8, (n) => (((data >> (8 * n)) & BigInt.from(0xFF)).toInt()), growable: true);

      for (int i = 7; i > 0; i--) {
        if (!isUnsigned && (byteArray[i] == 0xFF && byteArray[i - 1] & 0x80 != 0 || byteArray[i] == 0x00 && byteArray[i - 1] & 0x80 == 0)) {
          byteArray.removeLast();
        } else if (isUnsigned && byteArray[i] == 0x00) {
          byteArray.removeLast();
        } else {
          break;
        }
      }

      bool addZeros = isUnsigned || byteArray.last & 0x80 == 0;
      while (byteArray.length < 8 && ![1, 2, 4, 8].contains(byteArray.length)) {
        byteArray.add(addZeros ? 0x00 : 0xFF);
      }

      if (byteArray.length == 1 && !addZeros) {
        byteArray.add(0xFF);
      }

      if (byteArray.length == 1) {
        this.datatype = SYBINT1;
      } else if (byteArray.length == 2) {
        this.datatype = this.datatype == SYBINTN ? SYBINT2 : SYBUINT2;
      } else if (byteArray.length == 4) {
        this.datatype = this.datatype == SYBINTN ? SYBINT4 : SYBUINT4;
      } else {
        this.datatype = this.datatype == SYBINTN ? SYBINT8 : SYBUINT8;
      }
    } else {
      switch (this.datatype) {
        case SYBINT1:
          byteArray = List.of([(data & BigInt.from(0xFF)).toInt()], growable: true);
          break;
        case SYBINT2:
          byteArray = List.generate(2, (n) => (((data >> (8 * n)) & BigInt.from(0xFF)).toInt()), growable: true);
          break;
        case SYBUINT2:
          byteArray = List.generate(2, (n) => (((data >> (8 * n)) & BigInt.from(0xFF)).toInt()), growable: true);
          break;
        case SYBINT4:
          byteArray = List.generate(4, (n) => (((data >> (8 * n)) & BigInt.from(0xFF)).toInt()), growable: true);
          break;
        case SYBUINT4:
          byteArray = List.generate(4, (n) => (((data >> (8 * n)) & BigInt.from(0xFF)).toInt()), growable: true);
          break;
        case SYBINT8:
          byteArray = List.generate(8, (n) => (((data >> (8 * n)) & BigInt.from(0xFF)).toInt()), growable: true);
          break;
        case SYBUINT8:
          byteArray = List.generate(8, (n) => (((data >> (8 * n)) & BigInt.from(0xFF)).toInt()), growable: true);
          break;
        default:
          throw ArgumentError("Invalid data type");
      }
    }

    switch (this.datatype) {
      case SYBINT1:
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
        throw ArgumentError("Invalid data type");
    }

    final Pointer<Uint8> result = malloc<Uint8>(byteArray.length);
    result.asTypedList(byteArray.length).setAll(0, byteArray);

    this._value = (_, __) => result;
    this.maxlen = 0;
    this.scale = null;
    this.precision = null;
  }

  void _uInt8ListValue(List<int> data) {
    if (this.datatype == 0) {
      this.datatype = SYBVARBINARY;
    }

    final Pointer<Uint8> result = malloc<Uint8>(data.length);
    result.asTypedList(data.length).setAll(0, data);

    this._value = (_, __) => result;
    this.datalen = data.length;
    this.maxlen = 0;
    this.scale = null;
    this.precision = null;
  }

  @override
  String toString() => 'QueryParam{name: $name, output: $output, datatype: $datatype, maxlen: $maxlen, scale: $scale, precision: $precision, datalen: $datalen}';
}