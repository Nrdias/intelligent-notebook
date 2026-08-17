import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../tools/result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';

// State
class AuthState {
  final bool isAuthenticated;
  final AuthUser? user;
  final bool isLoading;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = true,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    AuthUser? user,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Provider
final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository: repository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;
  late final StreamSubscription _authSub;

  AuthNotifier({required this.repository}) : super(const AuthState()) {
    _authSub = repository.authStateChanges().listen((result) {
      if (result case Failure()) {
        state = const AuthState(
          isAuthenticated: false,
          user: null,
          isLoading: false,
        );
        return;
      }
      final user = result.unwrap();
      state = AuthState(
        isAuthenticated: true,
        user: user,
        isLoading: false,
      );
    });
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true);
    final result = await SignInUseCase(repository).call();
    if (result case Failure()) {
      state = state.copyWith(isLoading: false);
      return;
    }
    state = state.copyWith(
      isAuthenticated: true,
      user: result.unwrap(),
      isLoading: false,
    );
  }

  Future<void> signOut() async {
    final result = await SignOutUseCase(repository).call();
    if (result case Failure()) {
      return;
    }
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}

// Repository provider (wired via GetIt)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return getIt<AuthRepository>();
});
