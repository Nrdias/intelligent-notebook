import 'package:googleapis/calendar/v3.dart' as google_api;

import '../../../../tools/logger.dart';
import '../../../../tools/result.dart';
import '../../domain/failures/calendar_failure.dart';

class GoogleCalendarDataSource {
  final google_api.CalendarApi _calendarApi;
  final String _calendarId;

  GoogleCalendarDataSource(this._calendarApi, this._calendarId);

  Future<Result<List<google_api.Event>, CalendarFailure>> getEvents(
      DateTime start, DateTime end) async {
    try {
      final events = await _calendarApi.events.list(
        _calendarId,
        timeMin: start.toUtc(),
        timeMax: end.toUtc(),
        singleEvents: true,
      );
      return success(events.items ?? []);
    } catch (e, stack) {
      AppLoggerImpl.instance.error('GoogleCalendarDataSource.getEvents failed',
          error: e, stackTrace: stack);
      return failure(CalendarFailure(message: e.toString()));
    }
  }

  Future<Result<void, CalendarFailure>> createEvent(
      google_api.Event event) async {
    try {
      await _calendarApi.events.insert(
        event,
        _calendarId,
      );
      return success(null);
    } catch (e, stack) {
      AppLoggerImpl.instance.error('GoogleCalendarDataSource.createEvent failed',
          error: e, stackTrace: stack);
      return failure(CalendarFailure(message: e.toString()));
    }
  }

  Future<Result<void, CalendarFailure>> updateEvent(
      String eventId, google_api.Event event) async {
    try {
      await _calendarApi.events.update(
        event,
        _calendarId,
        eventId,
      );
      return success(null);
    } catch (e, stack) {
      AppLoggerImpl.instance.error('GoogleCalendarDataSource.updateEvent failed',
          error: e, stackTrace: stack);
      return failure(CalendarFailure(message: e.toString()));
    }
  }

  Future<Result<void, CalendarFailure>> deleteEvent(String eventId) async {
    try {
      await _calendarApi.events.delete(
        _calendarId,
        eventId,
      );
      return success(null);
    } catch (e, stack) {
      AppLoggerImpl.instance.error('GoogleCalendarDataSource.deleteEvent failed',
          error: e, stackTrace: stack);
      return failure(CalendarFailure(message: e.toString()));
    }
  }
}
