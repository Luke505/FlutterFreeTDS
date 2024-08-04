import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:ffi/ffi.dart';
import 'package:freetds/src/constants.dart';
import 'package:freetds/src/error/freetds_error_message.dart';
import 'package:freetds/src/error/freetds_exception.dart';
import 'package:freetds/src/freetds.dart';
import 'package:freetds/src/library/library.dart';
import 'package:freetds/src/library/model/model.dart';
import 'package:tempo/tempo.dart';

class Connection {
  static int getBindAndUpdate(Pointer<SQL_COLUMN> column) {
    switch (column.ref.type) {
      case SYBBIT:
      case SYBBITN:
        return BITBIND;
      case SYBINT1:
      case SYBSINT1:
      case SYBUINT1:
        return TINYBIND;
      case SYBINT2:
      case SYBUINT2:
        return SMALLBIND;
      case SYBINT4:
      case SYBUINT4:
      case SYBINTN:
        return INTBIND;
      case SYBINT8:
      case SYBUINT8:
        return BIGINTBIND;
      case SYBFLT8:
      case SYBFLTN:
        return FLT8BIND;
      case SYBREAL:
        return REALBIND;
      case SYBMONEY4:
        return SMALLMONEYBIND;
      case SYBMONEY:
      case SYBMONEYN:
        return MONEYBIND;
      case SYBDECIMAL:
      case SYBNUMERIC:
        column.ref.size += 23;
        return CHARBIND;
      case SYBCHAR:
      case SYBTEXT:
      case SYBVARCHAR:
      case SYBLONGCHAR:
        column.ref.size = min(column.ref.size, FreeTDS.maxTextSize);
        return NTBSTRINGBIND;
      case SYBBIGDATETIME:
        return BIGDATETIMEBIND;
      case SYBDATETIME:
      case SYBDATETIMN:
      case SYBDATETIME4:
        return DATETIMEBIND;
      case SYBDATE:
      case SYBMSDATE:
        return DATEBIND;
      case SYBMSDATETIMEOFFSET:
      case SYBMSDATETIME2:
        return DATETIME2BIND;
      case SYBBIGTIME:
        return BIGTIMEBIND;
      case SYBTIME:
      case SYBMSTIME:
        return TIMEBIND;
      case SYBVOID:
      case SYBIMAGE:
      case SYBBINARY:
      case SYBVARBINARY:
      case SYBUNIQUEIDENTIFIER:
        return BINARYBIND;
      default:
        return CHARBIND;
    }
  }

  static void bind(Library library, Pointer<DBPROCESS> connection, Pointer<SQL_COLUMN> column, int columnNumber, int bindType) {
    column.ref.data = calloc<Uint8>(column.ref.size);
    if (column.ref.data == nullptr) {
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.outOfMemoryError);
    }

    int typeBindStatus = library.dbbind(connection, columnNumber, bindType, column.ref.size, column.ref.data);
    if (typeBindStatus == FAIL) {
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.bindResultColumnError);
    }

    column.ref.status = calloc<Int32>();
    if (column.ref.status == nullptr) {
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.outOfMemoryError);
    }

    int nullBindStatus = library.dbnullbind(connection, columnNumber, column.ref.status);
    if (nullBindStatus == FAIL) {
      throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.bindNullColumnError);
    }
  }

  static dynamic getData(Library library, Pointer<DBPROCESS> connection, Pointer<SQL_COLUMN> column, int columnIndex) {
    switch (column.ref.type) {
      case SYBBIT:
        return column.ref.data.cast<Uint8>().value == 1 ? true : false;
      case SYBINT1:
        return column.ref.data.cast<Int8>().value.toUnsigned(8);
      case SYBINT2:
        return column.ref.data.cast<Int16>().value;
      case SYBINT4:
        return column.ref.data.cast<Int32>().value;
      case SYBINT8:
        return column.ref.data.cast<Int64>().value;
      case SYBUINT1:
        return column.ref.data.cast<Uint8>().value.toUnsigned(8);
      case SYBUINT2:
        return column.ref.data.cast<Uint16>().value.toUnsigned(16);
      case SYBUINT4:
        return column.ref.data.cast<Uint32>().value.toUnsigned(32);
      case SYBUINT8:
        return column.ref.data.cast<Uint64>().value.toUnsigned(64);
      case SYBFLT8:
        return column.ref.data.cast<Double>().value;
      case SYBREAL:
        return num.parse(
            Decimal.parse(column.ref.data.cast<Float>().value.toStringAsFixed(20)).toStringAsPrecision(7)
        );
      case SYBDECIMAL:
      case SYBNUMERIC:
        var codeUnits = column.ref.data.cast<Uint8>();

        var maxLength = column.ref.size;
        var length = 0;
        while (length < maxLength && codeUnits[length] != 0) {
          length++;
        }

        Pointer<DBTYPEINFO> columnTypeInfo = library.dbcoltypeinfo(connection, columnIndex + 1);
        if (columnTypeInfo == nullptr) {
          throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.outOfMemoryError);
        }

        if (columnTypeInfo.ref.scale == 0) {
          return num.parse(
              Decimal.parse(utf8.decode(codeUnits.asTypedList(length)).trim()).ceil(scale: 0)
                  .toStringAsPrecision(columnTypeInfo.ref.precision)
          ).toInt();
        } else {
          return double.parse(
              Decimal.parse(utf8.decode(codeUnits.asTypedList(length)).trim()).ceil(scale: columnTypeInfo.ref.scale)
                  .toStringAsPrecision(columnTypeInfo.ref.precision)
          );
        }
      case SYBMONEY4:
        return Decimal.fromInt(column.ref.data.cast<DBMONEY4>().ref.mny4).shift(-4).toDouble();
      case SYBMONEY:
        var data = column.ref.data.cast<DBMONEY>();
        return Decimal.fromInt((data.ref.mnyhigh << 32) | (data.ref.mnylow & 0xffffffff)).shift(-4).toDouble();
      case SYBMSDATETIMEOFFSET:
        final _value = calloc<DBDATEREC2>();
        if (_value == nullptr) {
          throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.outOfMemoryError);
        }
        library.dbanydatecrack(connection, _value, column.ref.type, column.ref.data);

        final offsetDateTime = OffsetDateTime(ZoneOffset.fromDuration(Duration(hours: _value.ref.datetzone)), _value.ref.dateyear, _value.ref.datemonth + 1, _value.ref.datedmonth, _value.ref.datehour,
            _value.ref.dateminute, _value.ref.datesecond, _value.ref.datensecond);
        calloc.free(_value);
        return offsetDateTime;
      case SYBDATETIME:
      case SYBDATETIMN:
      case SYBBIGDATETIME:
      case SYBMSDATETIME2:
        final _value = calloc<DBDATEREC2>();
        if (_value == nullptr) {
          throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.outOfMemoryError);
        }
        library.dbanydatecrack(connection, _value, column.ref.type, column.ref.data);

        final dateTime = LocalDateTime(_value.ref.dateyear, _value.ref.datemonth + 1, _value.ref.datedmonth, _value.ref.datehour, _value.ref.dateminute, _value.ref.datesecond, _value.ref.datensecond);
        calloc.free(_value);
        return dateTime;
      case SYBDATETIME4:
        final _value = calloc<DBDATEREC>();
        if (_value == nullptr) {
          throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.outOfMemoryError);
        }
        library.dbdatecrack(connection, _value, column.ref.data as Pointer<DBDATETIME>);

        final dateTime = LocalDateTime(_value.ref.dateyear, _value.ref.datemonth + 1, _value.ref.datedmonth, _value.ref.datehour, _value.ref.dateminute);
        calloc.free(_value);
        return dateTime;
      case SYBDATE:
      case SYBMSDATE:
        final _value = calloc<DBDATEREC2>();
        if (_value == nullptr) {
          throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.outOfMemoryError);
        }
        library.dbanydatecrack(connection, _value, column.ref.type, column.ref.data);

        final date = LocalDate(_value.ref.dateyear, _value.ref.datemonth + 1, _value.ref.datedmonth);
        calloc.free(_value);
        return date;
      case SYBBIGTIME:
      case SYBTIME:
      case SYBMSTIME:
        final _value = calloc<DBDATEREC2>();
        if (_value == nullptr) {
          throw FreeTDSException.fromErrorMessage(FreeTDSErrorMessage.outOfMemoryError);
        }
        library.dbanydatecrack(connection, _value, column.ref.type, column.ref.data);

        final time = LocalTime(_value.ref.datehour, _value.ref.dateminute, _value.ref.datesecond, _value.ref.datensecond);
        calloc.free(_value);
        return time;
      case SYBCHAR:
      case SYBTEXT:
      case SYBVARCHAR:
      case SYBLONGCHAR:
        var codeUnits = column.ref.data.cast<Uint8>();

        var maxLength = column.ref.size;
        var length = 0;
        while (length < maxLength && codeUnits[length] != 0) {
          length++;
        }

        return utf8.decode(codeUnits.asTypedList(length));
      case SYBVOID:
      case SYBIMAGE:
      case SYBBINARY:
      case SYBVARBINARY:
      case SYBUNIQUEIDENTIFIER:
        return column.ref.data.cast<Int8>().asTypedList(column.ref.size);
      default:
        return null;
    }
  }

  static String? getColumnTypeName(int type) {
    MapEntry<String, int> t;
    for (t in SYBTypes.entries) {
      if (t.value == type) {
        return t.key;
      }
    }
    return null;
  }

  static String? getColumnBindName(int bind) {
    MapEntry<String, int> b;
    for (b in SYBBinds.entries) {
      if (b.value == bind) {
        return b.key;
      }
    }
    return null;
  }
}
