import '../../../../tools/logger.dart';
import '../../../../tools/result.dart';
import '../entities/drawing.dart';
import '../failures/drawing_failure.dart';
import '../repositories/drawing_repository.dart';

class GetDrawingUseCase {
  final DrawingRepository repository;

  GetDrawingUseCase(this.repository);

  Future<Result<Drawing, DrawingFailure>> call(String pageId) async {
    final result = await repository.getDrawing(pageId);
    if (result case Failure(:final failure)) {
      AppLoggerImpl.instance
          .failure('GetDrawingUseCase failure: ${failure.message}');
      return Failure(failure);
    }
    return result;
  }
}
