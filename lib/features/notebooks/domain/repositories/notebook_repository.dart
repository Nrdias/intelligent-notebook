import '../../../../tools/result.dart';
import '../entities/notebook.dart';
import '../entities/page.dart';
import '../failures/notebook_failure.dart';

abstract class NotebookRepository {
  // Notebooks
  Future<Result<List<Notebook>, NotebookFailure>> getAll();
  Future<Result<Notebook, NotebookFailure>> getById(String id);
  Future<Result<void, NotebookFailure>> create(Notebook notebook);
  Future<Result<void, NotebookFailure>> update(Notebook notebook);
  Future<Result<void, NotebookFailure>> delete(String id);

  // Pages
  Future<Result<List<Page>, NotebookFailure>> getPages(String notebookId);
  Future<Result<void, NotebookFailure>> savePage(Page page);
  Future<Result<void, NotebookFailure>> deletePage(
      String notebookId, String pageId);
}
