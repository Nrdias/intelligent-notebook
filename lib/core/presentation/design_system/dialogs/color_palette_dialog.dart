import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

import 'color_picker/color_picker_gradient_painter.dart';
import 'color_picker/dotted_line_painter.dart';
import 'color_picker/hue_slider_painter.dart';

/// Reusable design system Color Palette Dialog with Swatches & Spectrum tabs.
class ColorPaletteDialog extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorSelected;

  const ColorPaletteDialog({
    super.key,
    required this.initialColor,
    required this.onColorSelected,
  });

  static Future<Color?> show(
    BuildContext context, {
    required Color initialColor,
  }) {
    return showDialog<Color>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => ColorPaletteDialog(
        initialColor: initialColor,
        onColorSelected: (color) => Navigator.of(context).pop(color),
      ),
    );
  }

  @override
  State<ColorPaletteDialog> createState() => _ColorPaletteDialogState();
}

/// Backward compatibility alias
typedef SamsungColorPaletteDialog = ColorPaletteDialog;

class _ColorPaletteDialogState extends State<ColorPaletteDialog> {
  int _selectedTab = 0; // 0 = Amostras (Swatches), 1 = Espectro (Spectrum)
  late Color _currentColor;
  late HSVColor _hsvColor;

  static const int _gridRows = 10;
  static const int _gridCols = 12;

  final List<Color> _bottomPresets = const [
    Color(0xFF00382B),
    Color(0xFF006666),
    Color(0xFFE50000),
    Color(0xFFC70066),
    Color(0xFF0D59F2),
  ];

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
    _hsvColor = HSVColor.fromColor(widget.initialColor);
  }

  Color _generateMatrixColor(int row, int col) {
    if (col == 0) {
      final lightness = 1.0 - (row / (_gridRows - 1));
      final val = (lightness * 255).round().clamp(0, 255);
      return Color.fromARGB(255, val, val, val);
    }

    const hueStep = 360.0 / (_gridCols - 1);
    final hue = (col - 1) * hueStep;

    double saturation;
    double value;

    if (row < 4) {
      saturation = 0.20 + (row * 0.22);
      value = 1.0;
    } else if (row == 4) {
      saturation = 1.0;
      value = 1.0;
    } else {
      saturation = 1.0;
      value = 1.0 - ((row - 4) * 0.15);
      if (value < 0.2) value = 0.2;
    }

    return HSVColor.fromAHSV(1.0, hue, saturation, value).toColor();
  }

  void _setColor(Color color) {
    setState(() {
      _currentColor = color;
      _hsvColor = HSVColor.fromColor(color);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hexString =
        '#${_currentColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 380,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C20),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Tab Header: "Amostras" & "Espectro"
            Container(
              padding: const EdgeInsets.only(top: 14, left: 16, right: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _TabHeaderButton(
                      label: l10n.amostras,
                      isSelected: _selectedTab == 0,
                      onTap: () => setState(() => _selectedTab = 0),
                    ),
                  ),
                  Expanded(
                    child: _TabHeaderButton(
                      label: l10n.espectro,
                      isSelected: _selectedTab == 1,
                      onTap: () => setState(() => _selectedTab = 1),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Color(0xFF2E2E34), height: 1),

            // Tab Content Body
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _selectedTab == 0
                    ? _buildAmostrasGrid()
                    : _buildEspectroPicker(),
              ),
            ),

            // Bottom Section: Color Details, Preset Row & Eyedropper
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Dual Comparison Box & Hex / RGB Text
                  Row(
                    children: [
                      // Dual Color Comparison Box (Initial vs Current)
                      Container(
                        width: 50,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF3E3E46),
                            width: 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(color: widget.initialColor),
                            ),
                            Expanded(
                              child: Container(color: _currentColor),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Hex & RGB Values Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Hexadecimal',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  hexString,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                _RGBLabelValue(
                                  label: 'V:',
                                  value: ( _currentColor.r * 255).round(),
                                ),
                                const SizedBox(width: 10),
                                _RGBLabelValue(
                                  label: 'V:',
                                  value: ( _currentColor.g * 255).round(),
                                ),
                                const SizedBox(width: 10),
                                _RGBLabelValue(
                                  label: 'A:',
                                  value: ( _currentColor.b * 255).round(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Dotted Separator
                  const SizedBox(
                    height: 2,
                    width: double.infinity,
                    child: CustomPaint(painter: DottedLinePainter()),
                  ),

                  const SizedBox(height: 14),

                  // Bottom Preset Favorites Row + Eyedropper Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: _bottomPresets.map((color) {
                          final isSel =
                              _currentColor.toARGB32() == color.toARGB32();
                          return GestureDetector(
                            onTap: () => _setColor(color),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSel
                                    ? Border.all(color: Colors.white, width: 2.5)
                                    : Border.all(
                                        color: const Color(0xFF44444C),
                                        width: 1,
                                      ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      // Eyedropper Icon Button
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2C2C32),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.colorize_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Action Buttons: "Cancelar" & "Concluir"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFF2E2E34), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFA0A0A8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: Text(l10n.cancel, style: const TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () =>
                        widget.onColorSelected(_currentColor),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D59F2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      l10n.done,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmostrasGrid() {
    return AspectRatio(
      aspectRatio: 1.35,
      child: GridView.builder(
        key: const ValueKey('AmostrasGrid'),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _gridCols,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
        ),
        itemCount: _gridRows * _gridCols,
        itemBuilder: (context, index) {
          final row = index ~/ _gridCols;
          final col = index % _gridCols;
          final cellColor = _generateMatrixColor(row, col);
          final isSelected =
              _currentColor.toARGB32() == cellColor.toARGB32();

          return GestureDetector(
            onTap: () => _setColor(cellColor),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              decoration: BoxDecoration(
                color: cellColor,
                borderRadius: BorderRadius.circular(3),
                border: isSelected
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEspectroPicker() {
    return AspectRatio(
      key: const ValueKey('EspectroPicker'),
      aspectRatio: 1.35,
      child: Column(
        children: [
          // 2D Saturation / Value Gradient Box
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;

                void updateFromPosition(Offset localOffset) {
                  final newSat = (localOffset.dx / width).clamp(0.0, 1.0);
                  final newVal =
                      (1.0 - (localOffset.dy / height)).clamp(0.0, 1.0);

                  setState(() {
                    _hsvColor =
                        _hsvColor.withSaturation(newSat).withValue(newVal);
                    _currentColor = _hsvColor.toColor();
                  });
                }

                return GestureDetector(
                  onPanStart: (details) =>
                      updateFromPosition(details.localPosition),
                  onPanUpdate: (details) =>
                      updateFromPosition(details.localPosition),
                  onTapDown: (details) =>
                      updateFromPosition(details.localPosition),
                  child: CustomPaint(
                    size: Size(width, height),
                    painter: ColorPickerGradientPainter(
                      hue: _hsvColor.hue,
                      saturation: _hsvColor.saturation,
                      value: _hsvColor.value,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Rainbow Hue Slider
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              void updateHue(Offset localOffset) {
                final newHue = ((localOffset.dx / width) * 360.0)
                    .clamp(0.0, 360.0);
                setState(() {
                  _hsvColor = _hsvColor.withHue(newHue);
                  _currentColor = _hsvColor.toColor();
                });
              }

              return GestureDetector(
                onPanStart: (details) => updateHue(details.localPosition),
                onPanUpdate: (details) => updateHue(details.localPosition),
                onTapDown: (details) => updateHue(details.localPosition),
                child: SizedBox(
                  height: 16,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: HueSliderPainter(hue: _hsvColor.hue),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TabHeaderButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabHeaderButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF8E8E93),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Container(
            height: 2,
            color: isSelected ? const Color(0xFF0D59F2) : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class _RGBLabelValue extends StatelessWidget {
  final String label;
  final int value;

  const _RGBLabelValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 10,
          ),
        ),
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
