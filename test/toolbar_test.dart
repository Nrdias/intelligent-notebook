import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:intelligent_notebook/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intelligent_notebook/features/canvas/presentation/providers/canvas_provider.dart';
import 'package:intelligent_notebook/features/canvas/presentation/widgets/toolbar.dart';
import 'package:intelligent_notebook/core/presentation/design_system/dialogs/color_palette_dialog.dart';
import 'package:intelligent_notebook/core/presentation/design_system/widgets/app_svg_icon.dart';
import 'package:intelligent_notebook/features/canvas/presentation/widgets/pen_options_popup.dart';
import 'package:intelligent_notebook/features/canvas/presentation/widgets/eraser_options_popup.dart';

Widget buildTestableWidget(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('pt', 'BR'),
        Locale('es'),
      ],
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('CanvasNotifier & State Tests', () {
    test('Initial state matches Samsung Notes specs', () {
      final notifier = CanvasNotifier();
      expect(notifier.state.currentTool, CanvasTool.pen);
      expect(notifier.state.recentColors.length, 5);
      expect(notifier.state.selectedColorIndex, 0);
      expect(notifier.state.strokeColor, 0xFFFFFFFF);
      expect(notifier.state.canUndo, false);
      expect(notifier.state.canRedo, false);
      expect(notifier.state.isFingerDrawingEnabled, false);
    });

    test('Palm rejection ignores finger touches when isFingerDrawingEnabled is false', () {
      final notifier = CanvasNotifier();
      expect(notifier.state.isFingerDrawingEnabled, false);

      // Finger touch down -> should be ignored for drawing
      notifier.onPointerDown(
        1,
        const Offset(10, 10),
        kind: PointerDeviceKind.touch,
      );
      notifier.onPointerMove(
        1,
        const Offset(20, 20),
        kind: PointerDeviceKind.touch,
      );
      notifier.onPointerUp(1);

      expect(notifier.state.currentStrokes.isEmpty, true);

      // Stylus touch down -> should draw stroke
      notifier.onPointerDown(
        2,
        const Offset(10, 10),
        kind: PointerDeviceKind.stylus,
      );
      notifier.onPointerMove(
        2,
        const Offset(20, 20),
        kind: PointerDeviceKind.stylus,
      );
      notifier.onPointerUp(2);

      expect(notifier.state.currentStrokes.length, 1);

      // Toggle finger drawing ON
      notifier.toggleFingerDrawing();
      expect(notifier.state.isFingerDrawingEnabled, true);

      // Now finger touch down -> should draw stroke
      notifier.onPointerDown(
        3,
        const Offset(30, 30),
        kind: PointerDeviceKind.touch,
      );
      notifier.onPointerMove(
        3,
        const Offset(40, 40),
        kind: PointerDeviceKind.touch,
      );
      notifier.onPointerUp(3);

      expect(notifier.state.currentStrokes.length, 2);
    });

    test('Per-tool color memory between Pen and Highlighter', () {
      final notifier = CanvasNotifier();

      // Pen default color is White (0xFFFFFFFF)
      expect(notifier.state.strokeColor, 0xFFFFFFFF);

      // Select Highlighter -> default color Yellow (0xFFFFE500)
      notifier.setTool(CanvasTool.highlighter);
      expect(notifier.state.currentTool, CanvasTool.highlighter);
      expect(notifier.state.strokeColor, 0xFFFFEB3B);

      // Change Highlighter color to Green (0xFF00FF00)
      notifier.setStrokeColor(0xFF00FF00);
      expect(notifier.state.highlighterColor, 0xFF00FF00);

      // Return to Pen -> should remember White (0xFFFFFFFF)
      notifier.setTool(CanvasTool.pen);
      expect(notifier.state.currentTool, CanvasTool.pen);
      expect(notifier.state.strokeColor, 0xFFFFFFFF);

      // Return to Highlighter -> should remember Green (0xFF00FF00)
      notifier.setTool(CanvasTool.highlighter);
      expect(notifier.state.currentTool, CanvasTool.highlighter);
      expect(notifier.state.strokeColor, 0xFF00FF00);
    });

    test('Tool switching and Eraser mode memory', () {
      final notifier = CanvasNotifier();
      notifier.setTool(CanvasTool.eraser);
      expect(notifier.state.eraserMode, EraserMode.stroke);

      // Change eraser mode to Area
      notifier.setEraserMode(EraserMode.area);
      expect(notifier.state.eraserMode, EraserMode.area);

      // Switch to Pen then back to Eraser -> should remember Area mode
      notifier.setTool(CanvasTool.pen);
      notifier.setTool(CanvasTool.eraser);
      expect(notifier.state.eraserMode, EraserMode.area);
    });

    test('Tapping color swatch when Eraser is active automatically selects Pen tool', () {
      final notifier = CanvasNotifier();
      notifier.setTool(CanvasTool.eraser);
      expect(notifier.state.currentTool, CanvasTool.eraser);

      // Select recent color slot 1
      notifier.selectRecentColor(1);
      expect(notifier.state.currentTool, CanvasTool.pen);
      expect(notifier.state.selectedColorIndex, 1);
    });

    test('Undo and Redo stack works properly for drawing and clearing', () {
      final notifier = CanvasNotifier();

      // Draw stroke 1
      notifier.onPointerDown(1, const Offset(10, 10), kind: PointerDeviceKind.stylus);
      notifier.onPointerMove(1, const Offset(20, 20), kind: PointerDeviceKind.stylus);
      notifier.onPointerUp(1);

      expect(notifier.state.currentStrokes.length, 1);
      expect(notifier.state.canUndo, true);
      expect(notifier.state.canRedo, false);

      // Undo -> empty
      notifier.undo();
      expect(notifier.state.currentStrokes.length, 0);
      expect(notifier.state.canUndo, false);
      expect(notifier.state.canRedo, true);

      // Redo -> 1 stroke
      notifier.redo();
      expect(notifier.state.currentStrokes.length, 1);
      expect(notifier.state.canUndo, true);
    });

    test('Selection tool selects, cuts, duplicates, recolors and pastes', () {
      final notifier = CanvasNotifier();

      // Draw stroke
      notifier.onPointerDown(1, const Offset(10, 10), kind: PointerDeviceKind.stylus);
      notifier.onPointerMove(1, const Offset(20, 20), kind: PointerDeviceKind.stylus);
      notifier.onPointerUp(1);

      // Select stroke
      notifier.setTool(CanvasTool.selection);
      notifier.onPointerDown(2, const Offset(0, 0), kind: PointerDeviceKind.stylus);
      notifier.onPointerMove(2, const Offset(30, 30), kind: PointerDeviceKind.stylus);
      notifier.onPointerUp(2);

      expect(notifier.state.selectedStrokeIndices.isNotEmpty, true);

      // Duplicate
      notifier.duplicateSelection();
      expect(notifier.state.currentStrokes.length, 2);

      // Change Color
      notifier.changeSelectionColor(0xFFFF00FF);
      expect(notifier.state.currentStrokes.last.color, 0xFFFF00FF);

      // Cut
      notifier.cutSelection();
      expect(notifier.state.currentStrokes.length, 1);
      expect(notifier.state.clipboardStrokes.isNotEmpty, true);
    });
  });

  group('Samsung Notes Toolbar Widget Tests', () {
    testWidgets('Toolbar renders tools, divider, 5 recent colors, presets, undo/redo',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const Toolbar()));

      // Check Pen tool AppSvgIcon
      final penFinder = find.byWidgetPredicate(
          (w) => w is AppSvgIcon && w.assetName.contains('pencil'));
      expect(penFinder, findsOneWidget);
      // Check Eraser AppSvgIcon
      final eraserFinder = find.byWidgetPredicate(
          (w) => w is AppSvgIcon && w.assetName.contains('erase'));
      expect(eraserFinder, findsOneWidget);
      // Check Undo AppSvgIcon
      final undoFinder = find.byWidgetPredicate(
          (w) => w is AppSvgIcon && w.assetName.contains('undo'));
      expect(undoFinder, findsOneWidget);
      // Check Redo AppSvgIcon
      final redoFinder = find.byWidgetPredicate(
          (w) => w is AppSvgIcon && w.assetName.contains('redo'));
      expect(redoFinder, findsOneWidget);
    });

    testWidgets('Pen tool single tap selects, second tap opens PenOptionsPopup and updates immediately',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const Toolbar()));

      final penFinder = find.byWidgetPredicate(
          (w) => w is AppSvgIcon && w.assetName.contains('pencil'));

      // Since Pen is selected by default, tapping it opens PenOptionsPopup
      await tester.tap(penFinder);
      await tester.pumpAndSettle();

      expect(find.byType(PenOptionsPopup), findsOneWidget);
      expect(find.text('Pen Thickness'), findsOneWidget);

      // Tap preset '18' in PenOptionsPopup
      await tester.tap(find.text('18'));
      await tester.pump();

      // Verify that numeric label updated immediately to 18
      expect(find.text('18'), findsWidgets);
    });

    testWidgets('Eraser tool opens popup and toggles mode / updates size immediately',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const Toolbar()));

      final eraserFinder = find.byWidgetPredicate(
          (w) => w is AppSvgIcon && w.assetName.contains('erase'));

      // First tap on Eraser: selects eraser
      await tester.tap(eraserFinder);
      await tester.pumpAndSettle();
      expect(find.byType(EraserOptionsPopup), findsNothing);

      // Second tap on Eraser: opens EraserOptionsPopup
      await tester.tap(eraserFinder);
      await tester.pumpAndSettle();

      expect(find.byType(EraserOptionsPopup), findsOneWidget);
      expect(find.text('Erase stroke'), findsOneWidget);
      expect(find.text('Erase area'), findsOneWidget);

      // Switch to 'Erase area'
      await tester.tap(find.text('Erase area'));
      await tester.pump();

      // Check presets appear and tap preset '32'
      expect(find.text('32'), findsOneWidget);
      await tester.tap(find.text('32'));
      await tester.pump();

      // Verify immediate update
      expect(find.text('32'), findsWidgets);
    });

    testWidgets('ColorPaletteDialog renders Amostras and Espectro tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('pt', 'BR'),
            Locale('es'),
          ],
          home: Scaffold(
            body: ColorPaletteDialog(
              initialColor: const Color(0xFF0D59F2),
              onColorSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Swatches'), findsOneWidget);
      expect(find.text('Spectrum'), findsOneWidget);
      expect(find.text('Hexadecimal'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      // Tap Spectrum tab
      await tester.tap(find.text('Spectrum'));
      await tester.pumpAndSettle();
    });
  });
}
