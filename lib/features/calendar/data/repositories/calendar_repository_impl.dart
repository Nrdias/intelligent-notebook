import '../../../../tools/logger.dart';
import '../../../../tools/result.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/failures/calendar_failure.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/firestore_event_datasource.dart';
import '../datasources/google_calendar_datasource.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final GoogleCalendarDataSource googleDataSource;
  final FirestoreEventDataSource firestoreDataSource;

  CalendarRepositoryImpl({
    required this.googleDataSource,
    required this.firestoreDataSource,
  });

  @override
  Future<Result<List<CalendarEvent>, CalendarFailure>> getEvents(
      DateTime start, DateTime end) async {
    final googleResult = await googleDataSource.getEvents(start, end);
    if (googleResult case Success(:final data)) {
      final events = data.map((e) => _googleEventToDomain(e)).toList();
      return success(events);
    }

    final firestoreResult = await firestoreDataSource.getEvents(start, end);
    if (firestoreResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'CalendarRepositoryImpl.getEvents failure: ${failure.message}');
      return Failure(failure);
    }
    return firestoreResult;
  }

  @override
  Future<Result<void, CalendarFailure>> createEvent(CalendarEvent event) async {
    final firestoreResult = await firestoreDataSource.createEvent(event);
    if (firestoreResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'CalendarRepositoryImpl.createEvent failure: ${failure.message}');
      return Failure(failure);
    }
    await _syncToGoogle(event);
    return success(null);
  }

  @override
  Future<Result<void, CalendarFailure>> updateEvent(CalendarEvent event) async {
    final firestoreResult = await firestoreDataSource.updateEvent(event);
    if (firestoreResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'CalendarRepositoryImpl.updateEvent failure: ${failure.message}');
      return Failure(failure);
    }
    if (event.googleEventId != null) {
      await _syncToGoogle(event);
    }
    return success(null);
  }

  @override
  Future<Result<void, CalendarFailure>> deleteEvent(String id) async {
    final eventsResult = await firestoreDataSource.getEvents(
      DateTime.now().subtract(const Duration(days: 365)),
      DateTime.now().add(const Duration(days: 365)),
    );
    if (eventsResult case Success(:final data)) {
      final event = data.firstWhere(
        (e) => e.id == id,
        orElse: () => CalendarEvent(
          id: '',
          title: '',
          startTime: DateTime.now(),
          endTime: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      if (event.googleEventId != null) {
        await googleDataSource.deleteEvent(event.googleEventId!);
      }
    }

    final deleteResult = await firestoreDataSource.deleteEvent(id);
    if (deleteResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'CalendarRepositoryImpl.deleteEvent failure: ${failure.message}');
      return Failure(failure);
    }
    return success(null);
  }

  @override
  Future<Result<void, CalendarFailure>> syncWithGoogle(
      CalendarEvent event) async {
    return _syncToGoogle(event);
  }

  Future<Result<void, CalendarFailure>> _syncToGoogle(
      CalendarEvent event) async {
    return success(null);
  }

  CalendarEvent _googleEventToDomain(dynamic googleEvent) {
    return CalendarEvent(
      id: googleEvent.id ?? '',
      title: googleEvent.summary ?? '',
      description: googleEvent.description ?? '',
      startTime: DateTime.parse(googleEvent.start?.dateTime?.toIso8601String() ??
          DateTime.now().toIso8601String()),
      endTime: DateTime.parse(googleEvent.end?.dateTime?.toIso8601String() ??
          DateTime.now().toIso8601String()),
      googleEventId: googleEvent.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
