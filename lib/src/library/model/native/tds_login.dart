library freetds.library.model.native;

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:freetds/src/library/model/native/tds_capabilities.dart';

base class TDSLOGIN extends Struct {
  external Pointer<Utf8> server_name;
  @Int32()
  external int port;
  @Uint16()
  external int tds_version;
  @Int32()
  external int block_size;
  external Pointer<Utf8> language;
  external Pointer<Utf8> server_charset;
  @Int32()
  external int connect_timeout;
  external Pointer<Utf8> client_host_name;
  external Pointer<Utf8> server_host_name;
  external Pointer<Utf8> server_realm_name;
  external Pointer<Int8> server_spn;
  external Pointer<Int8> db_filename;
  external Pointer<Int8> cafile;
  external Pointer<Int8> crlfile;
  external Pointer<Int8> openssl_ciphers;
  external Pointer<Int8> app_name;
  external Pointer<Utf8> user_name;
  external Pointer<Utf8> password;
  external Pointer<Int8> new_password;
  external Pointer<Int8> library;
  @Uint8()
  external int encryption_level;
  @Int32()
  external int query_timeout;
  external TDS_CAPABILITIES capabilities;
  external Pointer<Int8> client_charset;
  external Pointer<Int8> database;
  external Pointer<Int32> ip_addrs;
  external Pointer<Int8> instance_name;
  external Pointer<Int8> dump_file;
  @Int32()
  external int debug_flags;
  @Int32()
  external int text_size;
  external Pointer<Int8> routing_address;
  @Uint16()
  external int routing_port;
  @Uint8()
  external int option_flag2;
  @Uint32()
  external int bulk_copy;
  @Uint32()
  external int suppress_language;
  @Uint32()
  external int gssapi_use_delegation;
  @Uint32()
  external int mutual_authentication;
  @Uint32()
  external int use_ntlmv2;
  @Uint32()
  external int use_ntlmv2_specified;
  @Uint32()
  external int use_lanman;
  @Uint32()
  external int mars;
  @Uint32()
  external int use_utf16;
  @Uint32()
  external int use_new_password;
  @Uint32()
  external int valid_configuration;
  @Uint32()
  external int check_ssl_hostname;
  @Uint32()
  external int readonly_intent;
  @Uint32()
  external int enable_tls_v1;
  @Uint32()
  external int server_is_valid;
}
