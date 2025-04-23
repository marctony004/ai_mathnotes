import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Converts image to grayscale and applies manual binary thresholding
Uint8List preprocessForFallback(Uint8List bytes) {
  final image = img.decodeImage(bytes);
  if (image == null) return bytes;

  final grayImage = img.grayscale(image);
  const thresholdValue = 130;

  for (int y = 0; y < grayImage.height; y++) {
    for (int x = 0; x < grayImage.width; x++) {
      final pixel = grayImage.getPixel(x, y);
      final luminance = img.getLuminance(pixel);
      final value = luminance < thresholdValue ? 0 : 255;

      grayImage.setPixelRgb(x, y, value, value, value);
    }
  }

  return Uint8List.fromList(img.encodePng(grayImage));
}
