import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/design_system/dialogs/color_palette_dialog.dart';
import '../providers/canvas_provider.dart';

class TextFormattingToolbar extends ConsumerWidget {
  const TextFormattingToolbar({super.key});

  void _insertListPrefix(WidgetRef ref, String prefix) {
    final notifier = ref.read(canvasStateProvider.notifier);
    final state = ref.read(canvasStateProvider);

    final currentText = state.canvasText;
    if (currentText.isEmpty || currentText.endsWith('\n')) {
      notifier.updateCanvasText('$currentText$prefix');
    } else {
      notifier.updateCanvasText('$currentText\n$prefix');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(canvasStateProvider);
    final notifier = ref.read(canvasStateProvider.notifier);

    const fontSizes = [12.0, 14.0, 17.0, 20.0, 24.0, 28.0, 32.0, 40.0];

    return Material(
      elevation: 12,
      color: const Color(0xFF1E1E22),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E22),
          border: Border(
            top: BorderSide(color: Color(0xFF33333A), width: 1),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // 1. Checkbox List Toggle
              _FormattingButton(
                icon: Icons.check_box_outlined,
                tooltip: 'Checkbox List',
                onTap: () => _insertListPrefix(ref, '[ ] '),
              ),

              const VerticalDivider(width: 12, indent: 10, endIndent: 10, color: Color(0xFF3F3F46)),

              // 2. Preset Style Dropdown (Title / Subtitle / Body)
              PopupMenuButton<double>(
                tooltip: 'Text Style Preset',
                color: const Color(0xFF26262A),
                icon: const Icon(Icons.text_fields_rounded, color: Colors.white, size: 20),
                onSelected: (size) => notifier.setTextFontSize(size),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 26.0,
                    child: Text('Title (26pt)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const PopupMenuItem(
                    value: 20.0,
                    child: Text('Subtitle (20pt)', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                  const PopupMenuItem(
                    value: 17.0,
                    child: Text('Body (17pt)', style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ],
              ),

              // 3. Font Size Dropdown Button (e.g. "17 v")
              PopupMenuButton<double>(
                tooltip: 'Font Size',
                color: const Color(0xFF26262A),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A30),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF3F3F46)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${state.textFontSize.round()}',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 18),
                    ],
                  ),
                ),
                onSelected: (size) => notifier.setTextFontSize(size),
                itemBuilder: (context) => fontSizes.map((size) {
                  return PopupMenuItem<double>(
                    value: size,
                    child: Text(
                      '${size.round()} pt',
                      style: TextStyle(
                        color: state.textFontSize == size ? const Color(0xFF0D59F2) : Colors.white,
                        fontWeight: state.textFontSize == size ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(width: 6),
              const VerticalDivider(width: 12, indent: 10, endIndent: 10, color: Color(0xFF3F3F46)),

              // 4. Bold (B)
              _FormattingButton(
                icon: Icons.format_bold_rounded,
                tooltip: 'Bold',
                isActive: state.isBold,
                onTap: () => notifier.toggleBold(),
              ),

              // 5. Italic (I)
              _FormattingButton(
                icon: Icons.format_italic_rounded,
                tooltip: 'Italic',
                isActive: state.isItalic,
                onTap: () => notifier.toggleItalic(),
              ),

              // 6. Underline (U)
              _FormattingButton(
                icon: Icons.format_underlined_rounded,
                tooltip: 'Underline',
                isActive: state.isUnderline,
                onTap: () => notifier.toggleUnderline(),
              ),

              // 7. Strikethrough (S)
              _FormattingButton(
                icon: Icons.strikethrough_s_rounded,
                tooltip: 'Strikethrough',
                isActive: state.isStrikethrough,
                onTap: () => notifier.toggleStrikethrough(),
              ),

              const VerticalDivider(width: 12, indent: 10, endIndent: 10, color: Color(0xFF3F3F46)),

              // 8. Bullet List (:=)
              _FormattingButton(
                icon: Icons.format_list_bulleted_rounded,
                tooltip: 'Bullet List',
                onTap: () => _insertListPrefix(ref, '• '),
              ),

              // 9. Numbered List (1.=)
              _FormattingButton(
                icon: Icons.format_list_numbered_rounded,
                tooltip: 'Numbered List',
                onTap: () => _insertListPrefix(ref, '1. '),
              ),

              // 10. Alignment Dropdown Button
              PopupMenuButton<TextAlign>(
                tooltip: 'Text Alignment',
                color: const Color(0xFF26262A),
                icon: Icon(
                  state.textAlign == TextAlign.center
                      ? Icons.format_align_center_rounded
                      : state.textAlign == TextAlign.right
                          ? Icons.format_align_right_rounded
                          : state.textAlign == TextAlign.justify
                              ? Icons.format_align_justify_rounded
                              : Icons.format_align_left_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onSelected: (align) => notifier.setTextAlign(align),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: TextAlign.left,
                    child: Row(children: [Icon(Icons.format_align_left_rounded, color: Colors.white, size: 18), SizedBox(width: 8), Text('Left', style: TextStyle(color: Colors.white))]),
                  ),
                  PopupMenuItem(
                    value: TextAlign.center,
                    child: Row(children: [Icon(Icons.format_align_center_rounded, color: Colors.white, size: 18), SizedBox(width: 8), Text('Center', style: TextStyle(color: Colors.white))]),
                  ),
                  PopupMenuItem(
                    value: TextAlign.right,
                    child: Row(children: [Icon(Icons.format_align_right_rounded, color: Colors.white, size: 18), SizedBox(width: 8), Text('Right', style: TextStyle(color: Colors.white))]),
                  ),
                  PopupMenuItem(
                    value: TextAlign.justify,
                    child: Row(children: [Icon(Icons.format_align_justify_rounded, color: Colors.white, size: 18), SizedBox(width: 8), Text('Justify', style: TextStyle(color: Colors.white))]),
                  ),
                ],
              ),

              // 11. Text Color Picker (A)
              _FormattingButton(
                icon: Icons.format_color_text_rounded,
                tooltip: 'Text Color',
                iconColor: Color(state.textColor),
                onTap: () async {
                  final picked = await ColorPaletteDialog.show(
                    context,
                    initialColor: Color(state.textColor),
                  );
                  if (picked != null) {
                    notifier.setCanvasTextColor(picked.toARGB32());
                  }
                },
              ),

              const SizedBox(width: 4),
              const VerticalDivider(width: 12, indent: 10, endIndent: 10, color: Color(0xFF3F3F46)),

              // 12. Close Formatting / Dismiss Keyboard
              _FormattingButton(
                icon: Icons.keyboard_hide_rounded,
                tooltip: 'Close Keyboard',
                onTap: () {
                  FocusScope.of(context).unfocus();
                  notifier.setTool(CanvasTool.pen);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormattingButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final Color? iconColor;
  final VoidCallback onTap;

  const _FormattingButton({
    required this.icon,
    required this.tooltip,
    this.isActive = false,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isActive ? const Color(0xFF0D59F2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 20,
              color: isActive
                  ? Colors.white
                  : (iconColor ?? Colors.white.withValues(alpha: 0.85)),
            ),
          ),
        ),
      ),
    );
  }
}
