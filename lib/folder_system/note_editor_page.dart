import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import 'folder_model.dart';
import 'folder_repository.dart';
import '../handwriting/handwriting_canvas.dart';
import '../handwriting/floating_toolbar.dart';
import '../handwriting/drawing_tool.dart';
import '../ocr/ocr_pipeline.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import '../services/cas_service.dart';
import '../ai/expression_cleaner.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class NoteEditorPage extends StatefulWidget {
  final Folder folder;
  final Note? existingNote;
  final VoidCallback onNoteSaved;

  const NoteEditorPage({
    super.key,
    required this.folder,
    this.existingNote,
    required this.onNoteSaved,
  });

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  final GlobalKey<HandwritingCanvasState> _canvasKey = GlobalKey<HandwritingCanvasState>();
  final GlobalKey _canvasBoundaryKey = GlobalKey();
  bool _isSolving = false;

  CanvasBackgroundStyle _backgroundStyle = CanvasBackgroundStyle.plain;
  DrawingTool currentTool = DrawingTool.pen;
  double brushSize = 3.0;
  double brushOpacity = 1.0;
  bool smoothing = true;
  Color selectedColor = Colors.black;
  bool stylusOnly = true;
  bool toolbarCollapsed = true;

  final ScrollController _scrollController = ScrollController();
  double _canvasHeight = 1600;
  List<_TextBox> textBoxes = [];

  late FolderRepository _repo;
  Note? _noteBeingEdited;
  DateTime? _lastSaved;

  @override
  void initState() {
    super.initState();
    _repo = FolderRepository();
    if (widget.existingNote != null) {
      _noteBeingEdited = widget.existingNote!;
    }
  }

  void _clearCanvas() {
    _canvasKey.currentState?.clearCanvas();
    setState(() => textBoxes.clear());
  }

  void _onAddText() {
    final controller = TextEditingController(text: 'New Text');
    final focusNode = FocusNode();
    final newBox = _TextBox(
      controller: controller,
      focusNode: focusNode,
      offset: const Offset(50, 50),
      isEditing: true,
    );
    setState(() => textBoxes.add(newBox));

    focusNode.addListener(() {
      if (focusNode.hasFocus && controller.text == 'New Text') controller.clear();
      if (!focusNode.hasFocus) setState(() => newBox.isEditing = false);
    });
  }

  void _autosave() {
    final now = DateTime.now();
    if (_lastSaved != null && now.difference(_lastSaved!) < const Duration(seconds: 2)) return;

    final updatedNote = Note(
      id: _noteBeingEdited?.id ?? UniqueKey().toString(),
      title: widget.folder.name,
      content: '',
      folderId: widget.folder.id,
      createdAt: _noteBeingEdited?.createdAt ?? now,
      updatedAt: now,
    );

    _repo.saveNoteToFolder(widget.folder.id, updatedNote);
    widget.onNoteSaved();
    _noteBeingEdited = updatedNote;
    _lastSaved = now;
  }

  void _expandCanvasIfNeeded(DragUpdateDetails details) {
    final newY = details.localPosition.dy;
    if (newY > _canvasHeight - 200) {
      setState(() => _canvasHeight += 800);
    }
  }

  Future<void> _toggleSolve() async {
    if (_isSolving) {
      _canvasKey.currentState?.stopSolveCapture();

      final file = await _canvasKey.currentState?.exportSolveLinesAsImage();
      if (file == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ No strokes found for solving.")),
        );
        return;
      }

      if (await file.exists()) {
        await ImageGallerySaver.saveFile(file.path);
      }

      final ocrResults = await OCRPipeline.processImage(file);
      final mathLines = ocrResults.where((l) => l.category.name == "mathProblem").toList();

      if (mathLines.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ No math detected.")),
        );
      } else {
        final cleaned = ExpressionCleaner.clean(mathLines.first.text);
        final resultMap = await CASService.analyzeExpression(cleaned);

        if (resultMap.containsKey("error")) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ ${resultMap["error"]}")),
          );
        } else {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            builder: (context) {
              return Padding(
                padding: MediaQuery.of(context).viewInsets.add(
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text("🧠 AI Math Solution",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Math.tex(resultMap["latex"] ?? '', textStyle: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 24),
                      if (resultMap.containsKey("derivative"))
                        Math.tex(
                          'f\'(x) = ${resultMap["derivative"]}',
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      if (resultMap.containsKey("integral"))
                        Math.tex(
                          '\\int f(x) dx = ${resultMap["integral"]}',
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      }

      setState(() {
        currentTool = DrawingTool.pen;
        _isSolving = false;
      });
    } else {
      _canvasKey.currentState?.startSolveCapture();
      setState(() {
        currentTool = DrawingTool.pen;
        _isSolving = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("📝 ${widget.folder.name}"),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Listener(
                  onPointerDown: (event) {
                    if (stylusOnly && event.kind == PointerDeviceKind.stylus) {
                      _scrollController.position.hold(() {});
                    }
                  },
                  child: ScrollConfiguration(
                    behavior: const ScrollBehavior().copyWith(overscroll: false),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: stylusOnly ? const NeverScrollableScrollPhysics() : null,
                      child: GestureDetector(
                        onPanUpdate: _expandCanvasIfNeeded,
                        child: SizedBox(
                          height: _canvasHeight,
                          child: RepaintBoundary(
                            key: _canvasBoundaryKey,
                            child: Stack(
                              children: [
                                CustomPaint(
                                  painter: CanvasBackgroundPainter(style: _backgroundStyle),
                                  child: const SizedBox.expand(),
                                ),
                                HandwritingCanvas(
                                  key: _canvasKey,
                                  tool: currentTool,
                                  brushSize: brushSize,
                                  color: selectedColor.withOpacity(brushOpacity),
                                  stylusOnly: stylusOnly,
                                  enableSmoothing: smoothing,
                                  enablePressure: true,
                                  backgroundStyle: _backgroundStyle,
                                ),
                                ...textBoxes.map((box) => Positioned(
                                      left: box.offset.dx,
                                      top: box.offset.dy,
                                      child: GestureDetector(
                                        onPanUpdate: (details) {
                                          setState(() => box.offset += details.delta);
                                        },
                                        onTap: () {
                                          setState(() => box.isEditing = true);
                                          box.focusNode.requestFocus();
                                        },
                                        child: box.isEditing
                                            ? Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.grey),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                                child: IntrinsicWidth(
                                                  child: TextField(
                                                    controller: box.controller,
                                                    focusNode: box.focusNode,
                                                    autofocus: true,
                                                    decoration: const InputDecoration(
                                                      isDense: true,
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                                      border: InputBorder.none,
                                                    ),
                                                    style: const TextStyle(fontSize: 16),
                                                  ),
                                                ),
                                              )
                                            : Text(box.controller.text, style: const TextStyle(fontSize: 16)),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: toolbarCollapsed
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'solveFab',
                  onPressed: _toggleSolve,
                  label: Text(_isSolving ? "Done" : "Solve"),
                  icon: Icon(_isSolving ? Icons.check : Icons.calculate),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'brushFab',
                  onPressed: () => setState(() => toolbarCollapsed = false),
                  child: const Icon(Icons.brush),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingToolBar(
                  selectedTool: currentTool,
                  currentBrushSize: brushSize,
                  currentColor: selectedColor,
                  stylusOnly: stylusOnly,
                  onToolSelected: (tool) => setState(() => currentTool = tool),
                  onBrushSizeChanged: (size) => setState(() => brushSize = size),
                  onColorChanged: (color) => setState(() => selectedColor = color),
                  onUndo: () => _canvasKey.currentState?.undo(),
                  onRedo: () => _canvasKey.currentState?.redo(),
                  onClear: _clearCanvas,
                  onStylusToggle: (enabled) => setState(() => stylusOnly = enabled),
                  onCollapse: () => setState(() => toolbarCollapsed = true),
                  onAddText: _onAddText,
                  onOpacityChanged: (value) => setState(() => brushOpacity = value),
                  onSmoothingChanged: (value) => setState(() => smoothing = value),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: CanvasBackgroundStyle.values.map((style) {
                    return ChoiceChip(
                      label: Text(style.name),
                      selected: _backgroundStyle == style,
                      onSelected: (_) => setState(() => _backgroundStyle = style),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}

class _TextBox {
  final TextEditingController controller;
  final FocusNode focusNode;
  Offset offset;
  bool isEditing;

  _TextBox({
    required this.controller,
    required this.focusNode,
    required this.offset,
    this.isEditing = true,
  });
}

class CanvasBackgroundPainter extends CustomPainter {
  final CanvasBackgroundStyle style;
  final Paint linePaint = Paint()
    ..color = Colors.grey.withOpacity(0.3)
    ..strokeWidth = 0.7;

  CanvasBackgroundPainter({required this.style});

  @override
  void paint(Canvas canvas, Size size) {
    if (style == CanvasBackgroundStyle.plain) return;
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
    if (style == CanvasBackgroundStyle.grid) {
      for (double x = 0; x < size.width; x += 40) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
