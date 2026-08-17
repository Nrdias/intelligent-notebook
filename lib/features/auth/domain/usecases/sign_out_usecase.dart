import '../../../../tools/logger.dart';
import '../../../../tools/result.dart';
import '../failures/auth_failure.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<Result<void, AuthFailure>> call() async {
    final result = await repository.signOut();
    if (result case Failure(:final failure)) {
      AppLoggerImpl.instance
          .failure('SignOutUseCase failure: ${failure.message}');
      return Failure(failure);
    }
    return result;
  }
}
