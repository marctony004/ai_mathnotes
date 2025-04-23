import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';


class ColorPickerDialog extends StatefulWidget {
  final Color currentColor;

  const ColorPickerDialog({required this.currentColor});

  @override
  _ColorPickerDialogState createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.currentColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select Color"),
      content: SingleChildScrollView(
        child: ColorPicker(
                pickerColor: _selectedColor,
                onColorChanged: (color) {
                  setState(() => _selectedColor = color);
                },
                enableAlpha: true,
                displayThumbColor: true,
                showLabel: false,
),

      ),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text("Select"),
          onPressed: () => Navigator.of(context).pop(_selectedColor),
        ),
      ],
    );
  }
}
