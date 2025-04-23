import 'package:fl_chart/fl_chart.dart';
import 'package:function_tree/function_tree.dart';

class ParametricEquation {
  final String xExpression;
  final String yExpression;
  final double tMin;
  final double tMax;

  ParametricEquation({
    required this.xExpression,
    required this.yExpression,
    this.tMin = -10,
    this.tMax = 10,
  });

  factory ParametricEquation.fromString(String input) {
    final parts = input.split(RegExp(r'[,\t]'));
    if (parts.length < 2) {
      throw FormatException('Invalid parametric input. Expected format: x=..., y=...');
    }

    return ParametricEquation(
      xExpression: parts[0].replaceAll(RegExp(r'x\s*='), '').trim(),
      yExpression: parts[1].replaceAll(RegExp(r'y\s*='), '').trim(),
    );
  }

  List<FlSpot> generatePoints() {
    final List<FlSpot> points = [];

    final Function xFunc = xExpression.toSingleVariableFunction().call;
    final Function yFunc = yExpression.toSingleVariableFunction().call;

    for (double t = tMin; t <= tMax; t += 0.1) {
      try {
        final x = xFunc(t);
        final y = yFunc(t);

        if (_isValidNumber(x) && _isValidNumber(y)) {
          points.add(FlSpot(x.toDouble(), y.toDouble()));
        }
      } catch (_) {
        continue;
      }
    }

    if (points.isEmpty) {
      throw Exception('No valid points generated for parametric equation.');
    }

    return points;
  }

  bool _isValidNumber(num value) {
    return !value.isNaN && !value.isInfinite;
  }
}
