import 'package:equatable/equatable.dart';

class NotebookFailure extends Equatable {
  final String message;

  const NotebookFailure({required this.message});

  static const notFound = NotebookFailure(message: 'Notebook not found');

  @override
  List<Object?> get props => [message];
}
