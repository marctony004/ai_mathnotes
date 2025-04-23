import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'theme/theme_constants.dart';
import 'package:function_tree/function_tree.dart';


class CyberpunkGraph extends StatelessWidget {
  final String equation;

  const CyberpunkGraph({super.key, required this.equation});

  @override
  Widget build(BuildContext context) {
    try {
      final List<FlSpot> dataPoints = _generateDataPoints();

      return Container(
        height: 220,
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: ThemeConstants.graphBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.tealAccent.withOpacity(0.4), width: 1),
        ),
        padding: const EdgeInsets.all(12),
        child: LineChart(
          LineChartData(
            backgroundColor: Colors.transparent,
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: _buildAxisLabel,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: _buildAxisLabel,
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.white10,
                strokeWidth: 0.8,
              ),
              getDrawingVerticalLine: (value) => FlLine(
                color: Colors.white10,
                strokeWidth: 0.8,
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.white24, width: 1),
            ),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                color: Colors.tealAccent,
                barWidth: 3,
                dotData: FlDotData(show: false),
                spots: dataPoints,
              ),
            ],
            minX: -10,
            maxX: 10,
            minY: -10,
            maxY: 30,
          ),
        ),
      );
    } catch (e) {
      // In case parsing or evaluation fails
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: ThemeConstants.graphBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            '⚠️ Could not render: $equation',
            style: TextStyle(color: ThemeConstants.errorRed),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  /// Generates safe, validated graph points from the parsed equation
  List<FlSpot> _generateDataPoints() {
    final List<FlSpot> points = [];

    final cleaned = equation
        .replaceAll(RegExp(r'^y\s*=\s*'), '')
        .replaceAll(RegExp(r'^f\(x\)\s*=\s*'), '');

    late num Function(num) func;
    try {
      func = cleaned.toSingleVariableFunction().call;
    } catch (e) {
      throw Exception('Invalid expression: $cleaned');
    }

    for (double x = -10; x <= 10; x += 0.5) {
      final result = func(x);
      final y = result.toDouble();
      if (!y.isNaN && !y.isInfinite) {
        points.add(FlSpot(x, y));
      }
        }

    if (points.isEmpty) {
      throw Exception('No valid points generated from: $equation');
    }

    return points;
  }

  /// Axis label styling (white, small font)
  Widget _buildAxisLabel(double value, TitleMeta meta) {
    return Text(
      value.toInt().toString(),
      style: const TextStyle(color: Colors.white38, fontSize: 10),
    );
  }
}
