# FreeTDS Flutter

FreeTDS is a free implementation of Sybase's DB-Library, CT-Library,
and ODBC libraries. FreeTDS builds and runs on every flavor of
unix-like systems we've heard of (and some we haven't) as well as
Win32 (with or without Cygwin), VMS, and Mac OS X.

FreeTDS is licensed under the GNU LGPL license. See [COPYING_LIB.txt](./COPYING_LIB.txt) for
details.

FreeTDS project compiling for iOS and macOS.


FreeTDS 1.3.18
```bash
flutter create --platforms=macos . 
flutter build macos-framework -t lib/freetds.dart
```

## Sybase datatype

| constant     | storage formats   |
|--------------|-------------------|
| SYBCHAR      | char              |
| SYBVARCHAR   | varchar           |
| SYBNVARCHAR  | nvarchar          |
| SYBTEXT      | text              |
| SYBNTEXT     | ntext             |
| SYBBINARY    | binary, timestamp |
| SYBVARBINARY | varbinary         |
| SYBIMAGE     | image             |
| SYBINT1      | tinyint           |
| SYBINT2      | smallint          |
| SYBINT4      | int               |
| SYBINT8      | bigint            |
| SYBFLT8      | float             |
| SYBFLT8      | double            |
| SYBREAL      | real              |
| SYBBIT       | bit               |
| SYBNUMERIC   | numeric           |
| SYBDECIMAL   | decimal           |
| SYBMONEY     | money             |
| SYBMONEY4    | small money       |
| SYBDATETIME  | datetime          |
| SYBDATETIME4 | small datetime    |
| SYBDATE      | date              |
| SYBTIME      | time              |