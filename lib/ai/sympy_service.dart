import 'dart:convert';
import 'package:http/http.dart' as http;
import 'expression_cleaner.dart';

class CASService {
  static const String _baseUrl = 'http://192.168.1.192:8000'; // Your local IP

  static Future<Map<String, dynamic>> analyzeExpression(String expression) async {
    try {
      final cleanedExpression = ExpressionCleaner.clean(expression);
      print("📨 Sending to backend: $cleanedExpression");

      final response = await http.post(
        Uri.parse('$_baseUrl/analyze'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(cleanedExpression), // Just raw string!
      );

      print("⚠️ Response status: ${response.statusCode}");
      print("📩 Response body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": "HTTP ${response.statusCode}: ${response.reasonPhrase}"};
      }
    } catch (e) {
      return {"error": "❌ Error connecting to backend: ${e.toString()}"};
    }
  }
}
