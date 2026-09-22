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
    final localResult = hiveDataSource.getAll();
    if (localResult case Success(:final data) when data.isNotEmpty) {
      // In background, sync fresh data from Firestore and update local cache
      firestoreDataSource.getAll().then((remoteResult) {
        if (remoteResult case Success(:final data)) {
          for (final notebook in data) {
            hiveDataSource.create(notebook);
          }
        }
      }).catchError((_) {});

      return localResult;
    }

    final remoteResult = await firestoreDataSource.getAll();
    if (remoteResult case Success(:final data)) {
      for (final notebook in data) {
        await hiveDataSource.create(notebook);
      }
      return remoteResult;
    }

    return localResult;
  }

  @override
  Future<Result<Notebook, NotebookFailure>> getById(String id) async {
    final localResult = hiveDataSource.getById(id);
    if (localResult case Success()) {
      firestoreDataSource.getById(id).then((remoteResult) {
        if (remoteResult case Success(:final data)) {
          hiveDataSource.create(data);
        }
      }).catchError((_) {});

      return localResult;
    }

    final remoteResult = await firestoreDataSource.getById(id);
    if (remoteResult case Success(:final data)) {
      await hiveDataSource.create(data);
      return remoteResult;
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

    firestoreDataSource.create(notebook).then((firestoreResult) {
      if (firestoreResult case Failure(:final failure)) {
        AppLoggerImpl.instance.failure(
            'NotebookRepositoryImpl.create (Firestore) failure: ${failure.message}');
      }
    }).catchError((e) {
      AppLoggerImpl.instance.failure(
          'NotebookRepositoryImpl.create (Firestore) error: $e');
    });

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

    firestoreDataSource.update(notebook).then((firestoreResult) {
      if (firestoreResult case Failure(:final failure)) {
        AppLoggerImpl.instance.failure(
            'NotebookRepositoryImpl.update (Firestore) failure: ${failure.message}');
      }
    }).catchError((e) {
      AppLoggerImpl.instance.failure(
          'NotebookRepositoryImpl.update (Firestore) error: $e');
    });

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

    firestoreDataSource.delete(id).then((firestoreResult) {
      if (firestoreResult case Failure(:final failure)) {
        AppLoggerImpl.instance.failure(
            'NotebookRepositoryImpl.delete (Firestore) failure: ${failure.message}');
      }
    }).catchError((e) {
      AppLoggerImpl.instance.failure(
          'NotebookRepositoryImpl.delete (Firestore) error: $e');
    });

    return success(null);
  }

  @override
  Future<Result<List<Page>, NotebookFailure>> getPages(
      String notebookId) async {
    final localResult = hiveDataSource.getPages(notebookId);
    if (localResult case Success(:final data) when data.isNotEmpty) {
      firestoreDataSource.getPages(notebookId).then((remoteResult) {
        if (remoteResult case Success()) {
          // background sync
        }
      }).catchError((_) {});

      return localResult;
    }

    final remoteResult = await firestoreDataSource.getPages(notebookId);
    if (remoteResult case Success()) {
      return remoteResult;
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

    firestoreDataSource.savePage(page).then((firestoreResult) {
      if (firestoreResult case Failure(:final failure)) {
        AppLoggerImpl.instance.failure(
            'NotebookRepositoryImpl.savePage (Firestore) failure: ${failure.message}');
      }
    }).catchError((e) {
      AppLoggerImpl.instance.failure(
          'NotebookRepositoryImpl.savePage (Firestore) error: $e');
    });

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

    firestoreDataSource.deletePage(notebookId, pageId).then((firestoreResult) {
      if (firestoreResult case Failure(:final failure)) {
        AppLoggerImpl.instance.failure(
            'NotebookRepositoryImpl.deletePage (Firestore) failure: ${failure.message}');
      }
    }).catchError((e) {
      AppLoggerImpl.instance.failure(
          'NotebookRepositoryImpl.deletePage (Firestore) error: $e');
    });

    return success(null);
  }
}
