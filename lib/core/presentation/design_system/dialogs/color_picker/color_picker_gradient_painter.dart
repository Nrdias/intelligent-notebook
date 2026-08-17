import 'package:flutter/material.dart';

/// 2D HSV Saturation/Value gradient box painter with interactive thumb indicator.
class ColorPickerGradientPainter extends CustomPainter {
  final double hue;
  final double saturation;
  final double value;

  const ColorPickerGradientPainter({
    required this.hue,
    required this.saturation,
    required this.value,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Base color gradient (White to Hue color horizontally)
    final baseColor = HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();
    final horizontalGradient = LinearGradient(
      colors: [Colors.white, baseColor],
    );

    final horizPaint = Paint()
      ..shader = horizontalGradient.createShader(rect);
    canvas.drawRect(rect, horizPaint);

    // Black gradient vertically (Transparent to Black)
    const verticalGradient = LinearGradient(
      colors: [Colors.transparent, Colors.black],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final vertPaint = Paint()
      ..shader = verticalGradient.createShader(rect);
    canvas.drawRect(rect, vertPaint);

    // Draggable indicator thumb
    final thumbX = saturation * size.width;
    final thumbY = (1.0 - value) * size.height;

    final outerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final innerPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(Offset(thumbX, thumbY), 8, outerPaint);
    canvas.drawCircle(Offset(thumbX, thumbY), 7, innerPaint);
  }

  @override
  bool shouldRepaint(covariant ColorPickerGradientPainter oldDelegate) =>
      oldDelegate.hue != hue ||
      oldDelegate.saturation != saturation ||
      oldDelegate.value != value;
}
