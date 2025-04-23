import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ai/expression_cleaner.dart';

class CASService {
  static const String _baseUrl = 'http://192.168.1.192:8000';

  static Future<Map<String, dynamic>> analyzeExpression(String expression) async {
    try {
      final cleaned = ExpressionCleaner.clean(expression);

      print("📨 Sending to backend: $cleaned");
      print("📡 URL: $_baseUrl/analyze");

      final response = await http.post(
        Uri.parse("$_baseUrl/analyze"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'equation': cleaned}),
      );

      print("⚠️ Response status: ${response.statusCode}");
      print("📩 Response body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": "HTTP ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": e.toString()};
    }
  }
}
