import '../../../../tools/result.dart';
import '../entities/calendar_event.dart';
import '../failures/calendar_failure.dart';

abstract class CalendarRepository {
  Future<Result<List<CalendarEvent>, CalendarFailure>> getEvents(
      DateTime start, DateTime end);
  Future<Result<void, CalendarFailure>> createEvent(CalendarEvent event);
  Future<Result<void, CalendarFailure>> updateEvent(CalendarEvent event);
  Future<Result<void, CalendarFailure>> deleteEvent(String id);
  Future<Result<void, CalendarFailure>> syncWithGoogle(CalendarEvent event);
}
