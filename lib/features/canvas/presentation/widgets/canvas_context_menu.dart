import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/design_system/widgets/app_svg_icon.dart';
import '../providers/canvas_provider.dart';

class CanvasContextMenu extends ConsumerWidget {
  final Offset position;

  const CanvasContextMenu({super.key, required this.position});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(canvasStateProvider);
    final notifier = ref.read(canvasStateProvider.notifier);

    final screenSize = MediaQuery.of(context).size;
    const menuWidth = 180.0;
    const menuHeight = 150.0;

    // Clamp menu to screen bounds
    final left = position.dx.clamp(12.0, screenSize.width - menuWidth - 12.0);
    final top = position.dy.clamp(12.0, screenSize.height - menuHeight - 12.0);

    final hasClipboard = state.clipboardStrokes.isNotEmpty;
    final hasStrokes = state.currentStrokes.isNotEmpty;

    // Target position in canvas coordinates
    final localCanvasPos = position - state.panOffset;

    return Stack(
      children: [
        // Transparent barrier to dismiss on tap outside
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => notifier.hideContextMenu(),
            onPanStart: (_) => notifier.hideContextMenu(),
            child: Container(color: Colors.transparent),
          ),
        ),

        // Context Menu Card
        Positioned(
          left: left,
          top: top,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(14),
            color: const Color(0xFF26262A),
            child: Container(
              width: menuWidth,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF3F3F46)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ContextMenuItem(
                    icon: Icons.content_paste_rounded,
                    label: 'Paste',
                    enabled: hasClipboard,
                    onTap: () {
                      notifier.hideContextMenu();
                      notifier.pasteClipboard(targetPosition: localCanvasPos);
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFF3F3F46)),
                  _ContextMenuItem(
                    icon: Icons.select_all_rounded,
                    label: 'Select All',
                    enabled: hasStrokes,
                    onTap: () {
                      notifier.hideContextMenu();
                      notifier.selectAll();
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFF3F3F46)),
                  _ContextMenuItem(
                    iconWidget: AppSvgIcon.trash(
                      size: 18,
                      color: !hasStrokes ? Colors.white30 : Colors.redAccent,
                    ),
                    label: 'Clear All',
                    enabled: hasStrokes,
                    isDestructive: true,
                    onTap: () {
                      notifier.hideContextMenu();
                      notifier.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContextMenuItem extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final String label;
  final bool enabled;
  final bool isDestructive;
  final VoidCallback onTap;

  const _ContextMenuItem({
    this.icon,
    this.iconWidget,
    required this.label,
    this.enabled = true,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = !enabled
        ? Colors.white30
        : (isDestructive ? Colors.redAccent : Colors.white);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            iconWidget ?? Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
