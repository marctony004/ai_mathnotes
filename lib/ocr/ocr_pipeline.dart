import 'dart:io';
import 'dart:typed_data';
import 'ocr_service.dart';
import 'ocr_result_model.dart';
import 'text_classifier.dart';
import '../ocr/ocr_fallback_utils.dart'; // Adjust path if needed


class OCRPipeline {
  static Future<List<OCRLine>> processImage(File imageFile) async {
    // First OCR pass
    List<String> lines = await OCRService.extractTextFromImage(imageFile);
    List<OCRLine> results = _classifyLines(lines);

    bool hasMath = results.any((line) => line.category == OCRCategory.mathProblem);
    if (!hasMath) {
      print("🔁 No math detected, applying fallback...");

      final originalBytes = await imageFile.readAsBytes();
      final fallbackBytes = preprocessForFallback(originalBytes);
      final fallbackFile = File(imageFile.path.replaceFirst('.png', '_fallback.png'));
      await fallbackFile.writeAsBytes(fallbackBytes);

      List<String> fallbackLines = await OCRService.extractTextFromImage(fallbackFile);
      final fallbackResults = _classifyLines(fallbackLines);

      bool fallbackHasMath = fallbackResults.any((line) => line.category == OCRCategory.mathProblem);
      if (fallbackHasMath) {
        print("✅ Fallback OCR detected math.");
        return fallbackResults;
      } else {
        print("❌ Fallback OCR also failed.");
      }
    }

    return results;
  }

  static List<OCRLine> _classifyLines(List<String> lines) {
    final List<OCRLine> results = [];
    int currentBlockId = 0;
    OCRCategory? lastCategory;

    for (final line in lines) {
      final category = TextClassifier.classifyLine(line);
      if (line.trim().isEmpty || category != lastCategory) currentBlockId++;

      results.add(OCRLine(
        text: line,
        category: category,
        blockId: currentBlockId,
      ));

      lastCategory = category;
    }

    return results;
  }
}
