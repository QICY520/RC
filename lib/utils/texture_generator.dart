import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class TextureGenerator {
  /// Generates a texture image for a block face with the given [label], [icon], and [color].
  /// The texture will be a square image containing the block's face design.
  static Future<ui.Image> generateBlockTexture({
    required String label,
    required IconData icon,
    required Color color,
    double width = 512, // Wide texture
    double height = 204, // 5:2 Aspect Ratio (approx)
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

    final Paint bgPaint = Paint()..color = color;
    final Paint borderPaint = Paint()
      ..color = HSLColor.fromColor(color).withLightness(0.5).toColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // 1. Draw Background
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), borderPaint);

    // 2. Draw Icon (Left Side or Top? Standard blocks usually have Icon Top, Text Bottom. 
    // But for 5:2, maybe Side-by-Side is better? 
    // User's previous image showed Top/Bottom. 
    // Let's keep Top/Bottom but fit them in the limited height.
    // Height 204. 
    
    double h = height;
    double w = width;

    // Scaled down to fit height
    final TextPainter iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: h * 0.5, // 50% of height
          fontFamily: icon.fontFamily,
          color: Colors.white.withOpacity(0.9),
          fontWeight: FontWeight.bold, 
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas, 
      Offset((w - iconPainter.width) / 2, h * 0.05) // Top
    );

    // 3. Draw Label (Bottom)
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: label.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: h * 0.25, // 25% height
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout(maxWidth: w * 0.9);
    textPainter.paint(
      canvas,
      Offset((w - textPainter.width) / 2, h * 0.60),
    );

    final picture = recorder.endRecording();
    return await picture.toImage(width.toInt(), height.toInt());
  }
}
