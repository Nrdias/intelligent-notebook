import '../../../../tools/result.dart';
import '../entities/auth_user.dart';
import '../failures/auth_failure.dart';

abstract class AuthRepository {
  Future<Result<AuthUser, AuthFailure>> signInWithGoogle();
  Future<Result<void, AuthFailure>> signOut();
  Stream<Result<AuthUser, AuthFailure>> authStateChanges();
  Result<AuthUser, AuthFailure> get currentUser;
}
