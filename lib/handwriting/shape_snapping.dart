import 'dart:math';
import 'package:flutter/material.dart';

class ShapeSnapping {
  static List<Offset> snapIfShape(List<Offset> points) {
    if (points.length < 3) return points;

    final closed = _isClosed(points);
    if (!closed) return points;

    final simplified = _simplify(points, 0.05);

    if (_isTriangle(simplified)) {
      return _createPerfectTriangle(points);
    } else if (_isSquare(simplified)) {
      return _createPerfectSquare(points);
    }

    return points;
  }

  static bool _isClosed(List<Offset> points) {
    return (points.first - points.last).distance < 30;
  }

  static List<Offset> _simplify(List<Offset> points, double tolerance) {
    final simplified = <Offset>[];
    simplified.add(points.first);

    for (int i = 1; i < points.length - 1; i++) {
      if ((points[i] - simplified.last).distance > tolerance * 100) {
        simplified.add(points[i]);
      }
    }

    simplified.add(points.last);
    return simplified;
  }

  static bool _isTriangle(List<Offset> simplified) {
    return simplified.length <= 4;
  }

  static bool _isSquare(List<Offset> simplified) {
    if (simplified.length != 5) return false; // closed shape
    final angles = <double>[];

    for (int i = 1; i < simplified.length - 1; i++) {
      final a = simplified[i - 1];
      final b = simplified[i];
      final c = simplified[i + 1];
      final angle = _angleBetween(a, b, c);
      angles.add(angle);
    }

    final avg = angles.reduce((a, b) => a + b) / angles.length;
    return angles.every((a) => (a - avg).abs() < 0.3);
  }

  static double _angleBetween(Offset a, Offset b, Offset c) {
    final ab = a - b;
    final cb = c - b;
    return acos((ab.dx * cb.dx + ab.dy * cb.dy) / (ab.distance * cb.distance));
  }

  static List<Offset> _createPerfectTriangle(List<Offset> points) {
    final center = _findCentroid(points);
    final radius = 50.0;
    return List.generate(3, (i) {
      final angle = -pi / 2 + i * 2 * pi / 3;
      return Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
    })..add(center);
  }

  static List<Offset> _createPerfectSquare(List<Offset> points) {
    final center = _findCentroid(points);
    final size = 100.0;
    return [
      Offset(center.dx - size / 2, center.dy - size / 2),
      Offset(center.dx + size / 2, center.dy - size / 2),
      Offset(center.dx + size / 2, center.dy + size / 2),
      Offset(center.dx - size / 2, center.dy + size / 2),
      Offset(center.dx - size / 2, center.dy - size / 2),
    ];
  }

  static Offset _findCentroid(List<Offset> points) {
    double x = 0;
    double y = 0;
    for (var point in points) {
      x += point.dx;
      y += point.dy;
    }
    return Offset(x / points.length, y / points.length);
  }
}
