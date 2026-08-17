import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../tools/logger.dart';
import '../../../../tools/result.dart';
import '../../domain/failures/auth_failure.dart';

abstract class AuthDataSource {
  Future<Result<UserCredential, AuthFailure>> signInWithGoogle();
  Future<Result<void, AuthFailure>> signOut();
  Stream<Result<User, AuthFailure>> authStateChanges();
  Result<User, AuthFailure> get currentUser;
}

class FirebaseAuthDataSource implements AuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDataSource(this._firebaseAuth, this._googleSignIn);

  @override
  Future<Result<UserCredential, AuthFailure>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        AppLoggerImpl.instance.failure(
            'FirebaseAuthDataSource.signInWithGoogle: Google sign in cancelled by user');
        return failure(const AuthFailure(message: 'Google sign in cancelled'));
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      return success(userCredential);
    } catch (e, stack) {
      AppLoggerImpl.instance.error('FirebaseAuthDataSource.signInWithGoogle failed',
          error: e, stackTrace: stack);
      return failure(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void, AuthFailure>> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      return success(null);
    } catch (e, stack) {
      AppLoggerImpl.instance.error('FirebaseAuthDataSource.signOut failed',
          error: e, stackTrace: stack);
      return failure(AuthFailure(message: e.toString()));
    }
  }

  @override
  Stream<Result<User, AuthFailure>> authStateChanges() {
    try {
      return _firebaseAuth.authStateChanges().map((user) {
        if (user == null) {
          AppLoggerImpl.instance.failure(
              'FirebaseAuthDataSource.authStateChanges: user unauthenticated');
          return failure(AuthFailure.unauthenticated);
        }
        return success(user);
      });
    } catch (e, stack) {
      AppLoggerImpl.instance.error(
          'FirebaseAuthDataSource.authStateChanges failed',
          error: e,
          stackTrace: stack);
      return Stream.value(failure(AuthFailure(message: e.toString())));
    }
  }

  @override
  Result<User, AuthFailure> get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      AppLoggerImpl.instance
          .failure('FirebaseAuthDataSource.currentUser: unauthenticated');
      return failure(AuthFailure.unauthenticated);
    }
    return success(user);
  }
}
