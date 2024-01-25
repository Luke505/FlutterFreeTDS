library freetds.library;

import 'dart:ffi';
import 'dart:io' show Platform;

import 'package:freetds/src/library/model/functions.dart';

class Library {
  late DynamicLibrary _library;

  Library() {
    if (Platform.isMacOS || Platform.isIOS) {
      _library = DynamicLibrary.open('FreeTDS.framework/FreeTDS');
      _loadLibraryFunctions();
    } else if (Platform.isWindows) {
      _library = DynamicLibrary.open('sybdb.dll');
      _loadLibraryFunctions();
    } else {
      throw UnsupportedError('FreeTDS is only supported on macOS, iOS and windows.');
    }
  }

  Library.test(String libraryPath) {
    _library = DynamicLibrary.open(libraryPath);
    _loadLibraryFunctions();
  }

  late dbgetuserdata_Dart dbgetuserdata;
  late dbhasretstat_Dart dbhasretstat;
  late dbinit_Dart dbinit;
  late dbiordesc_Dart dbiordesc;

  late dbexit_Dart dbexit;
  late dbfirstrow_Dart dbfirstrow;

  late dberrhandle_Dart dberrhandle;
  late dbmsghandle_Dart dbmsghandle;
  late dbname_Dart dbname;
  late dbnextrow_Dart dbnextrow;
  late dbnullbind_Dart dbnullbind;
  late dbnumalts_Dart dbnumalts;
  late dbnumcols_Dart dbnumcols;
  late dbnumcompute_Dart dbnumcompute;
  late dbnumrets_Dart dbnumrets;
  late tdsdbopen_Dart tdsdbopen;
  late dbopen_Dart dbopen;
  late dbclose_Dart dbclose;
  late dbloginfree_Dart dbloginfree;
  late dbfreebuf_Dart dbfreebuf;
  late dbdead_Dart dbdead;
  late dbsetlname_Dart dbsetlname;
  late dbsetlversion_Dart dbsetlversion;
  late dblogin_Dart dblogin;
  late dbsetlogintime_Dart dbsetlogintime;
  late dbuse_Dart dbuse;
  late dbsqlexec_Dart dbsqlexec;
  late dbresults_Dart dbresults;
  late dbcolname_Dart dbcolname;
  late dbcoltype_Dart dbcoltype;
  late dbcoltypeinfo_Dart dbcoltypeinfo;
  late dbcollen_Dart dbcollen;
  late dbbind_Dart dbbind;
  late dbanydatecrack_Dart dbanydatecrack;
  late dbconvert_Dart dbconvert;
  late dbdatecrack_Dart dbdatecrack;
  late dbsettime_Dart dbsettime;
  late dbcmd_Dart dbcmd;
  late dbcount_Dart dbcount;
  late dbsqlsend_Dart dbsqlsend;
  late dbsqlok_Dart dbsqlok;
  late dbsqlexecparams_Dart dbsqlexecparams;

  void _loadLibraryFunctions() {
    dbgetuserdata = _library.lookupFunction<dbgetuserdata_Native, dbgetuserdata_Dart>('dbgetuserdata');
    dbhasretstat = _library.lookupFunction<dbhasretstat_Native, dbhasretstat_Dart>('dbhasretstat');
    dbinit = _library.lookupFunction<dbinit_Native, dbinit_Dart>('dbinit');
    dbiordesc = _library.lookupFunction<dbiordesc_Native, dbiordesc_Dart>('dbiordesc');
    dberrhandle = _library.lookupFunction<dberrhandle_Native, dberrhandle_Dart>('dberrhandle');
    dbexit = _library.lookupFunction<dbexit_Native, dbexit_Dart>('dbexit');
    dbfirstrow = _library.lookupFunction<dbfirstrow_Native, dbfirstrow_Dart>('dbfirstrow');
    dbmsghandle = _library.lookupFunction<dbmsghandle_Native, dbmsghandle_Dart>('dbmsghandle');
    dbname = _library.lookupFunction<dbname_Native, dbname_Dart>('dbname');
    dbnextrow = _library.lookupFunction<dbnextrow_Native, dbnextrow_Dart>('dbnextrow');
    dbnullbind = _library.lookupFunction<dbnullbind_Native, dbnullbind_Dart>('dbnullbind');
    dbnumalts = _library.lookupFunction<dbnumalts_Native, dbnumalts_Dart>('dbnumalts');
    dbnumcols = _library.lookupFunction<dbnumcols_Native, dbnumcols_Dart>('dbnumcols');
    dbnumcompute = _library.lookupFunction<dbnumcompute_Native, dbnumcompute_Dart>('dbnumcompute');
    dbnumrets = _library.lookupFunction<dbnumrets_Native, dbnumrets_Dart>('dbnumrets');
    tdsdbopen = _library.lookupFunction<tdsdbopen_Native, tdsdbopen_Dart>('tdsdbopen');
    dbopen = _library.lookupFunction<dbopen_Native, dbopen_Dart>('dbopen');
    dbclose = _library.lookupFunction<dbclose_Native, dbclose_Dart>('dbclose');
    dbloginfree = _library.lookupFunction<dbloginfree_Native, dbloginfree_Dart>('dbloginfree');
    dbfreebuf = _library.lookupFunction<dbfreebuf_Native, dbfreebuf_Dart>('dbfreebuf');
    dbdead = _library.lookupFunction<dbdead_Native, dbdead_Dart>('dbdead');
    dbsetlname = _library.lookupFunction<dbsetlname_Native, dbsetlname_Dart>('dbsetlname');
    dbsetlversion = _library.lookupFunction<dbsetlversion_Native, dbsetlversion_Dart>('dbsetlversion');
    dblogin = _library.lookupFunction<dblogin_Native, dblogin_Dart>('dblogin');
    dbsetlogintime = _library.lookupFunction<dbsetlogintime_Native, dbsetlogintime_Dart>('dbsetlogintime');
    dbuse = _library.lookupFunction<dbuse_Native, dbuse_Dart>('dbuse');
    dbsqlexec = _library.lookupFunction<dbsqlexec_Native, dbsqlexec_Dart>('dbsqlexec');
    dbresults = _library.lookupFunction<dbresults_Native, dbresults_Dart>('dbresults');
    dbcolname = _library.lookupFunction<dbcolname_Native, dbcolname_Dart>('dbcolname');
    dbcoltype = _library.lookupFunction<dbcoltype_Native, dbcoltype_Dart>('dbcoltype');
    dbcoltypeinfo = _library.lookupFunction<dbcoltypeinfo_Native, dbcoltypeinfo_Dart>('dbcoltypeinfo');
    dbcollen = _library.lookupFunction<dbcollen_Native, dbcollen_Dart>('dbcollen');
    dbbind = _library.lookupFunction<dbbind_Native, dbbind_Dart>('dbbind');
    dbanydatecrack = _library.lookupFunction<dbanydatecrack_Native, dbanydatecrack_Dart>('dbanydatecrack');
    dbconvert = _library.lookupFunction<dbconvert_Native, dbconvert_Dart>('dbconvert');
    dbdatecrack = _library.lookupFunction<dbdatecrack_Native, dbdatecrack_Dart>('dbdatecrack');
    dbsettime = _library.lookupFunction<dbsettime_Native, dbsettime_Dart>('dbsettime');
    dbcmd = _library.lookupFunction<dbcmd_Native, dbcmd_Dart>('dbcmd');
    dbcount = _library.lookupFunction<dbcount_Native, dbcount_Dart>('dbcount');
    dbsqlsend = _library.lookupFunction<dbsqlsend_Native, dbsqlsend_Dart>('dbsqlsend');
    dbsqlok = _library.lookupFunction<dbsqlok_Native, dbsqlok_Dart>('dbsqlok');
    dbsqlexecparams = _library.lookupFunction<dbsqlexecparams_Native, dbsqlexecparams_Dart>('dbsqlexecparams');
  }
}
