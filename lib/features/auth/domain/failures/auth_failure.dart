import 'package:equatable/equatable.dart';

class AuthFailure extends Equatable {
  final String message;

  const AuthFailure({required this.message});

  static const unauthenticated = AuthFailure(message: 'User is unauthenticated');
  static const userNotFound = AuthFailure(message: 'User not found');

  @override
  List<Object?> get props => [message];
}
