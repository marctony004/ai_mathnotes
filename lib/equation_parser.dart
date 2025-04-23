// lib/equation_parser.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:function_tree/function_tree.dart';

class EquationParser {
  static bool isGraphable(String input) {
    return _detectType(input) != EquationType.unknown;
  }

  static EquationType _detectType(String equation) {
    final normalized = equation.replaceAll(' ', '').toLowerCase();

    if (RegExp(r'^[yf]\(?x\)?=').hasMatch(normalized)) {
      return EquationType.cartesian;
    }
    if (normalized.contains('x=') && normalized.contains('y=')) {
      return EquationType.parametric;
    }
    if (normalized.startsWith('r=')) {
      return EquationType.polar;
    }
    if (normalized.contains('^2') || normalized.contains('+y')) {
      return EquationType.implicit;
    }
    return EquationType.unknown;
  }

  static Future<Map<String, dynamic>> analyzeWithCAS(String equation) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.192:8000/analyze'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'equation': equation}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to connect to CAS backend');
    }
  }

  static String? parseEquation(String input) {
  try {
    final cleaned = input.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    final patterns = [
      RegExp(r'^y\s*=\s*(.+)$'),
      RegExp(r'^f\(x\)\s*=\s*(.+)$'),
      RegExp(r'^[a-z]\s*=\s*(.+)$'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(cleaned);
      if (match != null) return cleaned;
    }

    return null;
  } catch (_) {
    return null;
  }
}


  static List<FlSpot> generatePoints(String equation) {
    switch (_detectType(equation)) {
      case EquationType.cartesian:
        return _parseCartesian(equation);
      case EquationType.parametric:
        return _parseParametric(equation);
      case EquationType.polar:
        return _parsePolar(equation);
      default:
        throw UnsupportedError('Equation type not supported');
    }
  }

  static List<FlSpot> _parseCartesian(String equation) {
  final expr = equation.split('=').last;
  final func = expr.toSingleVariableFunction();

  return List.generate(100, (i) {
    final x = -10.0 + 0.2 * i;
    final y = func(x).toDouble(); // ✅ Enforce double type
    return FlSpot(x, y);
  });
}


  static List<FlSpot> _parseParametric(String equation) {
  final parts = equation.split(RegExp(r'[;,]'));
  if (parts.length < 2) {
    throw FormatException('Invalid parametric equation format');
  } 

  final xExpr = parts[0].replaceAll(RegExp(r'x\\s*=\\s*'), '').trim();
  final yExpr = parts[1].replaceAll(RegExp(r'y\\s*=\\s*'), '').trim();

  final xFunc = xExpr.toSingleVariableFunction();
  final yFunc = yExpr.toSingleVariableFunction();

  return List.generate(100, (i) {
    final t = -10.0 + 0.2 * i;
    final x = xFunc(t).toDouble();  // 👈 Force type to double
    final y = yFunc(t).toDouble();  // 👈 Force type to double
    return FlSpot(x, y);
  });
}


  static List<FlSpot> _parsePolar(String equation) {
    final rExpr = equation.replaceAll('r=', '').trim();
    final rFunc = rExpr.toSingleVariableFunction();

    return List.generate(100, (i) {
      final theta = (2 * pi * i) / 100;
      final r = rFunc(theta);
      final x = r * cos(theta);
      final y = r * sin(theta);
      return FlSpot(x, y);
    });
  }
}

enum EquationType { cartesian, parametric, polar, implicit, unknown }