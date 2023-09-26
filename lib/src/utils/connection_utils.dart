import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:ffi/ffi.dart';

import '../../freetds.dart';
import '../error/error_message.dart';
import '../library.dart';
import 'date_utils.dart';

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
      case SYBVARCHAR:
      case SYBNVARCHAR:
      case SYBTEXT:
      case SYBNTEXT:
        column.ref.size = min(column.ref.size, FreeTDS.instance.maxTextSize);
        return NTBSTRINGBIND;
      case SYBDATETIME:
      case SYBDATETIME4:
      case SYBDATETIMN:
      case SYBBIGDATETIME:
      case SYBBIGTIME:
        return DATETIMEBIND;
      case SYBDATE:
      case SYBMSDATE:
        return DATEBIND;
      case SYBTIME:
      case SYBMSTIME:
        column.ref.size += 14;
        return CHARBIND;
      case SYBMSDATETIMEOFFSET:
      case SYBMSDATETIME2:
        return DATETIME2BIND;
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

  static void bind(FreeTDS_library library, Pointer<DBPROCESS> connection, Pointer<SQL_COLUMN> column, int columnNumber, int bindType) {
    column.ref.data = calloc<Uint8>(column.ref.size);
    if (column.ref.data == nullptr) {
      throw FreeTDSException.fromErrorMessage(ErrorMessage.outOfMemoryError);
    }

    int typeBindStatus = library.dbbind(connection, columnNumber, bindType, column.ref.size, column.ref.data);
    if (typeBindStatus == FAIL) {
      throw FreeTDSException.fromErrorMessage(ErrorMessage.bindResultColumnError);
    }

    column.ref.status = calloc<Int32>();
    if (column.ref.status == nullptr) {
      throw FreeTDSException.fromErrorMessage(ErrorMessage.outOfMemoryError);
    }

    int nullBindStatus = library.dbnullbind(connection, columnNumber, column.ref.status);
    if (nullBindStatus == FAIL) {
      throw FreeTDSException.fromErrorMessage(ErrorMessage.bindNullColumnError);
    }
  }

  static dynamic getData(FreeTDS_library library, Pointer<DBPROCESS> connection, Pointer<SQL_COLUMN> column) {
    switch (column.ref.type) {
      case SYBBIT:
        return column.ref.data
            .cast<Uint8>()
            .value == 1 ? true : false;
      case SYBINT1:
        return column.ref.data
            .cast<Int8>()
            .value;
      case SYBINT2:
        return column.ref.data
            .cast<Int16>()
            .value;
      case SYBINT4:
        return column.ref.data
            .cast<Int32>()
            .value;
      case SYBINT8:
        return column.ref.data
            .cast<Int64>()
            .value;
      case SYBUINT1:
        return column.ref.data
            .cast<Uint8>()
            .value;
      case SYBUINT2:
        return column.ref.data
            .cast<Uint16>()
            .value;
      case SYBUINT4:
        return column.ref.data
            .cast<Uint32>()
            .value;
      case SYBUINT8:
        return column.ref.data
            .cast<Uint64>()
            .value;
      case SYBFLT8:
        return column.ref.data
            .cast<Double>()
            .value;
      case SYBREAL:
        return column.ref.data
            .cast<Float>()
            .value;
      case SYBDECIMAL:
      case SYBNUMERIC:
        var codeUnits = column.ref.data.cast<Uint8>();

        var maxLength = column.ref.size;
        var length = 0;
        while (codeUnits[length] != 0 && length < maxLength) {
          length++;
        }

        return Decimal.parse(utf8.decode(codeUnits.asTypedList(length)).trim()).toDouble();
      case SYBMONEY4:
        return Decimal.fromInt(column.ref.data
            .cast<DBMONEY4>()
            .ref
            .mny4).shift(-4).toDouble();
      case SYBMONEY:
        final _value = calloc<Uint8>(20);
        if (_value == nullptr) {
          throw FreeTDSException.fromErrorMessage(ErrorMessage.outOfMemoryError);
        }
        library.dbconvert(
            connection,
            SYBMONEY,
            column.ref.data,
            sizeOf<Int32>(),
            SYBCHAR,
            _value,
            -1);

        var codeUnits = _value.asTypedList(20);

        var length = 0;
        while (codeUnits[length] != 0 && length < codeUnits.length) {
          length++;
        }

        final data = utf8.decode(codeUnits.sublist(0, length)).trim();
        calloc.free(_value);
        return Decimal.parse(data).toDouble();
      case SYBDATETIME:
      case SYBDATETIMN:
      case SYBBIGDATETIME:
      case SYBBIGTIME:
      case SYBMSDATETIME2:
      case SYBMSDATETIMEOFFSET:
        final _value = calloc<DBDATEREC2>();
        if (_value == nullptr) {
          throw FreeTDSException.fromErrorMessage(ErrorMessage.outOfMemoryError);
        }
        library.dbanydatecrack(connection, _value, column.ref.type, column.ref.data.cast());
        final dateTime = DateUtils.dateWithYear(
            _value.ref.dateyear,
            _value.ref.datemonth + 1,
            _value.ref.datedmonth,
            _value.ref.datehour,
            _value.ref.dateminute,
            _value.ref.datesecond,
            _value.ref.datensecond,
            _value.ref.datetzone);
        calloc.free(_value);
        return dateTime;
      case SYBDATETIME4:
        final _value = calloc<DBDATEREC>();
        if (_value == nullptr) {
          throw FreeTDSException.fromErrorMessage(ErrorMessage.outOfMemoryError);
        }
        library.dbdatecrack(connection, _value, column.ref.data.cast());
        final dateTime = DateUtils.dateWithYear(_value.ref.dateyear, _value.ref.datemonth + 1, _value.ref.datedmonth, _value.ref.datehour, _value.ref.dateminute, _value.ref.datesecond);
        calloc.free(_value);
        return dateTime;
      case SYBMSDATE:
        final _value = calloc<DBDATEREC>();
        if (_value == nullptr) {
          throw FreeTDSException.fromErrorMessage(ErrorMessage.outOfMemoryError);
        }
        library.dbdatecrack(connection, _value, column.ref.data.cast());
        final date = DateUtils.dateWithYear(_value.ref.dateyear, _value.ref.datemonth + 1, _value.ref.datedmonth);
        calloc.free(_value);
        return date;
      case SYBMSTIME:
        var codeUnits = column.ref.data.cast<Uint8>();

        var maxLength = column.ref.size;
        var length = 0;
        while (codeUnits[length] != 0 && length < maxLength) {
          length++;
        }

        return DateUtils.dateWithTimeString(utf8.decode(codeUnits.asTypedList(length)).trim());
      case SYBCHAR:
      case SYBVARCHAR:
      case SYBNVARCHAR:
      case SYBTEXT:
      case SYBNTEXT:
        var codeUnits = column.ref.data.cast<Uint8>();

        var maxLength = column.ref.size;
        var length = 0;
        while (codeUnits[length] != 0 && length < maxLength) {
          length++;
        }

        return utf8.decode(codeUnits.asTypedList(length));
      case SYBVOID:
      case SYBIMAGE:
      case SYBBINARY:
      case SYBVARBINARY:
      case SYBUNIQUEIDENTIFIER:
        final data = column.ref.data.cast<Uint8>().asTypedList(column.ref.size);
        return Uint8List.fromList(data);
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
