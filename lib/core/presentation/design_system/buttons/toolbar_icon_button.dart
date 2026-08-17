import 'package:flutter/material.dart';

/// Reusable icon button component for toolbars with active state & tooltip support.
class ToolbarIconButton extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final String? tooltip;
  final bool isActive;
  final bool isEnabled;
  final VoidCallback? onTap;

  const ToolbarIconButton({
    super.key,
    this.icon,
    this.iconWidget,
    this.tooltip,
    this.isActive = false,
    this.isEnabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = isEnabled ? 1.0 : 0.35;

    Widget button = Opacity(
      opacity: opacity,
      child: Material(
        color: isActive ? const Color(0xFF404048) : Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: isEnabled ? onTap : null,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: iconWidget ??
                Icon(
                  icon,
                  size: 22,
                  color: isActive ? Colors.white : const Color(0xFFDDDDDF),
                ),
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
