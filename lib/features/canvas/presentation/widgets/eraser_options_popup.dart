import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/presentation/design_system/pills/preset_pill.dart';
import '../../../../core/presentation/design_system/widgets/app_svg_icon.dart';
import '../providers/canvas_provider.dart';
import 'eraser_options_popup/live_eraser_preview_circle.dart';

class EraserOptionsPopup extends StatefulWidget {
  final EraserMode initialMode;
  final double initialRadius;
  final ValueChanged<EraserMode> onModeChanged;
  final ValueChanged<double> onRadiusChanged;
  final VoidCallback onClearAll;

  const EraserOptionsPopup({
    super.key,
    required this.initialMode,
    required this.initialRadius,
    required this.onModeChanged,
    required this.onRadiusChanged,
    required this.onClearAll,
  });

  static void show(
    BuildContext context, {
    required EraserMode mode,
    required double eraserRadius,
    required ValueChanged<EraserMode> onModeChanged,
    required ValueChanged<double> onRadiusChanged,
    required VoidCallback onClearAll,
    required GlobalKey anchorKey,
  }) {
    final renderBox =
        anchorKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;

    if (renderBox == null || overlay == null) return;

    final target = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
    final targetSize = renderBox.size;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              left: (target.dx + targetSize.width / 2 - 130)
                  .clamp(16.0, overlay.size.width - 276.0),
              top: target.dy + targetSize.height + 8,
              child: Material(
                color: Colors.transparent,
                child: EraserOptionsPopup(
                  initialMode: mode,
                  initialRadius: eraserRadius,
                  onModeChanged: onModeChanged,
                  onRadiusChanged: onRadiusChanged,
                  onClearAll: () {
                    Navigator.of(context).pop();
                    onClearAll();
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  State<EraserOptionsPopup> createState() => _EraserOptionsPopupState();
}

class _EraserOptionsPopupState extends State<EraserOptionsPopup> {
  late EraserMode _mode;
  late double _eraserRadius;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _eraserRadius = widget.initialRadius;
  }

  void _updateMode(EraserMode mode) {
    setState(() {
      _mode = mode;
    });
    widget.onModeChanged(mode);
  }

  void _updateRadius(double radius) {
    setState(() {
      _eraserRadius = radius;
    });
    widget.onRadiusChanged(radius);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const presets = [10.0, 20.0, 32.0, 48.0];

    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF232328),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFF383840)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.eraserOptions,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Eraser Mode Selector (Erase stroke vs Erase area)
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF18181C),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(2),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _updateMode(EraserMode.stroke),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _mode == EraserMode.stroke
                            ? const Color(0xFF0D59F2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        l10n.eraseStroke,
                        style: TextStyle(
                          color: _mode == EraserMode.stroke
                              ? Colors.white
                              : Colors.white60,
                          fontSize: 11,
                          fontWeight: _mode == EraserMode.stroke
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _updateMode(EraserMode.area),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _mode == EraserMode.area
                            ? const Color(0xFF0D59F2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        l10n.eraseArea,
                        style: TextStyle(
                          color: _mode == EraserMode.area
                              ? Colors.white
                              : Colors.white60,
                          fontSize: 11,
                          fontWeight: _mode == EraserMode.area
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // If Erase Area is selected: show size selection using LiveEraserPreviewCircle
          if (_mode == EraserMode.area) ...[
            const SizedBox(height: 14),
            LiveEraserPreviewCircle(radius: _eraserRadius),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: const Color(0xFF3E3E48),
                      thumbColor: Colors.white,
                      overlayColor: Colors.white.withValues(alpha: 0.15),
                      trackHeight: 4,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 8),
                    ),
                    child: Slider(
                      value: _eraserRadius.clamp(5.0, 50.0),
                      min: 5.0,
                      max: 50.0,
                      onChanged: (val) {
                        _updateRadius(val);
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 32,
                  child: Text(
                    '${_eraserRadius.round()}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Quick presets using PresetPill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: presets.map((p) {
                final isSelected = (_eraserRadius - p).abs() < 1.0;
                return PresetPill(
                  label: '${p.round()}',
                  isActive: isSelected,
                  onTap: () => _updateRadius(p),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 14),
          // Clear all button
          ElevatedButton.icon(
            onPressed: widget.onClearAll,
            icon: AppSvgIcon.trash(size: 18, color: Colors.redAccent),
            label: Text(
              l10n.clearPage,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E1C20),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
