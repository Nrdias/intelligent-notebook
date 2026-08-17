import '../../../../tools/logger.dart';
import '../../../../tools/result.dart';
import '../entities/drawing.dart';
import '../failures/drawing_failure.dart';
import '../repositories/drawing_repository.dart';

class SaveDrawingUseCase {
  final DrawingRepository repository;

  SaveDrawingUseCase(this.repository);

  Future<Result<void, DrawingFailure>> call(Drawing drawing) async {
    final result = await repository.saveDrawing(drawing);
    if (result case Failure(:final failure)) {
      AppLoggerImpl.instance
          .failure('SaveDrawingUseCase failure: ${failure.message}');
      return Failure(failure);
    }
    return result;
  }
}
