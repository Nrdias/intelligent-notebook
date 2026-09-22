import '../../../../tools/logger.dart';
import '../../../../tools/result.dart';
import '../../domain/entities/drawing.dart';
import '../../domain/failures/drawing_failure.dart';
import '../../domain/repositories/drawing_repository.dart';
import '../datasources/firestore_drawing_datasource.dart';
import '../datasources/hive_drawing_datasource.dart';

class DrawingRepositoryImpl implements DrawingRepository {
  final FirestoreDrawingDataSource firestoreDataSource;
  final HiveDrawingDataSource hiveDataSource;

  DrawingRepositoryImpl({
    required this.firestoreDataSource,
    required this.hiveDataSource,
  });

  @override
  Future<Result<void, DrawingFailure>> saveDrawing(Drawing drawing) async {
    // 1. Write immediately to local Hive cache (Offline-First Source of Truth)
    final hiveResult = await hiveDataSource.saveDrawing(drawing);
    if (hiveResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'DrawingRepositoryImpl.saveDrawing (Hive) failure: ${failure.message}');
      return Failure(failure);
    }

    // 2. Simultaneously sync to Firestore remote database asynchronously
    firestoreDataSource.saveDrawing(drawing).then((firestoreResult) {
      if (firestoreResult case Failure(:final failure)) {
        AppLoggerImpl.instance.failure(
            'DrawingRepositoryImpl.saveDrawing (Firestore) failure: ${failure.message}');
      }
    }).catchError((e) {
      AppLoggerImpl.instance.failure(
          'DrawingRepositoryImpl.saveDrawing (Firestore) error: $e');
    });

    return success(null);
  }

  @override
  Future<Result<Drawing, DrawingFailure>> getDrawing(String pageId) async {
    // 1. Return local Hive cache instantly
    final localResult = hiveDataSource.getDrawing(pageId);
    if (localResult case Success()) {
      // In background, sync from Firestore to update local cache
      firestoreDataSource.getDrawing(pageId).then((remoteResult) {
        if (remoteResult case Success(:final data)) {
          hiveDataSource.saveDrawing(data);
        }
      }).catchError((_) {});

      return localResult;
    }

    // 2. Fallback to remote Firestore if local is missing
    final remoteResult = await firestoreDataSource.getDrawing(pageId);
    if (remoteResult case Success(:final data)) {
      await hiveDataSource.saveDrawing(data);
      return remoteResult;
    }

    return localResult;
  }

  @override
  Future<Result<void, DrawingFailure>> deleteDrawing(String pageId) async {
    final hiveResult = await hiveDataSource.deleteDrawing(pageId);
    if (hiveResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'DrawingRepositoryImpl.deleteDrawing (Hive) failure: ${failure.message}');
      return Failure(failure);
    }

    firestoreDataSource.deleteDrawing(pageId).then((firestoreResult) {
      if (firestoreResult case Failure(:final failure)) {
        AppLoggerImpl.instance.failure(
            'DrawingRepositoryImpl.deleteDrawing (Firestore) failure: ${failure.message}');
      }
    }).catchError((e) {
      AppLoggerImpl.instance.failure(
          'DrawingRepositoryImpl.deleteDrawing (Firestore) error: $e');
    });

    return success(null);
  }

  @override
  Future<Result<String, DrawingFailure>> exportAsImage(String pageId) async {
    const f = DrawingFailure(message: 'Unimplemented exportAsImage');
    AppLoggerImpl.instance.failure('DrawingRepositoryImpl.exportAsImage: ${f.message}');
    return failure(f);
  }

  @override
  Future<Result<String, DrawingFailure>> exportAsPdf(String pageId) async {
    const f = DrawingFailure(message: 'Unimplemented exportAsPdf');
    AppLoggerImpl.instance.failure('DrawingRepositoryImpl.exportAsPdf: ${f.message}');
    return failure(f);
  }
}
