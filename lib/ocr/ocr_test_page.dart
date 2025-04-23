import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:ai_mathnotes/ocr/ocr_pipeline.dart';
import 'package:ai_mathnotes/ocr/ocr_result_model.dart';

class OCRTestPage extends StatefulWidget {
  const OCRTestPage({super.key});

  @override
  State<OCRTestPage> createState() => _OCRTestPageState();
}

class _OCRTestPageState extends State<OCRTestPage> {
  File? _selectedImage;
  List<OCRLine> _results = [];
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _results = [];
      });
    }
  }

  Future<void> _runOCR() async {
    if (_selectedImage == null) return;

    setState(() => _isLoading = true);

    final results = await OCRPipeline.processImage(_selectedImage!);
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  Widget _buildResultsList() {
    if (_results.isEmpty) {
      return const Text(
        "No OCR results yet",
        style: TextStyle(color: Colors.white70),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final line = _results[index];
          return ListTile(
            title: Text(
              line.text,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              line.category.toString().replaceAll('OCRCategory.', ''),
              style: TextStyle(
                color: line.category == OCRCategory.mathProblem
                    ? Colors.tealAccent
                    : line.category == OCRCategory.dueDate
                        ? Colors.orangeAccent
                        : line.category == OCRCategory.mathDefinition
                            ? Colors.cyan
                            : line.category == OCRCategory.exampleSolution
                                ? Colors.lightGreen
                                : Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("OCR Demo"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_selectedImage != null)
              Image.file(_selectedImage!, height: 200),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("📷 Pick Image"),
            ),
            ElevatedButton(
              onPressed: _runOCR,
              child: const Text("🧠 Run OCR"),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : _buildResultsList(),
          ],
        ),
      ),
    );
  }
}
