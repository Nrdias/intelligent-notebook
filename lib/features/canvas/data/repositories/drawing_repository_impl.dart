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
    final hiveResult = await hiveDataSource.saveDrawing(drawing);
    if (hiveResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'DrawingRepositoryImpl.saveDrawing (Hive) failure: ${failure.message}');
      return Failure(failure);
    }
    final firestoreResult = await firestoreDataSource.saveDrawing(drawing);
    if (firestoreResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'DrawingRepositoryImpl.saveDrawing (Firestore) failure: ${failure.message}');
      return Failure(failure);
    }
    return success(null);
  }

  @override
  Future<Result<Drawing, DrawingFailure>> getDrawing(String pageId) async {
    final remoteResult = await firestoreDataSource.getDrawing(pageId);
    if (remoteResult case Success()) {
      return remoteResult;
    }

    final localResult = hiveDataSource.getDrawing(pageId);
    if (localResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'DrawingRepositoryImpl.getDrawing failure: ${failure.message}');
      return Failure(failure);
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
    final firestoreResult = await firestoreDataSource.deleteDrawing(pageId);
    if (firestoreResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'DrawingRepositoryImpl.deleteDrawing (Firestore) failure: ${failure.message}');
      return Failure(failure);
    }
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
