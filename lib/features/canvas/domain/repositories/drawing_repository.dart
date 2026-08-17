import '../../../../tools/result.dart';
import '../entities/drawing.dart';
import '../failures/drawing_failure.dart';

abstract class DrawingRepository {
  Future<Result<void, DrawingFailure>> saveDrawing(Drawing drawing);
  Future<Result<Drawing, DrawingFailure>> getDrawing(String pageId);
  Future<Result<void, DrawingFailure>> deleteDrawing(String pageId);
  Future<Result<String, DrawingFailure>> exportAsImage(String pageId);
  Future<Result<String, DrawingFailure>> exportAsPdf(String pageId);
}
