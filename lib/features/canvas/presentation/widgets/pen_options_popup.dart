import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/presentation/design_system/pills/preset_pill.dart';
import 'pen_options_popup/live_pen_preview_box.dart';

class PenOptionsPopup extends StatefulWidget {
  final double initialWidth;
  final int color;
  final bool isHighlighter;
  final ValueChanged<double> onWidthChanged;

  const PenOptionsPopup({
    super.key,
    required this.initialWidth,
    required this.color,
    this.isHighlighter = false,
    required this.onWidthChanged,
  });

  static void show(
    BuildContext context, {
    required double currentWidth,
    required int color,
    bool isHighlighter = false,
    required ValueChanged<double> onWidthChanged,
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
              left: (target.dx + targetSize.width / 2 - 120)
                  .clamp(16.0, overlay.size.width - 256.0),
              top: target.dy + targetSize.height + 8,
              child: Material(
                color: Colors.transparent,
                child: PenOptionsPopup(
                  initialWidth: currentWidth,
                  color: color,
                  isHighlighter: isHighlighter,
                  onWidthChanged: onWidthChanged,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  State<PenOptionsPopup> createState() => _PenOptionsPopupState();
}

class _PenOptionsPopupState extends State<PenOptionsPopup> {
  late double _currentWidth;

  @override
  void initState() {
    super.initState();
    _currentWidth = widget.initialWidth;
  }

  void _updateWidth(double width) {
    setState(() {
      _currentWidth = width;
    });
    widget.onWidthChanged(width);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final displayColor = widget.isHighlighter
        ? Color(widget.color).withValues(alpha: 0.55)
        : Color(widget.color);

    final presets = widget.isHighlighter
        ? const [10.0, 16.0, 24.0, 36.0, 48.0]
        : const [1.0, 3.0, 6.0, 10.0, 18.0, 30.0];

    final maxVal = widget.isHighlighter ? 60.0 : 50.0;

    return Container(
      width: 240,
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
        children: [
          Text(
            widget.isHighlighter ? l10n.highlighterThickness : l10n.penThickness,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          // Live Size Preview Box
          LivePenPreviewBox(
            width: _currentWidth,
            displayColor: displayColor,
            isHighlighter: widget.isHighlighter,
          ),
          const SizedBox(height: 12),
          // Slider with numeric label
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
                    value: _currentWidth.clamp(1.0, maxVal),
                    min: 1.0,
                    max: maxVal,
                    onChanged: (val) {
                      _updateWidth(val);
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 32,
                child: Text(
                  '${_currentWidth.round()}',
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
          const SizedBox(height: 8),
          // Quick presets using PresetPill
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: presets.map((p) {
                final isSelected = (_currentWidth - p).abs() < 1.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: PresetPill(
                    label: '${p.round()}',
                    isActive: isSelected,
                    onTap: () => _updateWidth(p),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
