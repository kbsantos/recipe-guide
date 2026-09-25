import 'dart:convert';

import 'package:flutter/services.dart';

class JsonLoader {
  JsonLoader._();

  static Future<Map<String, dynamic>> load(String path) async {
    final jsonString = await rootBundle.loadString(path);

    return json.decode(jsonString) as Map<String, dynamic>;
  }
}
