import 'package:flutter/material.dart';

/// 2D Rainbow Hue Slider Painter with thumb indicator.
class HueSliderPainter extends CustomPainter {
  final double hue;

  const HueSliderPainter({required this.hue});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const rainbow = [
      Color(0xFFFF0000),
      Color(0xFFFFFF00),
      Color(0xFF00FF00),
      Color(0xFF00FFFF),
      Color(0xFF0000FF),
      Color(0xFFFF00FF),
      Color(0xFFFF0000),
    ];

    const gradient = LinearGradient(colors: rainbow);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      paint,
    );

    final thumbX = (hue / 360.0) * size.width;
    final thumbPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final thumbBorder = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(Offset(thumbX, size.height / 2), 10, thumbPaint);
    canvas.drawCircle(Offset(thumbX, size.height / 2), 10, thumbBorder);
  }

  @override
  bool shouldRepaint(covariant HueSliderPainter oldDelegate) =>
      oldDelegate.hue != hue;
}
