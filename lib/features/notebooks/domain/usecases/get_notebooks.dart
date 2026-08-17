import '../../../../tools/logger.dart';
import '../../../../tools/result.dart';
import '../entities/notebook.dart';
import '../failures/notebook_failure.dart';
import '../repositories/notebook_repository.dart';

class GetNotebooksUseCase {
  final NotebookRepository repository;

  GetNotebooksUseCase(this.repository);

  Future<Result<List<Notebook>, NotebookFailure>> call() async {
    final result = await repository.getAll();
    if (result case Failure(:final failure)) {
      AppLoggerImpl.instance
          .failure('GetNotebooksUseCase failure: ${failure.message}');
      return Failure(failure);
    }
    return result;
  }
}
