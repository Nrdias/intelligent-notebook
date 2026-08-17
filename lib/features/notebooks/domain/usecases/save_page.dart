import '../../../../tools/logger.dart';
import '../../../../tools/result.dart';
import '../entities/page.dart';
import '../failures/notebook_failure.dart';
import '../repositories/notebook_repository.dart';

class SavePageUseCase {
  final NotebookRepository repository;

  SavePageUseCase(this.repository);

  Future<Result<void, NotebookFailure>> call(Page page) async {
    final result = await repository.savePage(page);
    if (result case Failure(:final failure)) {
      AppLoggerImpl.instance
          .failure('SavePageUseCase failure: ${failure.message}');
      return Failure(failure);
    }
    return result;
  }
}
