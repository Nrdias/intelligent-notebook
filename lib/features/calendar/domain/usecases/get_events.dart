import '../../../../tools/logger.dart';
import '../../../../tools/result.dart';
import '../entities/calendar_event.dart';
import '../failures/calendar_failure.dart';
import '../repositories/calendar_repository.dart';

class GetEventsUseCase {
  final CalendarRepository repository;

  GetEventsUseCase(this.repository);

  Future<Result<List<CalendarEvent>, CalendarFailure>> call(
      DateTime start, DateTime end) async {
    final result = await repository.getEvents(start, end);
    if (result case Failure(:final failure)) {
      AppLoggerImpl.instance
          .failure('GetEventsUseCase failure: ${failure.message}');
      return Failure(failure);
    }
    return result;
  }
}
