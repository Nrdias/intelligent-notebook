import 'package:flutter/material.dart';

/// Dashed Selection Bounding Box Painter with Corner Handles.
class DashedSelectionPainter extends CustomPainter {
  final Rect rect;

  DashedSelectionPainter({required this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    if (rect.isEmpty) return;

    final fillPaint = Paint()
      ..color = const Color(0xFF0D59F2).withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, fillPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFF0D59F2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    _drawDashedRect(canvas, rect, borderPaint);

    // Draw 4 corner handles
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final handleBorder = Paint()
      ..color = const Color(0xFF0D59F2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final corners = [
      rect.topLeft,
      rect.topRight,
      rect.bottomLeft,
      rect.bottomRight,
    ];

    for (final corner in corners) {
      canvas.drawCircle(corner, 4.5, handlePaint);
      canvas.drawCircle(corner, 4.5, handleBorder);
    }
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 4.0;

    _drawDashedLine(canvas, rect.topLeft, rect.topRight, dashWidth, dashSpace, paint);
    _drawDashedLine(canvas, rect.topRight, rect.bottomRight, dashWidth, dashSpace, paint);
    _drawDashedLine(canvas, rect.bottomRight, rect.bottomLeft, dashWidth, dashSpace, paint);
    _drawDashedLine(canvas, rect.bottomLeft, rect.topLeft, dashWidth, dashSpace, paint);
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    double dashWidth,
    double dashSpace,
    Paint paint,
  ) {
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final totalDistance = (p2 - p1).distance;
    if (totalDistance == 0) return;
    final unitX = dx / totalDistance;
    final unitY = dy / totalDistance;

    double currentDist = 0.0;
    while (currentDist < totalDistance) {
      final start = Offset(
        p1.dx + unitX * currentDist,
        p1.dy + unitY * currentDist,
      );
      final endDist = (currentDist + dashWidth).clamp(0.0, totalDistance);
      final end = Offset(
        p1.dx + unitX * endDist,
        p1.dy + unitY * endDist,
      );
      canvas.drawLine(start, end, paint);
      currentDist += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant DashedSelectionPainter oldDelegate) =>
      oldDelegate.rect != rect;
}
