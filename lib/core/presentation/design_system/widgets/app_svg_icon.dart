import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jovial_svg/jovial_svg.dart';

/// AppSvgIcon displays vector icons compiled as `.si` binary files
/// using the [jovial_svg] package for optimized asset loading and performance.
class AppSvgIcon extends StatelessWidget {
  final String assetName;
  final double size;
  final Color? color;
  final BoxFit fit;

  const AppSvgIcon({
    super.key,
    required this.assetName,
    this.size = 24.0,
    this.color,
    this.fit = BoxFit.contain,
  });

  factory AppSvgIcon.chevron({Key? key, double size = 24.0, Color? color}) =>
      AppSvgIcon(key: key, assetName: 'assets/icons/chevron.si', size: size, color: color);

  factory AppSvgIcon.close({Key? key, double size = 24.0, Color? color}) =>
      AppSvgIcon(key: key, assetName: 'assets/icons/close.si', size: size, color: color);

  factory AppSvgIcon.doNotTouch({Key? key, double size = 24.0, Color? color}) =>
      AppSvgIcon(key: key, assetName: 'assets/icons/do-not-touch.si', size: size, color: color);

  factory AppSvgIcon.erase({Key? key, double size = 24.0, Color? color}) =>
      AppSvgIcon(key: key, assetName: 'assets/icons/erase.si', size: size, color: color);

  factory AppSvgIcon.eraser({Key? key, double size = 24.0, Color? color}) =>
      AppSvgIcon.erase(key: key, size: size, color: color);

  factory AppSvgIcon.highlighterFilled({Key? key, double size = 24.0, Color? color}) =>
      AppSvgIcon(key: key, assetName: 'assets/icons/highlighter-filled.si', size: size, color: color);

  factory AppSvgIcon.highlighterOutline({Key? key, double size = 24.0, Color? color}) =>
      AppSvgIcon(key: key, assetName: 'assets/icons/highlighter-outline.si', size: size, color: color);

  factory AppSvgIcon.highlighter({
    Key? key,
    double size = 24.0,
    Color? color,
    bool isSelected = false,
  }) =>
      isSelected
          ? AppSvgIcon.highlighterFilled(key: key, size: size, color: color)
          : AppSvgIcon.highlighterOutline(key: key, size: size, color: color);

  factory AppSvgIcon.pencilFilled({Key? key, double size = 24.0, Color? color}) =>
      AppSvgIcon(key: key, assetName: 'assets/icons/pencil-filled.si', size: size, color: color);

  factory AppSvgIcon.pencilOutline({Key? key, double size = 24.0, Color? color}) =>
      AppSvgIcon(key: key, assetName: 'assets/icons/pencil-outline.si', size: size, color: color);

  factory AppSvgIcon.pencil({
    Key? key,
    double size = 24.0,
    Color? color,
    bool isSelected = false,
  }) =>
      isSelected
          ? AppSvgIcon.pencilFilled(key: key, size: size, color: color)
          : AppSvgIcon.pencilOutline(key: key, size: size, color: color);

  factory AppSvgIcon.redo({Key? key, double size = 24.0, Color? color}) =>
      AppSvgIcon(key: key, assetName: 'assets/icons/redo.si', size: size, color: color);

  factory AppSvgIcon.save({Key? key, double size = 24.0, Color? color}) =>
      AppSvgIcon(key: key, assetName: 'assets/icons/save.si', size: size, color: color);

  factory AppSvgIcon.share({Key? key, double size = 24.0, Color? color}) =>
      AppSvgIcon(key: key, assetName: 'assets/icons/share.si', size: size, color: color);

  factory AppSvgIcon.touch({Key? key, double size = 24.0, Color? color}) =>
      AppSvgIcon(key: key, assetName: 'assets/icons/touch.si', size: size, color: color);

  factory AppSvgIcon.trash({Key? key, double size = 24.0, Color? color}) =>
      AppSvgIcon(key: key, assetName: 'assets/icons/trash.si', size: size, color: color);

  factory AppSvgIcon.undo({Key? key, double size = 24.0, Color? color}) =>
      AppSvgIcon(key: key, assetName: 'assets/icons/undo.si', size: size, color: color);

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? IconTheme.of(context).color;
    final siSource = ScalableImageSource.fromSI(rootBundle, assetName);

    return SizedBox(
      width: size,
      height: size,
      child: ScalableImageWidget.fromSISource(
        si: siSource,
        fit: fit,
        onLoaded: (context, si) {
          final tintedSi = iconColor != null
              ? si.modifyTint(newTintMode: BlendMode.srcIn, newTintColor: iconColor)
              : si;
          return ScalableImageWidget(si: tintedSi, fit: fit);
        },
      ),
    );
  }
}
