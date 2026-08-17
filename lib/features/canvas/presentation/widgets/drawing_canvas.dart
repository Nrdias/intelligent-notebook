import 'dart:async';
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/drawing.dart';
import '../providers/canvas_provider.dart';
import 'canvas_context_menu.dart';
import 'canvas_text_layer.dart';
import 'selection_overlay.dart';
import 'text_formatting_toolbar.dart';

class DrawingCanvas extends ConsumerStatefulWidget {
  final String pageId;

  const DrawingCanvas({super.key, required this.pageId});

  @override
  ConsumerState<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends ConsumerState<DrawingCanvas> {
  Timer? _longPressTimer;
  Offset? _downPosition;
  bool _longPressTriggered = false;

  void _cancelLongPressTimer() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
  }

  void _startLongPressTimer(Offset position) {
    _cancelLongPressTimer();
    _downPosition = position;
    _longPressTriggered = false;

    // 800ms threshold for long press menu
    _longPressTimer = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      _longPressTriggered = true;
      final notifier = ref.read(canvasStateProvider.notifier);

      // Remove single dot stroke created on down
      notifier.removeLastStrokeIfDrawing();

      // Show context menu at long-press position
      notifier.showContextMenu(position);
    });
  }

  @override
  void dispose() {
    _cancelLongPressTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(canvasStateProvider);
    final notifier = ref.read(canvasStateProvider.notifier);
    const bgColor = Color(0xFF000000);
    final isTextMode = state.currentTool == CanvasTool.text;

    return Stack(
      children: [
        // 1. Text Document Layer (BEHIND hand/pen drawing strokes)
        Positioned.fill(
          child: CanvasTextLayer(pageId: widget.pageId),
        ),

        // 2. Main Drawing Canvas (Handwriting ON TOP of text document)
        Positioned.fill(
          child: Listener(
            behavior: isTextMode
                ? HitTestBehavior.translucent
                : HitTestBehavior.opaque,
            onPointerDown: (event) {
              if (state.contextMenuPosition != null) {
                notifier.hideContextMenu();
                return;
              }

              if (isTextMode) return;

              _startLongPressTimer(event.localPosition);

              final isStylus = event.kind == PointerDeviceKind.stylus ||
                  event.kind == PointerDeviceKind.invertedStylus;
              notifier.onPointerDown(
                event.pointer,
                event.localPosition,
                pressure: event.pressure,
                isStylus: isStylus,
                kind: event.kind,
                buttons: event.buttons,
              );
            },
            onPointerMove: (event) {
              if (isTextMode) return;

              if (_downPosition != null) {
                final dist = (event.localPosition - _downPosition!).distance;
                // If pen/finger moves > 5px, immediately cancel long-press timer and draw!
                if (dist > 5.0) {
                  _cancelLongPressTimer();
                }
              }

              if (!_longPressTriggered) {
                notifier.onPointerMove(
                  event.pointer,
                  event.localPosition,
                  pressure: event.pressure,
                  kind: event.kind,
                );
              }
            },
            onPointerUp: (event) {
              if (isTextMode) return;
              _cancelLongPressTimer();
              notifier.onPointerUp(event.pointer);
              _longPressTriggered = false;
            },
            onPointerCancel: (event) {
              if (isTextMode) return;
              _cancelLongPressTimer();
              notifier.onPointerUp(event.pointer);
              _longPressTriggered = false;
            },
            child: CustomPaint(
              painter: SmoothStrokePainter(
                strokes: state.currentStrokes,
                panOffset: state.panOffset,
                backgroundColor: bgColor,
                activeSelectionRect:
                    state.isSelecting ? state.selectionRect : null,
              ),
              size: Size.infinite,
            ),
          ),
        ),

        // 3. Selection Overlay (Dashed bounding box & Floating Action Menu)
        if (state.selectionRect != null && !state.isSelecting)
          CanvasSelectionOverlay(
            selectionRect: state.selectionRect!,
            panOffset: state.panOffset,
          ),

        // 4. Canvas Long-Press Context Menu
        if (state.contextMenuPosition != null)
          CanvasContextMenu(position: state.contextMenuPosition!),

        // 5. Samsung Notes Floating Text Formatting Toolbar (Above Soft Keyboard)
        if (isTextMode)
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).viewInsets.bottom,
            child: const TextFormattingToolbar(),
          ),
      ],
    );
  }
}

class SmoothStrokePainter extends CustomPainter {
  final List<Stroke> strokes;
  final Offset panOffset;
  final Color backgroundColor;
  final Rect? activeSelectionRect;

  SmoothStrokePainter({
    required this.strokes,
    required this.panOffset,
    required this.backgroundColor,
    this.activeSelectionRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(panOffset.dx, panOffset.dy);

    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      final isHighlighter = stroke.isHighlighter;
      final strokeColor = stroke.isEraser
          ? backgroundColor
          : isHighlighter
              ? Color(stroke.color).withValues(alpha: 0.40)
              : Color(stroke.color);

      // If there is only one point, draw a circle
      if (stroke.points.length == 1) {
        final p = stroke.points.first;
        final paint = Paint()
          ..color = strokeColor
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;
        canvas.drawCircle(Offset(p.x, p.y), stroke.strokeWidth / 2, paint);
        continue;
      }

      final paint = Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke.strokeWidth
        ..strokeCap = isHighlighter ? StrokeCap.square : StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true;

      final path = Path();
      final pts = stroke.points;

      path.moveTo(pts.first.x, pts.first.y);

      for (var i = 1; i < pts.length; i++) {
        final prev = pts[i - 1];
        final curr = pts[i];
        final midX = (prev.x + curr.x) / 2;
        final midY = (prev.y + curr.y) / 2;
        path.quadraticBezierTo(prev.x, prev.y, midX, midY);
      }

      // ensure path reaches final point
      path.lineTo(pts.last.x, pts.last.y);

      canvas.drawPath(path, paint);
    }

    // Draw active drag selection rectangle
    if (activeSelectionRect != null && !activeSelectionRect!.isEmpty) {
      final fillPaint = Paint()
        ..color = const Color(0xFF0D59F2).withValues(alpha: 0.15)
        ..style = PaintingStyle.fill;
      canvas.drawRect(activeSelectionRect!, fillPaint);

      final borderPaint = Paint()
        ..color = const Color(0xFF0D59F2)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawRect(activeSelectionRect!, borderPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SmoothStrokePainter oldDelegate) =>
      oldDelegate.strokes != strokes ||
      oldDelegate.panOffset != panOffset ||
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.activeSelectionRect != activeSelectionRect;
}
