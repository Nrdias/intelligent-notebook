import 'package:flutter/material.dart';

/// Dashed Selection Box Icon Widget for Canvas Toolbar.
class DashedBoxIcon extends StatelessWidget {
  const DashedBoxIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _DashedBorderPainter(),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    const dashLength = 3.0;
    const dashSpace = 2.5;

    _drawDashedBorder(canvas, rect, paint, dashLength, dashSpace);
  }

  void _drawDashedBorder(
    Canvas canvas,
    Rect rect,
    Paint paint,
    double dashLength,
    double dashSpace,
  ) {
    _drawDashLine(
        canvas, rect.topLeft, rect.topRight, paint, dashLength, dashSpace);
    _drawDashLine(
        canvas, rect.topRight, rect.bottomRight, paint, dashLength, dashSpace);
    _drawDashLine(canvas, rect.bottomRight, rect.bottomLeft, paint, dashLength,
        dashSpace);
    _drawDashLine(
        canvas, rect.bottomLeft, rect.topLeft, paint, dashLength, dashSpace);
  }

  void _drawDashLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    double dashLength,
    double dashSpace,
  ) {
    final dist = (end - start).distance;
    final unit = (end - start) / dist;
    double current = 0.0;

    while (current < dist) {
      final p1 = start + unit * current;
      final endDist = (current + dashLength).clamp(0.0, dist);
      final p2 = start + unit * endDist;
      canvas.drawLine(p1, p2, paint);
      current += dashLength + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
