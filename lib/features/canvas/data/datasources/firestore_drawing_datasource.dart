import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../tools/logger.dart';
import '../../../../tools/result.dart';
import '../../domain/entities/drawing.dart' as domain_drawing;
import '../../domain/failures/drawing_failure.dart';
import '../models/drawing_model.dart';

class FirestoreDrawingDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreDrawingDataSource(this._firestore, [FirebaseAuth? auth])
      : _auth = auth ?? FirebaseAuth.instance;

  String get userId => _auth.currentUser?.uid ?? 'guest';

  CollectionReference get _drawingsRef =>
      _firestore.collection('users').doc(userId).collection('drawings');

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
      await _drawingsRef.doc(drawing.pageId).set(model.toJson());
      return success(null);
    } catch (e, stack) {
      AppLoggerImpl.instance.error(
          'FirestoreDrawingDataSource.saveDrawing failed',
          error: e,
          stackTrace: stack);
      return failure(DrawingFailure(message: e.toString()));
    }
  }

  Future<Result<domain_drawing.Drawing, DrawingFailure>> getDrawing(
      String pageId) async {
    try {
      final doc = await _drawingsRef.doc(pageId).get();
      if (!doc.exists) {
        AppLoggerImpl.instance.failure(
            'FirestoreDrawingDataSource.getDrawing: doc for page $pageId does not exist');
        return failure(DrawingFailure.notFound);
      }
      final model =
          DrawingModel.fromJson(doc.data()! as Map<String, dynamic>);
      return success(model.toDomain());
    } catch (e, stack) {
      AppLoggerImpl.instance.error(
          'FirestoreDrawingDataSource.getDrawing failed',
          error: e,
          stackTrace: stack);
      return failure(DrawingFailure(message: e.toString()));
    }
  }

  Future<Result<void, DrawingFailure>> deleteDrawing(String pageId) async {
    try {
      await _drawingsRef.doc(pageId).delete();
      return success(null);
    } catch (e, stack) {
      AppLoggerImpl.instance.error(
          'FirestoreDrawingDataSource.deleteDrawing failed',
          error: e,
          stackTrace: stack);
      return failure(DrawingFailure(message: e.toString()));
    }
  }
}

// Extension for serialization
extension DrawingModelExtension on DrawingModel {
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
