import 'package:hive/hive.dart';

import '../../../../core/utils/constants.dart';
import '../../../../tools/logger.dart';
import '../../../../tools/result.dart';
import '../../domain/entities/drawing.dart' as domain_drawing;
import '../../domain/failures/drawing_failure.dart';
import '../models/drawing_model.dart';

// Extension for serialization
extension DrawingModelHiveExtension on DrawingModel {
  domain_drawing.Drawing toDomain() => domain_drawing.Drawing(
        id: id,
        pageId: pageId,
        notebookId: notebookId,
        strokes: strokes
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
            .toList(),
        thumbnailUrl: thumbnailUrl,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

class HiveDrawingDataSource {
  late final Box _drawingsBox;

  HiveDrawingDataSource._();

  static final HiveDrawingDataSource _instance = HiveDrawingDataSource._();
  static HiveDrawingDataSource get instance => _instance;

  void init() {
    _drawingsBox = Hive.box(Constants.drawingsBox);
  }

  Future<Result<void, DrawingFailure>> saveDrawing(
      domain_drawing.Drawing drawing) async {
    try {
      final model = DrawingModel(
        id: drawing.id,
        pageId: drawing.pageId,
        notebookId: drawing.notebookId,
        strokes: drawing.strokes
            .map((s) => StrokeModel(
                  points: s.points
                      .map((p) =>
                          OffsetPoint(x: p.x, y: p.y, pressure: p.pressure))
                      .toList(),
                  strokeWidth: s.strokeWidth,
                  color: s.color,
                  isEraser: s.isEraser,
                  isHighlighter: s.isHighlighter,
                  pressure: s.pressure,
                ))
            .toList(),
        thumbnailUrl: drawing.thumbnailUrl,
        createdAt: drawing.createdAt,
        updatedAt: drawing.updatedAt,
      );
      await _drawingsBox.put(drawing.pageId, model.toJson());
      return success(null);
    } catch (e, stack) {
      AppLoggerImpl.instance.error('HiveDrawingDataSource.saveDrawing failed',
          error: e, stackTrace: stack);
      return failure(DrawingFailure(message: e.toString()));
    }
  }

  Result<domain_drawing.Drawing, DrawingFailure> getDrawing(String pageId) {
    try {
      final value = _drawingsBox.get(pageId);
      if (value == null) {
        AppLoggerImpl.instance.failure(
            'HiveDrawingDataSource.getDrawing: drawing for page $pageId not found');
        return failure(DrawingFailure.notFound);
      }
      final map = Map<String, dynamic>.from(value as Map);
      final drawing = DrawingModel.fromJson(map).toDomain();
      return success(drawing);
    } catch (e, stack) {
      AppLoggerImpl.instance.error('HiveDrawingDataSource.getDrawing failed',
          error: e, stackTrace: stack);
      return failure(DrawingFailure(message: e.toString()));
    }
  }

  Future<Result<void, DrawingFailure>> deleteDrawing(String pageId) async {
    try {
      await _drawingsBox.delete(pageId);
      return success(null);
    } catch (e, stack) {
      AppLoggerImpl.instance.error('HiveDrawingDataSource.deleteDrawing failed',
          error: e, stackTrace: stack);
      return failure(DrawingFailure(message: e.toString()));
    }
  }
}
