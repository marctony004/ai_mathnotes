import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'drawing_tool.dart';

class FloatingToolBar extends StatefulWidget {
  final DrawingTool selectedTool;
  final double currentBrushSize;
  final Color currentColor;
  final bool stylusOnly;

  final ValueChanged<DrawingTool> onToolSelected;
  final ValueChanged<double> onBrushSizeChanged;
  final ValueChanged<double> onOpacityChanged;
  final ValueChanged<bool> onSmoothingChanged;
  final ValueChanged<Color> onColorChanged;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onClear;
  final ValueChanged<bool> onStylusToggle;
  final VoidCallback onCollapse;
  final VoidCallback onAddText;

  const FloatingToolBar({
    super.key,
    required this.selectedTool,
    required this.currentBrushSize,
    required this.currentColor,
    required this.stylusOnly,
    required this.onToolSelected,
    required this.onBrushSizeChanged,
    required this.onOpacityChanged,
    required this.onSmoothingChanged,
    required this.onColorChanged,
    required this.onUndo,
    required this.onRedo,
    required this.onClear,
    required this.onStylusToggle,
    required this.onCollapse,
    required this.onAddText,
  });

  @override
  State<FloatingToolBar> createState() => _FloatingToolBarState();
}

class _FloatingToolBarState extends State<FloatingToolBar> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  double _opacity = 1.0;
  bool _smoothing = true;
  late SharedPreferences _prefs;
  late AnimationController _controller;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightAnimation = Tween<double>(begin: 60, end: 260).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _opacity = _prefs.getDouble('brush_opacity') ?? 1.0;
      _smoothing = _prefs.getBool('smoothing') ?? true;
    });
  }

  void _savePrefs() {
    _prefs.setDouble('brush_opacity', _opacity);
    _prefs.setBool('smoothing', _smoothing);
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            height: _heightAnimation.value,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.85),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 4,
                    children: [
                      _toolButton(Icons.create, DrawingTool.pen),
                      _toolButton(Icons.brush, DrawingTool.pencil),
                      _toolButton(Icons.edit, DrawingTool.marker),
                      _toolButton(Icons.highlight, DrawingTool.highlighter),
                      _toolButton(Icons.clear, DrawingTool.eraser),
                      _toolButton(Icons.straighten, DrawingTool.ruler),
                      _toolButton(Icons.change_history, DrawingTool.shape),
                      _toolButton(Icons.functions, DrawingTool.mathSymbol),
                      _toolButton(Icons.crop_free, DrawingTool.lasso),
                      IconButton(icon: const Icon(Icons.text_fields, color: Colors.white), onPressed: widget.onAddText),
                      IconButton(icon: const Icon(Icons.undo, color: Colors.white), onPressed: widget.onUndo),
                      IconButton(icon: const Icon(Icons.redo, color: Colors.white), onPressed: widget.onRedo),
                  /// 🔻 Collapse button
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                        onPressed: widget.onCollapse,
                        tooltip: 'Collapse Toolbar',
                      ),
                    ],
                  ),
                  if (_isExpanded) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.opacity, color: Colors.white),
                        Expanded(
                          child: Slider(
                            min: 0.1,
                            max: 1.0,
                            divisions: 9,
                            value: _opacity,
                            onChanged: (value) {
                              setState(() => _opacity = value);
                              widget.onOpacityChanged(value);
                              _savePrefs();
                            },
                            activeColor: Colors.cyanAccent,
                          ),
                        ),
                      ],
                    ),
                    Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Row(children: [
      const Icon(Icons.blur_on, color: Colors.white),
      const SizedBox(width: 6),
      Switch(
        value: _smoothing,
        onChanged: (val) {
          setState(() => _smoothing = val);
          widget.onSmoothingChanged(val);
          _savePrefs();
        },
      ),
    ]),
    Row(
      children: [
        IconButton(
          icon: Icon(widget.stylusOnly ? Icons.edit_off : Icons.edit, color: Colors.white),
          onPressed: () => widget.onStylusToggle(!widget.stylusOnly),
          tooltip: 'Stylus Mode',
        ),
        IconButton(
          icon: const Icon(Icons.delete_forever, color: Colors.white),
          onPressed: widget.onClear,
          tooltip: 'Clear Canvas',
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          onPressed: widget.onCollapse,
          tooltip: 'Collapse Toolbar',
        ),
      ],
    ),
  ],
),

                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _toolButton(IconData icon, DrawingTool tool) {
    final isSelected = tool == widget.selectedTool;
    return IconButton(
      icon: Icon(icon, color: isSelected ? Colors.cyanAccent : Colors.white),
      onPressed: () => widget.onToolSelected(tool),
      tooltip: tool.name,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
