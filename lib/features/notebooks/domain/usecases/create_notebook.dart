import '../../../../tools/logger.dart';
import '../../../../tools/result.dart';
import '../entities/notebook.dart';
import '../failures/notebook_failure.dart';
import '../repositories/notebook_repository.dart';

class CreateNotebookUseCase {
  final NotebookRepository repository;

  CreateNotebookUseCase(this.repository);

  Future<Result<void, NotebookFailure>> call(Notebook notebook) async {
    final result = await repository.create(notebook);
    if (result case Failure(:final failure)) {
      AppLoggerImpl.instance
          .failure('CreateNotebookUseCase failure: ${failure.message}');
      return Failure(failure);
    }
    return result;
  }
}
