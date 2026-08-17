import 'package:equatable/equatable.dart';

class DrawingFailure extends Equatable {
  final String message;

  const DrawingFailure({required this.message});

  static const notFound = DrawingFailure(message: 'Drawing not found');

  @override
  List<Object?> get props => [message];
}
