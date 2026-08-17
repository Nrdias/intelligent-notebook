import 'package:flutter/material.dart';

/// Scoped Highlighter Button Widget for Canvas Toolbar.
class HighlighterButton extends StatelessWidget {
  final bool isActive;
  final Color color;
  final String? tooltip;
  final VoidCallback onTap;

  const HighlighterButton({
    super.key,
    required this.isActive,
    required this.color,
    this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = Material(
      color: isActive ? const Color(0xFF404048) : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: CustomPaint(
            size: const Size(22, 22),
            painter: _HighlighterIconPainter(tipColor: color),
          ),
        ),
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      button = Tooltip(
        message: tooltip!,
        preferBelow: true,
        verticalOffset: 24,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C30),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: button,
      );
    }

    return button;
  }
}

class _HighlighterIconPainter extends CustomPainter {
  final Color tipColor;

  _HighlighterIconPainter({required this.tipColor});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final tipPaint = Paint()
      ..color = tipColor
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.85)
      ..lineTo(size.width * 0.75, size.height * 0.85)
      ..lineTo(size.width * 0.75, size.height * 0.40)
      ..lineTo(size.width * 0.55, size.height * 0.15)
      ..lineTo(size.width * 0.25, size.height * 0.40)
      ..close();

    final tipPath = Path()
      ..moveTo(size.width * 0.30, size.height * 0.35)
      ..lineTo(size.width * 0.55, size.height * 0.15)
      ..lineTo(size.width * 0.70, size.height * 0.35)
      ..close();

    canvas.drawPath(tipPath, tipPaint);
    canvas.drawPath(path, bodyPaint);
  }

  @override
  bool shouldRepaint(covariant _HighlighterIconPainter oldDelegate) =>
      oldDelegate.tipColor != tipColor;
}
