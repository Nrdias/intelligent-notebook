import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/design_system/buttons/toolbar_icon_button.dart';
import '../../../../core/presentation/design_system/dialogs/color_palette_dialog.dart';
import '../../../../core/presentation/design_system/swatches/color_swatch.dart';
import '../../../../core/presentation/design_system/widgets/app_svg_icon.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/canvas_provider.dart';
import 'eraser_options_popup.dart';
import 'pen_options_popup.dart';
import 'toolbar/dashed_box_icon.dart';

class Toolbar extends ConsumerStatefulWidget {
  const Toolbar({super.key});

  @override
  ConsumerState<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends ConsumerState<Toolbar> {
  final GlobalKey _penKey = GlobalKey();
  final GlobalKey _highlighterKey = GlobalKey();
  final GlobalKey _eraserKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(canvasStateProvider);
    final notifier = ref.read(canvasStateProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Container(
      height: 54,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF18181C),
        border: Border(
          bottom: BorderSide(color: Color(0xFF27272A), width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Keyboard / Mode Switch
            ToolbarIconButton(
              icon: Icons.keyboard_alt_outlined,
              tooltip: l10n.keyboard,
              isActive: state.currentTool == CanvasTool.text,
              onTap: () => notifier.setTool(
                state.currentTool == CanvasTool.text
                    ? CanvasTool.pen
                    : CanvasTool.text,
              ),
            ),

            const SizedBox(width: 4),

            // 2. Pen / Pencil Tool
            ToolbarIconButton(
              key: _penKey,
              iconWidget: AppSvgIcon.pencil(
                size: 22,
                isSelected: state.currentTool == CanvasTool.pen,
                color: state.currentTool == CanvasTool.pen
                    ? Color(state.strokeColor)
                    : const Color(0xFFDDDDDF),
              ),
              tooltip: l10n.pencil,
              isActive: state.currentTool == CanvasTool.pen,
              onTap: () {
                if (state.currentTool != CanvasTool.pen) {
                  notifier.setTool(CanvasTool.pen);
                } else {
                  // Already selected -> Open Pen Size Options Popup
                  PenOptionsPopup.show(
                    context,
                    currentWidth: state.strokeWidth,
                    color: state.strokeColor,
                    onWidthChanged: (w) => notifier.setStrokeWidth(w),
                    anchorKey: _penKey,
                  );
                }
              },
            ),

            const SizedBox(width: 4),

            // 3. Highlighter Tool (Using AppSvgIcon.highlighter)
            ToolbarIconButton(
              key: _highlighterKey,
              iconWidget: AppSvgIcon.highlighter(
                size: 22,
                isSelected: state.currentTool == CanvasTool.highlighter,
                color: state.currentTool == CanvasTool.highlighter
                    ? Color(state.highlighterColor)
                    : const Color(0xFFDDDDDF),
              ),
              tooltip: l10n.highlighter,
              isActive: state.currentTool == CanvasTool.highlighter,
              onTap: () {
                if (state.currentTool != CanvasTool.highlighter) {
                  notifier.setTool(CanvasTool.highlighter);
                } else {
                  // Already selected -> Open Highlighter Size Options Popup
                  PenOptionsPopup.show(
                    context,
                    currentWidth: state.highlighterWidth,
                    color: state.highlighterColor,
                    isHighlighter: true,
                    onWidthChanged: (w) => notifier.setHighlighterWidth(w),
                    anchorKey: _highlighterKey,
                  );
                }
              },
            ),

            const SizedBox(width: 4),

            // 4. Eraser Tool (Using AppSvgIcon.erase)
            ToolbarIconButton(
              key: _eraserKey,
              iconWidget: AppSvgIcon.erase(
                size: 22,
                color: state.currentTool == CanvasTool.eraser
                    ? Colors.white
                    : const Color(0xFFDDDDDF),
              ),
              tooltip: state.eraserMode == EraserMode.area
                  ? l10n.eraserArea
                  : l10n.eraserStroke,
              isActive: state.currentTool == CanvasTool.eraser,
              onTap: () {
                if (state.currentTool != CanvasTool.eraser) {
                  notifier.setTool(CanvasTool.eraser);
                } else {
                  // Already selected -> Open Eraser Options Popup
                  EraserOptionsPopup.show(
                    context,
                    mode: state.eraserMode,
                    eraserRadius: state.eraserRadius,
                    onModeChanged: (m) => notifier.setEraserMode(m),
                    onRadiusChanged: (r) => notifier.setEraserRadius(r),
                    onClearAll: () => notifier.clear(),
                    anchorKey: _eraserKey,
                  );
                }
              },
            ),

            const SizedBox(width: 4),

            // 5. Selection (Dashed Box) Tool
            ToolbarIconButton(
              iconWidget: const DashedBoxIcon(),
              tooltip: l10n.selectionBox,
              isActive: state.currentTool == CanvasTool.selection,
              onTap: () => notifier.setTool(CanvasTool.selection),
            ),

            const SizedBox(width: 8),

            // 6. Vertical Separator
            Container(
              height: 24,
              width: 1.2,
              color: const Color(0xFF484850),
            ),

            const SizedBox(width: 10),

            // 7. Recent 5 Colors Palette
            ...List.generate(state.recentColors.length, (index) {
              final colorVal = state.recentColors[index];
              final isSelected = state.selectedColorIndex == index;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ColorSwatchWidget(
                  color: Color(colorVal),
                  isSelected: isSelected,
                  tooltip: '${l10n.colorPalette} ${index + 1}',
                  onTap: () async {
                    if (state.currentTool == CanvasTool.eraser ||
                        state.currentTool == CanvasTool.selection) {
                      notifier.setTool(CanvasTool.pen);
                    }

                    if (!isSelected) {
                      // Tap unselected color -> select it
                      notifier.selectRecentColor(index);
                    } else {
                      // Tap already selected color -> open Color Palette Dialog
                      final pickedColor = await ColorPaletteDialog.show(
                        context,
                        initialColor: Color(colorVal),
                      );
                      if (pickedColor != null) {
                        notifier.updateRecentColor(
                            index, pickedColor.toARGB32());
                      }
                    }
                  },
                ),
              );
            }),

            const SizedBox(width: 10),

            // 8. Undo & Redo Buttons
            ToolbarIconButton(
              iconWidget: AppSvgIcon.undo(
                size: 20,
                color: state.canUndo ? const Color(0xFFDDDDDF) : Colors.white24,
              ),
              tooltip: l10n.undo,
              isEnabled: state.canUndo,
              onTap: state.canUndo ? () => notifier.undo() : null,
            ),
            const SizedBox(width: 2),
            ToolbarIconButton(
              iconWidget: AppSvgIcon.redo(
                size: 20,
                color: state.canRedo ? const Color(0xFFDDDDDF) : Colors.white24,
              ),
              tooltip: l10n.redo,
              isEnabled: state.canRedo,
              onTap: state.canRedo ? () => notifier.redo() : null,
            ),
            const SizedBox(width: 8),
            Container(
              height: 24,
              width: 1.2,
              color: const Color(0xFF484850),
            ),
            const SizedBox(width: 4),
            // Hand Ignore / Palm Rejection Toggle Button
            ToolbarIconButton(
              iconWidget: state.isFingerDrawingEnabled
                  ? AppSvgIcon.touch(
                      size: 20,
                      color: const Color(0xFFDDDDDF),
                    )
                  : AppSvgIcon.doNotTouch(
                      size: 20,
                      color: Colors.white,
                    ),
              tooltip: state.isFingerDrawingEnabled
                  ? l10n.fingerDrawing
                  : l10n.palmRejection,
              isActive: !state.isFingerDrawingEnabled,
              onTap: () {
                notifier.toggleFingerDrawing();
                final isEnabled = !state.isFingerDrawingEnabled;
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEnabled
                          ? l10n.fingerDrawingEnabled
                          : l10n.palmRejectionActive,
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
