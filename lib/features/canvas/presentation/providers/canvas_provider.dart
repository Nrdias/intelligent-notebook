import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../tools/result.dart';
import '../../domain/entities/drawing.dart' as domain_drawing;
import '../../domain/entities/drawing.dart';
import '../../domain/repositories/drawing_repository.dart';

// Tools
enum CanvasTool { pen, highlighter, eraser, selection, text, shape }
enum EraserMode { stroke, area }

// State
class CanvasState {
  final CanvasTool currentTool;
  final EraserMode lastSelectedEraserMode;

  // Pen tool color and stroke width memory
  final double penStrokeWidth;
  final int penColor;
  final List<int> penRecentColors;
  final int penSelectedColorIndex;

  // Highlighter tool color and stroke width memory
  final double highlighterWidth;
  final int highlighterColor;
  final List<int> highlighterRecentColors;
  final int highlighterSelectedColorIndex;

  // Eraser memory
  final double eraserRadius;

  final List<Stroke> currentStrokes;
  final Rect? selectionRect;
  final Set<int> selectedStrokeIndices;
  final bool isSelecting;
  final Offset? selectionStart;
  final Offset? selectionCurrent;
  final bool isMovingSelection;
  final List<Stroke> clipboardStrokes;
  final bool canUndo;
  final bool canRedo;
  final Offset panOffset;
  final bool isDrawing;
  final bool isFingerDrawingEnabled;

  final Offset? contextMenuPosition;

  // Canvas Document Text state
  final String canvasText;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final bool isStrikethrough;
  final double textFontSize;
  final int textColor;
  final TextAlign textAlign;

  // Auto-Save state
  final bool isSaving;
  final bool isDirty;
  final DateTime? lastSavedAt;
  final String? pageId;

  const CanvasState({
    this.currentTool = CanvasTool.pen,
    this.lastSelectedEraserMode = EraserMode.stroke,
    this.penStrokeWidth = 3.0,
    this.penColor = 0xFFFFFFFF,
    this.penRecentColors = const [
      0xFFFFFFFF, // White
      0xFF0D59F2, // Blue
      0xFFE51C24, // Red
      0xFF0A2265, // Dark Navy
      0xFF621093, // Purple
    ],
    this.penSelectedColorIndex = 0,
    this.highlighterWidth = 24.0,
    this.highlighterColor = 0xFFFFEB3B, // Neon Yellow
    this.highlighterRecentColors = const [
      0xFFFFEB3B, // Neon Yellow
      0xFF76FF03, // Neon Green
      0xFFFF9100, // Neon Orange
      0xFFFF4081, // Neon Pink
      0xFF00E5FF, // Neon Cyan
    ],
    this.highlighterSelectedColorIndex = 0,
    this.eraserRadius = 20.0,
    this.currentStrokes = const [],
    this.selectionRect,
    this.selectedStrokeIndices = const {},
    this.isSelecting = false,
    this.selectionStart,
    this.selectionCurrent,
    this.isMovingSelection = false,
    this.clipboardStrokes = const [],
    this.canUndo = false,
    this.canRedo = false,
    this.panOffset = Offset.zero,
    this.isDrawing = false,
    this.isFingerDrawingEnabled = false,
    this.contextMenuPosition,
    this.canvasText = '',
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.isStrikethrough = false,
    this.textFontSize = 17.0,
    this.textColor = 0xFFFFFFFF,
    this.textAlign = TextAlign.left,
    this.isSaving = false,
    this.isDirty = false,
    this.lastSavedAt,
    this.pageId,
  });

  // Getter for active eraser mode
  EraserMode get eraserMode => lastSelectedEraserMode;

  // Dynamic getters reflecting active tool memory
  int get strokeColor =>
      currentTool == CanvasTool.highlighter ? highlighterColor : penColor;

  double get strokeWidth =>
      currentTool == CanvasTool.highlighter ? highlighterWidth : penStrokeWidth;

  List<int> get recentColors => currentTool == CanvasTool.highlighter
      ? highlighterRecentColors
      : penRecentColors;

  int get selectedColorIndex => currentTool == CanvasTool.highlighter
      ? highlighterSelectedColorIndex
      : penSelectedColorIndex;

  CanvasState copyWith({
    CanvasTool? currentTool,
    EraserMode? eraserMode,
    EraserMode? lastSelectedEraserMode,
    double? penStrokeWidth,
    int? penColor,
    List<int>? penRecentColors,
    int? penSelectedColorIndex,
    double? highlighterWidth,
    int? highlighterColor,
    List<int>? highlighterRecentColors,
    int? highlighterSelectedColorIndex,
    double? eraserRadius,
    List<Stroke>? currentStrokes,
    Rect? selectionRect,
    bool clearSelectionRect = false,
    Set<int>? selectedStrokeIndices,
    bool? isSelecting,
    Offset? selectionStart,
    bool clearSelectionStart = false,
    Offset? selectionCurrent,
    bool clearSelectionCurrent = false,
    bool? isMovingSelection,
    List<Stroke>? clipboardStrokes,
    bool? canUndo,
    bool? canRedo,
    Offset? panOffset,
    bool? isDrawing,
    bool? isFingerDrawingEnabled,
    Offset? contextMenuPosition,
    bool clearContextMenuPosition = false,
    String? canvasText,
    bool? isBold,
    bool? isItalic,
    bool? isUnderline,
    bool? isStrikethrough,
    double? textFontSize,
    int? textColor,
    TextAlign? textAlign,
    bool? isSaving,
    bool? isDirty,
    DateTime? lastSavedAt,
    String? pageId,
  }) {
    return CanvasState(
      currentTool: currentTool ?? this.currentTool,
      lastSelectedEraserMode: lastSelectedEraserMode ??
          eraserMode ??
          this.lastSelectedEraserMode,
      penStrokeWidth: penStrokeWidth ?? this.penStrokeWidth,
      penColor: penColor ?? this.penColor,
      penRecentColors: penRecentColors ?? this.penRecentColors,
      penSelectedColorIndex:
          penSelectedColorIndex ?? this.penSelectedColorIndex,
      highlighterWidth: highlighterWidth ?? this.highlighterWidth,
      highlighterColor: highlighterColor ?? this.highlighterColor,
      highlighterRecentColors:
          highlighterRecentColors ?? this.highlighterRecentColors,
      highlighterSelectedColorIndex:
          highlighterSelectedColorIndex ?? this.highlighterSelectedColorIndex,
      eraserRadius: eraserRadius ?? this.eraserRadius,
      currentStrokes: currentStrokes ?? this.currentStrokes,
      selectionRect:
          clearSelectionRect ? null : (selectionRect ?? this.selectionRect),
      selectedStrokeIndices:
          selectedStrokeIndices ?? this.selectedStrokeIndices,
      isSelecting: isSelecting ?? this.isSelecting,
      selectionStart:
          clearSelectionStart ? null : (selectionStart ?? this.selectionStart),
      selectionCurrent: clearSelectionCurrent
          ? null
          : (selectionCurrent ?? this.selectionCurrent),
      isMovingSelection: isMovingSelection ?? this.isMovingSelection,
      clipboardStrokes: clipboardStrokes ?? this.clipboardStrokes,
      canUndo: canUndo ?? this.canUndo,
      canRedo: canRedo ?? this.canRedo,
      panOffset: panOffset ?? this.panOffset,
      isDrawing: isDrawing ?? this.isDrawing,
      isFingerDrawingEnabled:
          isFingerDrawingEnabled ?? this.isFingerDrawingEnabled,
      contextMenuPosition: clearContextMenuPosition
          ? null
          : (contextMenuPosition ?? this.contextMenuPosition),
      canvasText: canvasText ?? this.canvasText,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isUnderline: isUnderline ?? this.isUnderline,
      isStrikethrough: isStrikethrough ?? this.isStrikethrough,
      textFontSize: textFontSize ?? this.textFontSize,
      textColor: textColor ?? this.textColor,
      textAlign: textAlign ?? this.textAlign,
      isSaving: isSaving ?? this.isSaving,
      isDirty: isDirty ?? this.isDirty,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      pageId: pageId ?? this.pageId,
    );
  }
}

// Provider
final canvasStateProvider =
    StateNotifierProvider<CanvasNotifier, CanvasState>((ref) {
  return CanvasNotifier();
});

class CanvasNotifier extends StateNotifier<CanvasState> {
  CanvasNotifier() : super(const CanvasState());

  CanvasTool? _previousTool;
  final Set<int> _activePointers = {};
  final Map<int, Offset> _lastPointerPositions = {};
  final Set<int> _ignoredDrawingPointers = {};
  Offset? _lastCentroid;

  final List<List<Stroke>> _undoStack = [];
  final List<List<Stroke>> _redoStack = [];

  Offset? _selectionMoveStart;
  bool _eraserModifiedInGesture = false;
  Timer? _autoSaveTimer;

  DrawingRepository? get _drawingRepo {
    if (getIt.isRegistered<DrawingRepository>()) {
      return getIt<DrawingRepository>();
    }
    return null;
  }

  void resetAndLoadCanvas(String pageId) async {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
    _undoStack.clear();
    _redoStack.clear();

    state = CanvasState(
      pageId: pageId,
      currentStrokes: const [],
      isDirty: false,
      canUndo: false,
      canRedo: false,
    );

    _startAutoSaveTimer();

    final repo = _drawingRepo;
    if (repo != null) {
      final result = await repo.getDrawing(pageId);
      if (result case Success(:final data)) {
        if (state.pageId == pageId) {
          final loadedStrokes = data.strokes
              .map((s) => Stroke(
                    points: s.points
                        .map((p) => OffsetPoint(x: p.x, y: p.y, pressure: p.pressure))
                        .toList(),
                    strokeWidth: s.strokeWidth,
                    color: s.color,
                    isEraser: s.isEraser,
                    isHighlighter: s.isHighlighter,
                    pressure: s.pressure,
                  ))
              .toList();
          state = state.copyWith(
            currentStrokes: loadedStrokes,
            isDirty: false,
          );
        }
      }
    }
  }

  void loadCanvas(String pageId) => resetAndLoadCanvas(pageId);

  void _startAutoSaveTimer() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(milliseconds: 5000), (_) {
      autoSave();
    });
  }

  Future<void> autoSave({bool force = false}) async {
    final pageId = state.pageId;
    if (pageId == null || pageId.isEmpty) return;
    if (!state.isDirty && !force) return;
    if (state.isSaving) return;

    final repo = _drawingRepo;
    if (repo == null) return;

    state = state.copyWith(isSaving: true);

    try {
      final domainStrokes = state.currentStrokes
          .map((s) => domain_drawing.Stroke(
                points: s.points
                    .map((p) => domain_drawing.OffsetPoint(
                        x: p.x, y: p.y, pressure: p.pressure))
                    .toList(),
                strokeWidth: s.strokeWidth,
                color: s.color,
                isEraser: s.isEraser,
                isHighlighter: s.isHighlighter,
                pressure: s.pressure,
              ))
          .toList();

      final drawing = domain_drawing.Drawing(
        id: pageId,
        pageId: pageId,
        notebookId: '',
        strokes: domainStrokes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repo.saveDrawing(drawing);

      state = state.copyWith(
        isSaving: false,
        isDirty: false,
        lastSavedAt: DateTime.now(),
      );
    } catch (_) {
      state = state.copyWith(isSaving: false);
    }
  }

  void disposeCanvas() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
    if (state.isDirty) {
      autoSave(force: true);
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
    super.dispose();
  }

  void _pushUndoSnapshot() {
    _undoStack.add(List.of(state.currentStrokes));
    if (_undoStack.length > 50) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
    state = state.copyWith(canUndo: true, canRedo: false, isDirty: true);
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    final previous = _undoStack.removeLast();
    _redoStack.add(List.of(state.currentStrokes));
    state = state.copyWith(
      currentStrokes: previous,
      canUndo: _undoStack.isNotEmpty,
      canRedo: true,
      clearSelectionRect: true,
      selectedStrokeIndices: const {},
    );
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    final next = _redoStack.removeLast();
    _undoStack.add(List.of(state.currentStrokes));
    state = state.copyWith(
      currentStrokes: next,
      canUndo: true,
      canRedo: _redoStack.isNotEmpty,
      clearSelectionRect: true,
      selectedStrokeIndices: const {},
    );
  }

  void clear() {
    if (state.currentStrokes.isEmpty) return;
    _pushUndoSnapshot();
    state = state.copyWith(
      currentStrokes: const [],
      clearSelectionRect: true,
      selectedStrokeIndices: const {},
    );
  }

  void toggleFingerDrawing() {
    state = state.copyWith(
      isFingerDrawingEnabled: !state.isFingerDrawingEnabled,
    );
  }

  Offset? _computeCentroid() {
    if (_lastPointerPositions.isEmpty) return null;
    double sumX = 0, sumY = 0;
    int count = 0;
    for (final p in _lastPointerPositions.values) {
      sumX += p.dx;
      sumY += p.dy;
      count++;
    }
    if (count == 0) return null;
    return Offset(sumX / count, sumY / count);
  }

  bool _doesStrokeTouchPoint(Stroke stroke, Offset point, double radius) {
    if (stroke.points.isEmpty) return false;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final p in stroke.points) {
      minX = math.min(minX, p.x);
      maxX = math.max(maxX, p.x);
      minY = math.min(minY, p.y);
      maxY = math.max(maxY, p.y);
    }

    final effectiveRadius = radius + (stroke.strokeWidth / 2);
    final expandedBounds = Rect.fromLTRB(
      minX - effectiveRadius,
      minY - effectiveRadius,
      maxX + effectiveRadius,
      maxY + effectiveRadius,
    );

    if (!expandedBounds.contains(point)) {
      return false;
    }

    for (final p in stroke.points) {
      final distance = (Offset(p.x, p.y) - point).distance;
      if (distance <= effectiveRadius) {
        return true;
      }
    }
    return false;
  }

  void _eraseAt(Offset position) {
    final strokes = state.currentStrokes;
    final updated = strokes.where((stroke) {
      return !_doesStrokeTouchPoint(stroke, position, state.eraserRadius);
    }).toList();

    if (updated.length != strokes.length) {
      if (!_eraserModifiedInGesture) {
        _pushUndoSnapshot();
        _eraserModifiedInGesture = true;
      }
      state = state.copyWith(currentStrokes: updated);
    }
  }

  void _eraseAreaAt(Offset position) {
    final strokes = state.currentStrokes;
    final updated = <Stroke>[];
    bool anyChanged = false;

    for (final stroke in strokes) {
      var touched = false;
      final currentSegment = <OffsetPoint>[];
      final segments = <List<OffsetPoint>>[];

      final effectiveRadius = state.eraserRadius + (stroke.strokeWidth / 2);

      for (final p in stroke.points) {
        final distance = (Offset(p.x, p.y) - position).distance;
        final hit = distance <= effectiveRadius;
        if (hit) {
          touched = true;
          if (currentSegment.length > 1) {
            segments.add(List.of(currentSegment));
          }
          currentSegment.clear();
        } else {
          currentSegment.add(p);
        }
      }

      if (currentSegment.length > 1) {
        segments.add(List.of(currentSegment));
      }

      if (!touched) {
        updated.add(stroke);
      } else {
        anyChanged = true;
        for (final segment in segments) {
          updated.add(stroke.copyWith(points: segment));
        }
      }
    }

    if (anyChanged) {
      if (!_eraserModifiedInGesture) {
        _pushUndoSnapshot();
        _eraserModifiedInGesture = true;
      }
      state = state.copyWith(currentStrokes: updated);
    }
  }

  void setTool(CanvasTool tool) {
    if (state.currentTool == tool) return;
    _activePointers.clear();
    _lastPointerPositions.clear();
    _ignoredDrawingPointers.clear();
    _previousTool = null;
    if (tool != CanvasTool.selection && state.selectionRect != null) {
      clearSelection();
    }
    state = state.copyWith(currentTool: tool);
  }

  void setStrokeWidth(double width) {
    if (state.currentTool == CanvasTool.highlighter) {
      state = state.copyWith(highlighterWidth: width);
    } else {
      state = state.copyWith(penStrokeWidth: width);
    }
  }

  void setPenStrokeWidth(double width) {
    state = state.copyWith(penStrokeWidth: width);
  }

  void setHighlighterWidth(double width) {
    state = state.copyWith(highlighterWidth: width);
  }

  void setEraserRadius(double radius) {
    state = state.copyWith(eraserRadius: radius);
  }

  void setEraserMode(EraserMode mode) {
    state = state.copyWith(lastSelectedEraserMode: mode);
  }

  void toggleEraserMode() {
    final nextMode = state.lastSelectedEraserMode == EraserMode.stroke
        ? EraserMode.area
        : EraserMode.stroke;
    state = state.copyWith(lastSelectedEraserMode: nextMode);
  }

  void selectRecentColor(int index) {
    if (state.currentTool == CanvasTool.eraser ||
        state.currentTool == CanvasTool.selection) {
      state = state.copyWith(currentTool: CanvasTool.pen);
    }

    if (state.currentTool == CanvasTool.highlighter) {
      if (index >= 0 && index < state.highlighterRecentColors.length) {
        state = state.copyWith(
          highlighterSelectedColorIndex: index,
          highlighterColor: state.highlighterRecentColors[index],
        );
      }
    } else {
      if (index >= 0 && index < state.penRecentColors.length) {
        state = state.copyWith(
          penSelectedColorIndex: index,
          penColor: state.penRecentColors[index],
        );
      }
    }
  }

  void updateRecentColor(int index, int newColor) {
    if (state.currentTool == CanvasTool.eraser ||
        state.currentTool == CanvasTool.selection) {
      state = state.copyWith(currentTool: CanvasTool.pen);
    }

    if (state.currentTool == CanvasTool.highlighter) {
      if (index >= 0 && index < state.highlighterRecentColors.length) {
        final updatedList = List<int>.from(state.highlighterRecentColors);
        updatedList[index] = newColor;
        state = state.copyWith(
          highlighterRecentColors: updatedList,
          highlighterSelectedColorIndex: index,
          highlighterColor: newColor,
        );
      }
    } else {
      if (index >= 0 && index < state.penRecentColors.length) {
        final updatedList = List<int>.from(state.penRecentColors);
        updatedList[index] = newColor;
        state = state.copyWith(
          penRecentColors: updatedList,
          penSelectedColorIndex: index,
          penColor: newColor,
        );
      }
    }
  }

  void setStrokeColor(int color) {
    if (state.currentTool == CanvasTool.eraser ||
        state.currentTool == CanvasTool.selection) {
      state = state.copyWith(currentTool: CanvasTool.pen);
    }
    if (state.currentTool == CanvasTool.highlighter) {
      final existingIdx = state.highlighterRecentColors.indexOf(color);
      if (existingIdx != -1) {
        selectRecentColor(existingIdx);
      } else {
        updateRecentColor(state.highlighterSelectedColorIndex, color);
      }
    } else {
      final existingIdx = state.penRecentColors.indexOf(color);
      if (existingIdx != -1) {
        selectRecentColor(existingIdx);
      } else {
        updateRecentColor(state.penSelectedColorIndex, color);
      }
    }
  }

  // Pointer Events for Canvas
  void onPointerDown(
    int pointer,
    Offset position, {
    double pressure = 1.0,
    bool isStylus = false,
    PointerDeviceKind kind = PointerDeviceKind.stylus,
    int buttons = 0,
  }) {
    _activePointers.add(pointer);
    _lastPointerPositions[pointer] = position;

    // Palm rejection / Stylus-only mode:
    // If finger drawing is disabled and this pointer is a finger touch, ignore for drawing
    final isFingerTouch = kind == PointerDeviceKind.touch;
    if (!state.isFingerDrawingEnabled && isFingerTouch) {
      _ignoredDrawingPointers.add(pointer);
      // Still allow multi-pointer centroid calculation for panning
      if (_activePointers.length > 1) {
        _lastCentroid = _computeCentroid();
      }
      return;
    }

    final isEraserPressed = isStylus && ((buttons & 0x2) != 0);
    if (isEraserPressed) {
      _previousTool ??= state.currentTool;
      state = state.copyWith(currentTool: CanvasTool.eraser);
    }

    if (_activePointers.length > 1) {
      _lastCentroid = _computeCentroid();
      return;
    }

    final localPos = position - state.panOffset;

    // SELECTION TOOL LOGIC
    if (state.currentTool == CanvasTool.selection) {
      if (state.selectionRect != null &&
          state.selectionRect!.inflate(12).contains(localPos) &&
          state.selectedStrokeIndices.isNotEmpty) {
        _selectionMoveStart = localPos;
        state = state.copyWith(isMovingSelection: true);
      } else {
        clearSelection();
        state = state.copyWith(
          isSelecting: true,
          selectionStart: localPos,
          selectionCurrent: localPos,
          selectionRect: Rect.fromPoints(localPos, localPos),
        );
      }
      return;
    }

    // ERASER LOGIC
    if (state.currentTool == CanvasTool.eraser) {
      _eraserModifiedInGesture = false;
      if (state.eraserMode == EraserMode.area) {
        _eraseAreaAt(localPos);
      } else {
        _eraseAt(localPos);
      }
      return;
    }

    // DRAWING LOGIC (Pen & Highlighter)
    _pushUndoSnapshot();
    final isHighlighter = state.currentTool == CanvasTool.highlighter;
    final width = isHighlighter ? state.highlighterWidth : state.penStrokeWidth;
    final color = isHighlighter ? state.highlighterColor : state.penColor;

    state = state.copyWith(
      isDrawing: true,
      currentStrokes: [
        ...state.currentStrokes,
        Stroke(
          points: [
            OffsetPoint(x: localPos.dx, y: localPos.dy, pressure: pressure)
          ],
          strokeWidth: width,
          color: color,
          isEraser: false,
          isHighlighter: isHighlighter,
        ),
      ],
    );
  }

  void onPointerMove(
    int pointer,
    Offset position, {
    double pressure = 1.0,
    PointerDeviceKind kind = PointerDeviceKind.stylus,
  }) {
    _lastPointerPositions[pointer] = position;

    if (_activePointers.length > 1) {
      final newCentroid = _computeCentroid();
      if (_lastCentroid != null && newCentroid != null) {
        final delta = newCentroid - _lastCentroid!;
        state = state.copyWith(panOffset: state.panOffset + delta);
      }
      _lastCentroid = newCentroid;
      return;
    }

    if (_ignoredDrawingPointers.contains(pointer)) {
      return;
    }

    final localPos = position - state.panOffset;

    // SELECTION MOVE / DRAG
    if (state.currentTool == CanvasTool.selection) {
      if (state.isMovingSelection && _selectionMoveStart != null) {
        final delta = localPos - _selectionMoveStart!;
        _selectionMoveStart = localPos;
        _moveSelectedStrokes(delta);
      } else if (state.isSelecting && state.selectionStart != null) {
        state = state.copyWith(
          selectionCurrent: localPos,
          selectionRect: Rect.fromPoints(state.selectionStart!, localPos),
        );
      }
      return;
    }

    // ERASER MOVE
    if (state.currentTool == CanvasTool.eraser) {
      if (state.eraserMode == EraserMode.area) {
        _eraseAreaAt(localPos);
      } else {
        _eraseAt(localPos);
      }
      return;
    }

    // DRAWING MOVE
    if (!state.isDrawing || state.currentStrokes.isEmpty) return;

    final lastStroke = state.currentStrokes.last;
    if (lastStroke.points.isNotEmpty) {
      final lastPoint = lastStroke.points.last;
      final dist = (localPos - Offset(lastPoint.x, lastPoint.y)).distance;
      if (dist < 1.0) {
        return;
      }
    }

    final updatedStrokes = [...state.currentStrokes];
    updatedStrokes[updatedStrokes.length - 1] = lastStroke.copyWith(
      points: [
        ...lastStroke.points,
        OffsetPoint(x: localPos.dx, y: localPos.dy, pressure: pressure)
      ],
    );

    state = state.copyWith(currentStrokes: updatedStrokes);
  }

  void onPointerUp(int pointer) {
    _activePointers.remove(pointer);
    _lastPointerPositions.remove(pointer);
    final wasIgnored = _ignoredDrawingPointers.remove(pointer);

    if (_activePointers.length <= 1) {
      _lastCentroid = null;
    }

    if (wasIgnored) return;

    if (_activePointers.isEmpty) {
      if (state.currentTool == CanvasTool.selection) {
        if (state.isMovingSelection) {
          state = state.copyWith(isMovingSelection: false);
          _selectionMoveStart = null;
        } else if (state.isSelecting) {
          _finalizeSelection();
        }
      }

      state = state.copyWith(isDrawing: false);
      if (_previousTool != null) {
        state = state.copyWith(currentTool: _previousTool);
        _previousTool = null;
      }
    }
  }

  void _finalizeSelection() {
    final rect = state.selectionRect;
    if (rect == null || rect.width < 5 || rect.height < 5) {
      clearSelection();
      return;
    }

    final normalized = Rect.fromLTRB(
      math.min(rect.left, rect.right),
      math.min(rect.top, rect.bottom),
      math.max(rect.left, rect.right),
      math.max(rect.top, rect.bottom),
    );

    final selectedIndices = <int>{};
    double minX = double.infinity, minY = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity;

    for (int i = 0; i < state.currentStrokes.length; i++) {
      final stroke = state.currentStrokes[i];
      bool intersects = false;
      for (final pt in stroke.points) {
        if (normalized.contains(Offset(pt.x, pt.y))) {
          intersects = true;
          break;
        }
      }
      if (intersects) {
        selectedIndices.add(i);
        for (final pt in stroke.points) {
          minX = math.min(minX, pt.x);
          minY = math.min(minY, pt.y);
          maxX = math.max(maxX, pt.x);
          maxY = math.max(maxY, pt.y);
        }
      }
    }

    if (selectedIndices.isEmpty) {
      clearSelection();
    } else {
      final tightRect = Rect.fromLTRB(
        minX - 12,
        minY - 12,
        maxX + 12,
        maxY + 12,
      );
      state = state.copyWith(
        isSelecting: false,
        selectionRect: tightRect,
        selectedStrokeIndices: selectedIndices,
      );
    }
  }

  void _moveSelectedStrokes(Offset delta) {
    if (state.selectedStrokeIndices.isEmpty) return;

    final updatedStrokes = [...state.currentStrokes];
    for (final index in state.selectedStrokeIndices) {
      final stroke = updatedStrokes[index];
      final newPoints = stroke.points
          .map((p) => OffsetPoint(
                x: p.x + delta.dx,
                y: p.y + delta.dy,
                pressure: p.pressure,
              ))
          .toList();
      updatedStrokes[index] = stroke.copyWith(points: newPoints);
    }

    final newRect = state.selectionRect?.shift(delta);

    state = state.copyWith(
      currentStrokes: updatedStrokes,
      selectionRect: newRect,
    );
  }

  void clearSelection() {
    state = state.copyWith(
      clearSelectionRect: true,
      selectedStrokeIndices: const {},
      isSelecting: false,
      isMovingSelection: false,
      clearSelectionStart: true,
      clearSelectionCurrent: true,
    );
  }

  void copySelection() {
    if (state.selectedStrokeIndices.isEmpty) return;
    final selected = state.selectedStrokeIndices
        .map((i) => state.currentStrokes[i])
        .toList();
    state = state.copyWith(
      clipboardStrokes: selected,
      clearSelectionRect: true,
      selectedStrokeIndices: const {},
    );
  }

  void cutSelection() {
    if (state.selectedStrokeIndices.isEmpty) return;
    _pushUndoSnapshot();
    final selected = state.selectedStrokeIndices
        .map((i) => state.currentStrokes[i])
        .toList();

    final remaining = <Stroke>[];
    for (int i = 0; i < state.currentStrokes.length; i++) {
      if (!state.selectedStrokeIndices.contains(i)) {
        remaining.add(state.currentStrokes[i]);
      }
    }

    state = state.copyWith(
      clipboardStrokes: selected,
      currentStrokes: remaining,
      clearSelectionRect: true,
      selectedStrokeIndices: const {},
    );
  }

  void showContextMenu(Offset position) {
    state = state.copyWith(contextMenuPosition: position);
  }

  void hideContextMenu() {
    if (state.contextMenuPosition != null) {
      state = state.copyWith(clearContextMenuPosition: true);
    }
  }

  void removeLastStrokeIfDrawing() {
    if (state.isDrawing && state.currentStrokes.isNotEmpty) {
      final updated = List<Stroke>.from(state.currentStrokes)..removeLast();
      if (_undoStack.isNotEmpty) {
        _undoStack.removeLast();
      }
      state = state.copyWith(
        currentStrokes: updated,
        isDrawing: false,
        canUndo: _undoStack.isNotEmpty,
      );
    }
  }

  void pasteClipboard({Offset? offset, Offset? targetPosition}) {
    if (state.clipboardStrokes.isEmpty) return;
    _pushUndoSnapshot();

    Offset delta;
    if (targetPosition != null) {
      double sMinX = double.infinity, sMinY = double.infinity;
      double sMaxX = double.negativeInfinity, sMaxY = double.negativeInfinity;
      for (final s in state.clipboardStrokes) {
        for (final p in s.points) {
          sMinX = math.min(sMinX, p.x);
          sMinY = math.min(sMinY, p.y);
          sMaxX = math.max(sMaxX, p.x);
          sMaxY = math.max(sMaxY, p.y);
        }
      }
      final center = Offset((sMinX + sMaxX) / 2, (sMinY + sMaxY) / 2);
      delta = targetPosition - center;
    } else {
      delta = offset ?? const Offset(30, 30);
    }

    final pastedStrokes = state.clipboardStrokes.map((s) {
      return s.copyWith(
        points: s.points
            .map((p) => OffsetPoint(
                x: p.x + delta.dx, y: p.y + delta.dy, pressure: p.pressure))
            .toList(),
      );
    }).toList();

    final startIndex = state.currentStrokes.length;
    final newIndices = List.generate(
      pastedStrokes.length,
      (i) => startIndex + i,
    ).toSet();

    double minX = double.infinity, minY = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity;
    for (final s in pastedStrokes) {
      for (final p in s.points) {
        minX = math.min(minX, p.x);
        minY = math.min(minY, p.y);
        maxX = math.max(maxX, p.x);
        maxY = math.max(maxY, p.y);
      }
    }

    final newRect = Rect.fromLTRB(
      minX - 12,
      minY - 12,
      maxX + 12,
      maxY + 12,
    );

    state = state.copyWith(
      currentStrokes: [...state.currentStrokes, ...pastedStrokes],
      selectionRect: newRect,
      selectedStrokeIndices: newIndices,
      currentTool: CanvasTool.selection,
      clearContextMenuPosition: true,
    );
  }

  void selectAll() {
    if (state.currentStrokes.isEmpty) return;

    final allIndices = Set<int>.from(
        List.generate(state.currentStrokes.length, (index) => index));

    double minX = double.infinity, minY = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity;

    for (final stroke in state.currentStrokes) {
      for (final pt in stroke.points) {
        minX = math.min(minX, pt.x);
        minY = math.min(minY, pt.y);
        maxX = math.max(maxX, pt.x);
        maxY = math.max(maxY, pt.y);
      }
    }

    final tightRect = Rect.fromLTRB(
      minX - 12,
      minY - 12,
      maxX + 12,
      maxY + 12,
    );

    state = state.copyWith(
      isSelecting: false,
      selectionRect: tightRect,
      selectedStrokeIndices: allIndices,
      currentTool: CanvasTool.selection,
      clearContextMenuPosition: true,
    );
  }

  void deleteSelection() {
    if (state.selectedStrokeIndices.isEmpty) return;
    _pushUndoSnapshot();

    final remaining = <Stroke>[];
    for (int i = 0; i < state.currentStrokes.length; i++) {
      if (!state.selectedStrokeIndices.contains(i)) {
        remaining.add(state.currentStrokes[i]);
      }
    }

    state = state.copyWith(
      currentStrokes: remaining,
      clearSelectionRect: true,
      selectedStrokeIndices: const {},
    );
  }

  void duplicateSelection() {
    if (state.selectedStrokeIndices.isEmpty) return;
    copySelection();
    pasteClipboard(offset: const Offset(25, 25));
  }

  void changeSelectionColor(int newColor) {
    if (state.selectedStrokeIndices.isEmpty) return;
    _pushUndoSnapshot();

    final updatedStrokes = [...state.currentStrokes];
    for (final i in state.selectedStrokeIndices) {
      updatedStrokes[i] = updatedStrokes[i].copyWith(color: newColor);
    }

    state = state.copyWith(currentStrokes: updatedStrokes);
  }

  void updateCanvasText(String text) {
    state = state.copyWith(canvasText: text);
  }

  void toggleBold() {
    state = state.copyWith(isBold: !state.isBold);
  }

  void toggleItalic() {
    state = state.copyWith(isItalic: !state.isItalic);
  }

  void toggleUnderline() {
    state = state.copyWith(isUnderline: !state.isUnderline);
  }

  void toggleStrikethrough() {
    state = state.copyWith(isStrikethrough: !state.isStrikethrough);
  }

  void setTextFontSize(double size) {
    state = state.copyWith(textFontSize: size);
  }

  void setCanvasTextColor(int color) {
    state = state.copyWith(textColor: color);
  }

  void setTextAlign(TextAlign align) {
    state = state.copyWith(textAlign: align);
  }
}
