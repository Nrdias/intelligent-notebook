import 'package:equatable/equatable.dart';

class CalendarFailure extends Equatable {
  final String message;

  const CalendarFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
