import 'package:flutter/material.dart';

/// Live Preview Circle for Eraser Area Options Popup.
class LiveEraserPreviewCircle extends StatelessWidget {
  final double radius;

  const LiveEraserPreviewCircle({
    super.key,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF18181C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Container(
          width: (radius * 2).clamp(4.0, 46.0),
          height: (radius * 2).clamp(4.0, 46.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey, width: 1),
          ),
        ),
      ),
    );
  }
}
