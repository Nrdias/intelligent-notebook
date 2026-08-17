import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/auth/data/datasources/auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/canvas/data/datasources/firestore_drawing_datasource.dart';
import '../../features/canvas/data/datasources/hive_drawing_datasource.dart';
import '../../features/canvas/data/repositories/drawing_repository_impl.dart';
import '../../features/canvas/domain/repositories/drawing_repository.dart';
import '../../features/notebooks/data/datasources/firestore_notebook_datasource.dart';
import '../../features/notebooks/data/datasources/hive_notebook_datasource.dart';
import '../../features/notebooks/data/repositories/notebook_repository_impl.dart';
import '../../features/notebooks/domain/repositories/notebook_repository.dart';
import '../../firebase_options.dart';
import '../../tools/logger.dart';
import '../utils/constants.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // Register Logger Strategy (DebugLogger in debug mode, CrashlyticsLogger in release mode)
  getIt.registerLazySingleton<AppLogger>(() => AppLogger.instance);

  // Initialize Hive (local cache)
  await Hive.initFlutter();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Crashlytics collection only in production
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(!kDebugMode);

  // Global uncaught Flutter framework error handler
  FlutterError.onError = (errorDetails) {
    if (kDebugMode) {
      FlutterError.presentError(errorDetails);
    } else {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    }
  };

  // Global uncaught platform/isolate error handler
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.instance.error('PlatformDispatcher uncaught error',
        error: error, stackTrace: stack);
    return true;
  };

  // Register Firebase services
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => FirebaseStorage.instance);
  getIt.registerLazySingleton(() => FirebaseCrashlytics.instance);
  getIt.registerLazySingleton(() => GoogleSignIn());

  // Register auth data layer
  getIt.registerLazySingleton<AuthDataSource>(
    () => FirebaseAuthDataSource(getIt<FirebaseAuth>(), getIt<GoogleSignIn>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthDataSource>()),
  );

  // Open Hive boxes before registering them with GetIt
  final notesBox = await Hive.openBox(Constants.notesBox);
  final drawingsBox = await Hive.openBox(Constants.drawingsBox);
  final chatBox = await Hive.openBox(Constants.chatBox);

  getIt.registerLazySingleton<Box<dynamic>>(
    () => notesBox,
    instanceName: Constants.notesBox,
  );
  getIt.registerLazySingleton<Box<dynamic>>(
    () => drawingsBox,
    instanceName: Constants.drawingsBox,
  );
  getIt.registerLazySingleton<Box<dynamic>>(
    () => chatBox,
    instanceName: Constants.chatBox,
  );

  // Initialize HiveNotebookDataSource & HiveDrawingDataSource
  HiveNotebookDataSource.instance.init();
  HiveDrawingDataSource.instance.init();

  // Register Notebook Repository
  getIt.registerLazySingleton<NotebookRepository>(
    () => NotebookRepositoryImpl(
      firestoreDataSource: FirestoreNotebookDataSource(
        getIt<FirebaseFirestore>(),
        getIt<FirebaseAuth>().currentUser?.uid ?? 'guest',
      ),
      hiveDataSource: HiveNotebookDataSource.instance,
    ),
  );

  // Register Drawing Repository
  getIt.registerLazySingleton<DrawingRepository>(
    () => DrawingRepositoryImpl(
      firestoreDataSource: FirestoreDrawingDataSource(
        getIt<FirebaseFirestore>(),
        getIt<FirebaseAuth>().currentUser?.uid ?? 'guest',
      ),
      hiveDataSource: HiveDrawingDataSource.instance,
    ),
  );
}
