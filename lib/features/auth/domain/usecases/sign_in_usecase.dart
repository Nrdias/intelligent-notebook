import '../../../../tools/logger.dart';
import '../../../../tools/result.dart';
import '../entities/auth_user.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<Result<AuthUser, AuthFailure>> call() async {
    final result = await repository.signInWithGoogle();
    if (result case Failure(:final failure)) {
      AppLoggerImpl.instance
          .failure('SignInUseCase failure: ${failure.message}');
      return Failure(failure);
    }
    return result;
  }
}
