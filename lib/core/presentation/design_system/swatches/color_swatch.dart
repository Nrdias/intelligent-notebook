import 'package:flutter/material.dart';

/// Reusable circular color swatch component with selection highlight & tooltip.
class ColorSwatchWidget extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final String? tooltip;
  final VoidCallback onTap;

  const ColorSwatchWidget({
    super.key,
    required this.color,
    required this.isSelected,
    this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget swatch = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Colors.white, width: 2.8)
              : Border.all(color: const Color(0xFF55555C), width: 1.2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      swatch = Tooltip(
        message: tooltip!,
        preferBelow: true,
        verticalOffset: 20,
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
        child: swatch,
      );
    }

    return swatch;
  }
}
