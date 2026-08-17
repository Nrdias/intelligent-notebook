import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jovial_svg/jovial_svg.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test AppSvgIcon rendering with jovial_svg onLoaded tinting', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppSvgIcon(
              assetName: 'assets/icons/pencil-filled.si',
              size: 32,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.byWidgetPredicate((w) => w is ScalableImageWidget), findsWidgets);
  });
}
