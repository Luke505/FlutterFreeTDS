import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:freetds/freetds.dart';
import 'package:logger/logger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Logger logger = Logger(level: Level.debug);

  bool loading = false;
  String? error;
  List<FreeTDSExecutionResultTable>? tables;

  TextEditingController hostname = TextEditingController(text: "127.0.0.1:2638");
  TextEditingController username = TextEditingController(text: "dba");
  TextEditingController password = TextEditingController(text: "sql");
  TextEditingController database = TextEditingController(text: "test");
  TextEditingController encryption = TextEditingController(text: "");
  TextEditingController query = TextEditingController(text: "SELECT TOP 100 * FROM SYSTABLE");

  StreamSubscription<FreeTDSError>? errorStreamSubscription;
  StreamSubscription<FreeTDSMessage>? messageStreamSubscription;

  @override
  void initState() async {
    super.initState();

    await FreeTDS.open();
    FreeTDS.openErrorStream();
    FreeTDS.logger = (Level level, String msg) => logger.log(level, msg);
    errorStreamSubscription = FreeTDS.errorStream!.stream.listen((event) {
      logger.e(event);
    });
    FreeTDS.openMessageStream();
    messageStreamSubscription = FreeTDS.messageStream!.stream.listen((event) {
      logger.d(event);
    });
  }

  @override
  void dispose() {
    messageStreamSubscription?.cancel();
    errorStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FreeTDS example'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Hostname'),
                  controller: hostname,
                  enabled: !loading,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Username'),
                  controller: username,
                  enabled: !loading,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  controller: password,
                  obscureText: true,
                  enabled: !loading,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Database'),
                  controller: database,
                  enabled: !loading,
                ),
                DropdownButtonFormField<String>(
                  value: encryption.text,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  //elevation: 16,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    enabledBorder: InputBorder.none,
                    labelText: "Encryption",
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      encryption.text = value ?? "";
                    });
                  },
                  items: [...SYBEncryptionLevel.values].map<DropdownMenuItem<String>>((item) {
                    return DropdownMenuItem<String>(
                      value: item.value,
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Query'),
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  controller: query,
                  enabled: !loading,
                  maxLines: null,
                ),
                const SizedBox(height: 10.0),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: loading ? null : execute,
                      child: const Text('Execute'),
                    ),
                  ),
                ),
                if (error != null)
                  Center(
                    child: Text("Error: $error"),
                  ),
                if (tables != null)
                  Column(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text("Affected rows: ${getResultAffectedRows(tables!)}"),
                            Text("# Rows: ${getResultRowCounts(tables!)}"),
                          ],
                        ),
                      ),
                      ...(tables!
                          .map(
                            (table) => table.columns.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        border: TableBorder.all(),
                                        columns: [
                                          const DataColumn(
                                            label: Expanded(
                                              child: Text(
                                                "#",
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            numeric: true,
                                          ),
                                          ...table.columns.map((column) => DataColumn(
                                                label: Expanded(
                                                  child: Text(
                                                    column,
                                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ))
                                        ],
                                        rows: table.data
                                            .mapIndexed((i, row) => DataRow(
                                                  cells: [
                                                    DataCell(
                                                      Text((i + 1).toString()),
                                                      placeholder: true,
                                                    ),
                                                    ...table.columns.map((column) => DataCell(
                                                          Text(row[column]?.toString() ?? "NULL"),
                                                          placeholder: row[column] == null,
                                                        ))
                                                  ],
                                                ))
                                            .toList(),
                                      ),
                                    ),
                                  )
                                : null,
                          )
                          .nonNulls
                          .toList()),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void execute() async {
    setState(() {
      loading = true;
      tables = null;
      error = null;
    });

    logger.i("connect ...");
    List<FreeTDSExecutionResultTable>? tmpResult;

    try {
      var database = this.database.text.isNotEmpty ? this.database.text : null;
      var encryption = this.encryption.text.isNotEmpty ? SYBEncryptionLevel.values.firstWhere((it) => it.value == this.encryption.text) : null;
      try {
        FreeTDS.connect(host: hostname.text, username: username.text, password: password.text, database: database, encryption: encryption);
      } on FreeTDSException catch (e, st) {
        logger.e("Connection exception", error: e, stackTrace: st);
        setState(() {
          error = e.message;
          loading = false;
        });
        return;
      } catch (e, st) {
        var message = "Unknown exception";
        logger.e(message, error: e, stackTrace: st);
        setState(() {
          error = message;
          loading = false;
        });
        return;
      }

      logger.i("execute ...");

      try {
        tmpResult = FreeTDS.query(query.text, []);
      } on FreeTDSException catch (e, st) {
        logger.e("Query execute exception", error: e, stackTrace: st);
        setState(() {
          error = e.message;
          loading = false;
        });
        return;
      } catch (e, st) {
        var message = "Unknown exception";
        logger.e(message, error: e, stackTrace: st);
        setState(() {
          error = message;
          loading = false;
        });
        return;
      }

      logger.i("result: $tmpResult");

      for (var table in tmpResult) {
        logger.i("output of #${table.affectedRows} affected rows: ${json.encode(table.data, toEncodable: (dynamic object) {
          try {
            return object.toJson();
          } on NoSuchMethodError {
            return object.toString();
          }
        })}");
      }
    } catch (e, st) {
      logger.e("Process exception", error: e, stackTrace: st);
    }

    try {
      FreeTDS.disconnect();
    } catch (e, st) {
      logger.e("Disconnection exception", error: e, stackTrace: st);
    }

    setState(() {
      loading = false;
      tables = tmpResult;
      error = null;
    });
  }

  dynamic getResultAffectedRows(List<FreeTDSExecutionResultTable> tables) {
    if (tables.length == 1) {
      return tables[0].affectedRows;
    } else if (tables.length > 1) {
      return tables.map((t) => t.affectedRows).toList();
    } else {
      return 0;
    }
  }

  dynamic getResultRowCounts(List<FreeTDSExecutionResultTable> tables) {
    if (tables.length == 1) {
      return tables[0].data.length;
    } else if (tables.length > 1) {
      return tables.map((t) => t.data.length).toList();
    } else {
      return 0;
    }
  }
}
