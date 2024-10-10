import 'dart:convert';
import 'dart:io';

import 'router_data.dart';

class RouterParse {
  final File jsonRoutesFile;
  const RouterParse(this.jsonRoutesFile);

  factory RouterParse.fromPath(String path) {
    final file = File(path);
    if (!file.existsSync()) throw ArgumentError('File not found');

    return RouterParse(file);
  }

  static RouterParse of({String? path, File? file}) {
    const msg = 'Routes specification is required';
    if (path == null && file == null) throw ArgumentError(msg);
    return path != null ? RouterParse.fromPath(path) : RouterParse(file!);
  }

  String get _content => jsonRoutesFile.readAsStringSync();

  List<RouterData> getRoutes() {
    final data = (json.decode(_content) as Map<String, dynamic>).entries;
    return data.map((it) => RouterData.fromJson(it.key, it.value)).toList();
  }
}
