import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  /// Extracts individual lines of text from an image using ML Kit
  static Future<List<String>> extractTextFromImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close(); // Important to free resources

    // 🧠 Return each individual line of text detected in the image
    final lines = <String>[];
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        lines.add(line.text.trim());
      }
    }

    return lines;
  }
}
