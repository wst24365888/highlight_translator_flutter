import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Translator {
  final String source;
  String? result;
  final String targetLang;

  Translator({required this.source, required this.targetLang});

  Future<void> translate() async {
    http.Client client = http.Client();

    try {
      http.Response response = await client.post(
          Uri.http("127.0.0.1:6666", "/translate"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({"source": source, "target-lang": targetLang}));

      Map<String, dynamic> translator =
          jsonDecode(utf8.decode(response.bodyBytes));

      print(translator["result"]);
      result = translator["result"];
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
