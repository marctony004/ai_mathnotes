import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui' as ui;
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'drawing_tool.dart';

enum CanvasBackgroundStyle { plain, lined, grid }

class DrawnLine {
  final List<Offset> points;
  final DrawingTool tool;
  final double brushSize;
  final Color color;

  DrawnLine(this.points, this.tool, this.brushSize, this.color);
}

class _DrawingPainter extends CustomPainter {
  final List<DrawnLine> lines;
  final List<Offset> currentPoints;
  final Offset? shapeStart;
  final Offset? shapeEnd;
  final DrawingTool tool;
  final double brushSize;
  final Color color;
  final Paint Function(DrawnLine) getPaint;
  final CanvasBackgroundStyle backgroundStyle;
  final Rect? highlightRect;

  _DrawingPainter({
    required this.lines,
    required this.currentPoints,
    required this.shapeStart,
    required this.shapeEnd,
    required this.tool,
    required this.brushSize,
    required this.color,
    required this.getPaint,
    required this.backgroundStyle,
    required this.highlightRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in lines) {
      final path = Path();
      final points = line.points;
      if (points.isEmpty) continue;
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, getPaint(line));
    }

    if (currentPoints.isNotEmpty) {
      final path = Path();
      path.moveTo(currentPoints.first.dx, currentPoints.first.dy);
      for (int i = 1; i < currentPoints.length; i++) {
        path.lineTo(currentPoints[i].dx, currentPoints[i].dy);
      }
      final previewLine = DrawnLine(currentPoints, tool, brushSize, color);
      canvas.drawPath(path, getPaint(previewLine));
    }

    if (highlightRect != null) {
      final highlightPaint = Paint()
        ..color = Colors.yellow.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      canvas.drawRect(highlightRect!, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class HandwritingCanvas extends StatefulWidget {
  final DrawingTool tool;
  final double brushSize;
  final Color color;
  final bool stylusOnly;
  final bool enableSmoothing;
  final bool enablePressure;
  final CanvasBackgroundStyle backgroundStyle;

  const HandwritingCanvas({
    super.key,
    required this.tool,
    required this.brushSize,
    required this.color,
    required this.stylusOnly,
    this.enableSmoothing = true,
    this.enablePressure = true,
    this.backgroundStyle = CanvasBackgroundStyle.plain,
  });

  @override
  HandwritingCanvasState createState() => HandwritingCanvasState();
}

class HandwritingCanvasState extends State<HandwritingCanvas> {
  final GlobalKey repaintKey = GlobalKey();
  final List<DrawnLine> _lines = [];
  final List<DrawnLine> _redoStack = [];
  final List<DrawnLine> _solveLines = [];

  List<Offset> _currentPoints = [];
  Offset? _startShapePoint;
  Offset? _endShapePoint;
  Path? _lassoPath;
  Rect? _highlightRect;
  Timer? _highlightTimer;
  double _currentPressure = 1.0;
  bool _isCapturingSolve = false;

  bool _isStylus(PointerEvent e) =>
      e.kind == PointerDeviceKind.stylus || e.kind == PointerDeviceKind.invertedStylus;

  double _getEffectiveBrushSize() {
    return widget.enablePressure
        ? (_currentPressure * widget.brushSize).clamp(1.0, 40.0)
        : widget.brushSize;
  }

  List<Offset> _chaikinSmooth(List<Offset> points, int iterations) {
    List<Offset> smoothed = List.from(points);
    for (int i = 0; i < iterations; i++) {
      List<Offset> newPoints = [];
      for (int j = 0; j < smoothed.length - 1; j++) {
        Offset p0 = smoothed[j];
        Offset p1 = smoothed[j + 1];
        Offset q = Offset(0.75 * p0.dx + 0.25 * p1.dx, 0.75 * p0.dy + 0.25 * p1.dy);
        Offset r = Offset(0.25 * p0.dx + 0.75 * p1.dx, 0.25 * p0.dy + 0.75 * p1.dy);
        newPoints.add(q);
        newPoints.add(r);
      }
      smoothed = newPoints;
    }
    return smoothed;
  }

  Rect _calculateBounds(List<DrawnLine> lines) {
    Rect bounds = Rect.zero;
    for (final line in lines) {
      for (final point in line.points) {
        bounds = bounds.expandToInclude(Rect.fromCircle(center: point, radius: 1));
      }
    }
    return bounds;
  }

  Paint _getPaintFor(DrawnLine line) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = line.brushSize
      ..style = PaintingStyle.stroke;

    switch (line.tool) {
      case DrawingTool.pen:
        paint.color = line.color;
        break;
      case DrawingTool.pencil:
        paint.color = line.color.withOpacity(0.6);
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 0.5);
        break;
      case DrawingTool.marker:
        paint.color = line.color.withOpacity(0.85);
        paint.strokeWidth = line.brushSize * 1.4;
        break;
      case DrawingTool.highlighter:
        paint.color = line.color.withOpacity(0.2);
        paint.strokeWidth = line.brushSize * 3.0;
        break;
      case DrawingTool.eraser:
        paint.color = Colors.transparent;
        paint.blendMode = BlendMode.clear;
        break;
      default:
        paint.color = line.color;
    }

    return paint;
  }

  DrawnLine _createSnappedShape(Offset start, Offset end, DrawingTool tool) {
    List<Offset> points = [];
    final left = min(start.dx, end.dx);
    final right = max(start.dx, end.dx);
    final top = min(start.dy, end.dy);
    final bottom = max(start.dy, end.dy);

    switch (tool) {
      case DrawingTool.ruler:
        points = [start, end];
        break;
      case DrawingTool.shape:
        final width = right - left;
        final height = bottom - top;
        if ((width - height).abs() < 20) {
          points = [
            Offset(left, top),
            Offset(right, top),
            Offset(right, bottom),
            Offset(left, bottom),
            Offset(left, top),
          ];
        } else if (height > width) {
          final p1 = Offset(left + width / 2, top);
          final p2 = Offset(left, bottom);
          final p3 = Offset(right, bottom);
          points = [p1, p2, p3, p1];
        } else {
          final radius = (width + height) / 4;
          final center = Offset((left + right) / 2, (top + bottom) / 2);
          for (int i = 0; i <= 30; i++) {
            final angle = 2 * pi * i / 30;
            points.add(Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle)));
          }
        }
        break;
      default:
        break;
    }

    return DrawnLine(points, tool, _getEffectiveBrushSize(), widget.color);
  }

  void _flashHighlight(Rect rect) {
    setState(() => _highlightRect = rect);
    _highlightTimer?.cancel();
    _highlightTimer = Timer(const Duration(milliseconds: 600), () {
      setState(() => _highlightRect = null);
    });
  }

  void _commitCurrentLine() {
    if (_currentPoints.length < 2) return;

    final line = DrawnLine(
      widget.enableSmoothing ? _chaikinSmooth(_currentPoints, 2) : _currentPoints,
      widget.tool,
      _getEffectiveBrushSize(),
      widget.color,
    );

    if (_isCapturingSolve) {
      _solveLines.add(line);
    } else {
      _lines.add(line);
    }

    if (widget.tool == DrawingTool.solveLasso) {
      final path = Path()..addPolygon(line.points, true);
      final bounds = path.getBounds();
      _flashHighlight(bounds);
    }

    _currentPoints = [];
    setState(() {});
  }

  void startSolveCapture() {
    _solveLines.clear();
    _isCapturingSolve = true;
  }

  void stopSolveCapture() {
    _isCapturingSolve = false;
  }

  Future<File?> exportSolveLinesAsImage() async {
    await WidgetsBinding.instance.endOfFrame;

    final bounds = _calculateBounds(_solveLines).inflate(40);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      Paint()..color = Colors.white,
    );

    for (final line in _solveLines) {
      final paint = _getPaintFor(line);
      final path = Path();
      final points = line.points;
      if (points.isEmpty) continue;
      path.moveTo(points.first.dx - bounds.left, points.first.dy - bounds.top);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx - bounds.left, points[i].dy - bounds.top);
      }
      canvas.drawPath(path, paint);
    }

    final image = await recorder
        .endRecording()
        .toImage(bounds.width.toInt(), bounds.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;

    final file = File('${(await getTemporaryDirectory()).path}/solve_capture.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file;
  }

  void clearCanvas() {
    _lines.clear();
    _redoStack.clear();
    _solveLines.clear();
    _currentPoints.clear();
    _startShapePoint = null;
    _endShapePoint = null;
    setState(() {});
  }

  bool undo() {
    if (_lines.isNotEmpty) {
      _redoStack.add(_lines.removeLast());
      setState(() {});
      return true;
    }
    return false;
  }

  bool redo() {
    if (_redoStack.isNotEmpty) {
      _lines.add(_redoStack.removeLast());
      setState(() {});
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: Listener(
        onPointerDown: (event) {
          if (event.kind == PointerDeviceKind.stylus && widget.stylusOnly) {
            _currentPoints = [event.localPosition];
            setState(() {});
          }
        },
        onPointerMove: (event) {
          if (event.kind == PointerDeviceKind.stylus && widget.stylusOnly) {
            _currentPoints.add(event.localPosition);
            setState(() {});
          }
        },
        onPointerUp: (event) {
          if (event.kind == PointerDeviceKind.stylus && widget.stylusOnly) {
            _commitCurrentLine();
          }
        },
        child: CustomPaint(
          painter: _DrawingPainter(
            lines: [..._lines, ..._solveLines],
            currentPoints: _currentPoints,
            shapeStart: _startShapePoint,
            shapeEnd: _endShapePoint,
            tool: widget.tool,
            brushSize: _getEffectiveBrushSize(),
            color: widget.color,
            getPaint: _getPaintFor,
            backgroundStyle: widget.backgroundStyle,
            highlightRect: _highlightRect,
          ),
          isComplex: true,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
