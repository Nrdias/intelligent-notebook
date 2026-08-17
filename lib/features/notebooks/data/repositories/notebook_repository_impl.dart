import '../../../../tools/logger.dart';
import '../../../../tools/result.dart';
import '../../domain/entities/notebook.dart';
import '../../domain/entities/page.dart';
import '../../domain/failures/notebook_failure.dart';
import '../../domain/repositories/notebook_repository.dart';
import '../datasources/firestore_notebook_datasource.dart';
import '../datasources/hive_notebook_datasource.dart';

class NotebookRepositoryImpl implements NotebookRepository {
  final FirestoreNotebookDataSource firestoreDataSource;
  final HiveNotebookDataSource hiveDataSource;

  NotebookRepositoryImpl({
    required this.firestoreDataSource,
    required this.hiveDataSource,
  });

  @override
  Future<Result<List<Notebook>, NotebookFailure>> getAll() async {
    final remoteResult = await firestoreDataSource.getAll();
    if (remoteResult case Success(:final data)) {
      for (final notebook in data) {
        await hiveDataSource.create(notebook);
      }
      return remoteResult;
    }

    final localResult = hiveDataSource.getAll();
    if (localResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'NotebookRepositoryImpl.getAll failure: ${failure.message}');
      return Failure(failure);
    }
    return localResult;
  }

  @override
  Future<Result<Notebook, NotebookFailure>> getById(String id) async {
    final remoteResult = await firestoreDataSource.getById(id);
    if (remoteResult case Success()) {
      return remoteResult;
    }

    final localResult = hiveDataSource.getById(id);
    if (localResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'NotebookRepositoryImpl.getById failure: ${failure.message}');
      return Failure(failure);
    }
    return localResult;
  }

  @override
  Future<Result<void, NotebookFailure>> create(Notebook notebook) async {
    final hiveResult = await hiveDataSource.create(notebook);
    if (hiveResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'NotebookRepositoryImpl.create (Hive) failure: ${failure.message}');
      return Failure(failure);
    }
    final firestoreResult = await firestoreDataSource.create(notebook);
    if (firestoreResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'NotebookRepositoryImpl.create (Firestore) failure: ${failure.message}');
      return Failure(failure);
    }
    return success(null);
  }

  @override
  Future<Result<void, NotebookFailure>> update(Notebook notebook) async {
    final hiveResult = await hiveDataSource.update(notebook);
    if (hiveResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'NotebookRepositoryImpl.update (Hive) failure: ${failure.message}');
      return Failure(failure);
    }
    final firestoreResult = await firestoreDataSource.update(notebook);
    if (firestoreResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'NotebookRepositoryImpl.update (Firestore) failure: ${failure.message}');
      return Failure(failure);
    }
    return success(null);
  }

  @override
  Future<Result<void, NotebookFailure>> delete(String id) async {
    final hiveResult = await hiveDataSource.delete(id);
    if (hiveResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'NotebookRepositoryImpl.delete (Hive) failure: ${failure.message}');
      return Failure(failure);
    }
    final firestoreResult = await firestoreDataSource.delete(id);
    if (firestoreResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'NotebookRepositoryImpl.delete (Firestore) failure: ${failure.message}');
      return Failure(failure);
    }
    return success(null);
  }

  @override
  Future<Result<List<Page>, NotebookFailure>> getPages(
      String notebookId) async {
    final remoteResult = await firestoreDataSource.getPages(notebookId);
    if (remoteResult case Success()) {
      return remoteResult;
    }

    final localResult = hiveDataSource.getPages(notebookId);
    if (localResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'NotebookRepositoryImpl.getPages failure: ${failure.message}');
      return Failure(failure);
    }
    return localResult;
  }

  @override
  Future<Result<void, NotebookFailure>> savePage(Page page) async {
    final hiveResult = await hiveDataSource.savePage(page);
    if (hiveResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'NotebookRepositoryImpl.savePage (Hive) failure: ${failure.message}');
      return Failure(failure);
    }
    final firestoreResult = await firestoreDataSource.savePage(page);
    if (firestoreResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'NotebookRepositoryImpl.savePage (Firestore) failure: ${failure.message}');
      return Failure(failure);
    }
    return success(null);
  }

  @override
  Future<Result<void, NotebookFailure>> deletePage(
      String notebookId, String pageId) async {
    final hiveResult = await hiveDataSource.deletePage(notebookId, pageId);
    if (hiveResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'NotebookRepositoryImpl.deletePage (Hive) failure: ${failure.message}');
      return Failure(failure);
    }
    final firestoreResult =
        await firestoreDataSource.deletePage(notebookId, pageId);
    if (firestoreResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'NotebookRepositoryImpl.deletePage (Firestore) failure: ${failure.message}');
      return Failure(failure);
    }
    return success(null);
  }
}
