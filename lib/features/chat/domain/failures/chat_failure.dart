import 'package:equatable/equatable.dart';

class ChatFailure extends Equatable {
  final String message;

  const ChatFailure({required this.message});

  static const sessionNotFound = ChatFailure(message: 'Session not found');

  @override
  List<Object?> get props => [message];
}
