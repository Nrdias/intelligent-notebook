import '../../../../tools/logger.dart';
import '../../../../tools/result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';
import '../models/auth_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<Result<AuthUser, AuthFailure>> signInWithGoogle() async {
    final result = await dataSource.signInWithGoogle();
    if (result case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'AuthRepositoryImpl.signInWithGoogle failure: ${failure.message}');
      return Failure(failure);
    }
    final credential = result.unwrap();
    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      const f = AuthFailure(message: 'Firebase user is null');
      AppLoggerImpl.instance
          .failure('AuthRepositoryImpl.signInWithGoogle: ${f.message}');
      return failure(f);
    }

    final user = AuthUserModel.fromFirebaseUser(firebaseUser);
    return success(user.toDomain());
  }

  @override
  Future<Result<void, AuthFailure>> signOut() async {
    final result = await dataSource.signOut();
    if (result case Failure(:final failure)) {
      AppLoggerImpl.instance
          .failure('AuthRepositoryImpl.signOut failure: ${failure.message}');
      return Failure(failure);
    }
    return success(null);
  }

  @override
  Stream<Result<AuthUser, AuthFailure>> authStateChanges() {
    return dataSource.authStateChanges().map((result) {
      if (result case Failure(:final failure)) {
        AppLoggerImpl.instance.failure(
            'AuthRepositoryImpl.authStateChanges failure: ${failure.message}');
        return Failure(failure);
      }
      final firebaseUser = result.unwrap();
      final user = AuthUserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(),
      ).toDomain();
      return success(user);
    });
  }

  @override
  Result<AuthUser, AuthFailure> get currentUser {
    final result = dataSource.currentUser;
    if (result case Failure(:final failure)) {
      AppLoggerImpl.instance
          .failure('AuthRepositoryImpl.currentUser failure: ${failure.message}');
      return Failure(failure);
    }
    final firebaseUser = result.unwrap();
    return success(AuthUserModel.fromFirebaseUser(firebaseUser).toDomain());
  }
}

// Extension on AuthUserModel to convert to domain entity
extension AuthUserModelExtension on AuthUserModel {
  AuthUser toDomain() => AuthUser(
        uid: uid,
        email: email,
        displayName: displayName,
        photoUrl: photoUrl,
        createdAt: createdAt,
      );
}
