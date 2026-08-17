import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/canvas_provider.dart';
import 'selection_overlay/dashed_selection_painter.dart';
import 'selection_overlay/selection_action_bar.dart';

class CanvasSelectionOverlay extends ConsumerWidget {
  final Rect selectionRect;
  final Offset panOffset;

  const CanvasSelectionOverlay({
    super.key,
    required this.selectionRect,
    required this.panOffset,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(canvasStateProvider.notifier);
    final state = ref.watch(canvasStateProvider);

    // Screen coordinates
    final screenRect = selectionRect.shift(panOffset);

    // Menu position: above selectionRect if space permits, else below
    final menuTop = (screenRect.top - 54).clamp(10.0, double.infinity);
    final menuLeft = (screenRect.center.dx - 160)
        .clamp(12.0, MediaQuery.of(context).size.width - 340.0);

    return Stack(
      children: [
        // Custom Paint for Dashed Box and Handles
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: DashedSelectionPainter(rect: screenRect),
            ),
          ),
        ),

        // Floating Action Menu
        if (!state.isSelecting &&
            !state.isMovingSelection &&
            state.selectedStrokeIndices.isNotEmpty)
          Positioned(
            left: menuLeft,
            top: menuTop,
            child: Material(
              color: Colors.transparent,
              child: SelectionActionBar(
                state: state,
                notifier: notifier,
              ),
            ),
          ),
      ],
    );
  }
}
