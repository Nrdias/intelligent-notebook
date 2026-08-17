import 'package:flutter/material.dart';

/// Live Preview Box for Pen/Highlighter Options Popup.
class LivePenPreviewBox extends StatelessWidget {
  final double width;
  final Color displayColor;
  final bool isHighlighter;

  const LivePenPreviewBox({
    super.key,
    required this.width,
    required this.displayColor,
    required this.isHighlighter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF18181C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Container(
          width: width.clamp(2.0, 46.0),
          height: isHighlighter ? 18.0 : width.clamp(2.0, 46.0),
          decoration: BoxDecoration(
            color: displayColor,
            borderRadius: isHighlighter
                ? BorderRadius.circular(4)
                : BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}
