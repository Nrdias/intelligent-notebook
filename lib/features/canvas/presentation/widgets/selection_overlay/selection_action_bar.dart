import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/presentation/design_system/dialogs/color_palette_dialog.dart';
import '../../../../../core/presentation/design_system/widgets/app_svg_icon.dart';
import '../../providers/canvas_provider.dart';

/// Floating Context Action Menu Bar for Selection Overlay.
class SelectionActionBar extends ConsumerWidget {
  final CanvasState state;
  final CanvasNotifier notifier;

  const SelectionActionBar({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF242429),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFF3E3E48)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SelectionActionButton(
            icon: Icons.content_cut_rounded,
            label: l10n.cut,
            onTap: () => notifier.cutSelection(),
          ),
          _SelectionActionButton(
            icon: Icons.content_copy_rounded,
            label: l10n.copy,
            onTap: () => notifier.copySelection(),
          ),
          if (state.clipboardStrokes.isNotEmpty)
            _SelectionActionButton(
              icon: Icons.content_paste_rounded,
              label: l10n.paste,
              onTap: () => notifier.pasteClipboard(),
            ),
          _SelectionActionButton(
            icon: Icons.copy_all_rounded,
            label: l10n.duplicate,
            onTap: () => notifier.duplicateSelection(),
          ),
          _SelectionActionButton(
            icon: Icons.palette_outlined,
            label: l10n.color,
            onTap: () async {
              final pickedColor = await ColorPaletteDialog.show(
                context,
                initialColor: Color(state.strokeColor),
              );
              if (pickedColor != null) {
                notifier.changeSelectionColor(pickedColor.toARGB32());
              }
            },
          ),
          _SelectionActionButton(
            iconWidget: AppSvgIcon.trash(size: 18, color: Colors.redAccent),
            label: l10n.delete,
            isDestructive: true,
            onTap: () => notifier.deleteSelection(),
          ),
          _SelectionActionButton(
            iconWidget: AppSvgIcon.close(size: 18, color: Colors.white),
            label: l10n.deselect,
            onTap: () => notifier.clearSelection(),
          ),
        ],
      ),
    );
  }
}

class _SelectionActionButton extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final String label;
  final bool isDestructive;
  final VoidCallback onTap;

  const _SelectionActionButton({
    this.icon,
    this.iconWidget,
    required this.label,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.redAccent : Colors.white;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget ?? Icon(icon, size: 18, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color.withValues(alpha: 0.9),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
