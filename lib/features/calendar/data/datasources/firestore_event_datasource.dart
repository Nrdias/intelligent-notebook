import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../tools/logger.dart';
import '../../../../tools/result.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/failures/calendar_failure.dart';
import '../models/calendar_event_model.dart';

class FirestoreEventDataSource {
  final FirebaseFirestore _firestore;
  final String userId;

  FirestoreEventDataSource(this._firestore, this.userId);

  CollectionReference get _eventsRef =>
      _firestore.collection('users').doc(userId).collection('events');

  Future<Result<List<CalendarEvent>, CalendarFailure>> getEvents(
      DateTime start, DateTime end) async {
    try {
      final snapshot = await _eventsRef
          .where('startTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('startTime', isLessThan: Timestamp.fromDate(end))
          .orderBy('startTime')
          .get();

      final events = snapshot.docs
          .map((doc) =>
              CalendarEventModel.fromJson(doc.data() as Map<String, dynamic>)
                  .toDomain())
          .toList();
      return success(events);
    } catch (e, stack) {
      AppLoggerImpl.instance.error('FirestoreEventDataSource.getEvents failed',
          error: e, stackTrace: stack);
      return failure(CalendarFailure(message: e.toString()));
    }
  }

  Future<Result<void, CalendarFailure>> createEvent(
      CalendarEvent event) async {
    try {
      await _eventsRef.doc(event.id).set(event.toJson());
      return success(null);
    } catch (e, stack) {
      AppLoggerImpl.instance.error('FirestoreEventDataSource.createEvent failed',
          error: e, stackTrace: stack);
      return failure(CalendarFailure(message: e.toString()));
    }
  }

  Future<Result<void, CalendarFailure>> updateEvent(
      CalendarEvent event) async {
    try {
      await _eventsRef.doc(event.id).update({
        'title': event.title,
        'description': event.description,
        'startTime': Timestamp.fromDate(event.startTime),
        'endTime': Timestamp.fromDate(event.endTime),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return success(null);
    } catch (e, stack) {
      AppLoggerImpl.instance.error('FirestoreEventDataSource.updateEvent failed',
          error: e, stackTrace: stack);
      return failure(CalendarFailure(message: e.toString()));
    }
  }

  Future<Result<void, CalendarFailure>> deleteEvent(String id) async {
    try {
      await _eventsRef.doc(id).delete();
      return success(null);
    } catch (e, stack) {
      AppLoggerImpl.instance.error('FirestoreEventDataSource.deleteEvent failed',
          error: e, stackTrace: stack);
      return failure(CalendarFailure(message: e.toString()));
    }
  }
}

extension CalendarEventModelExtension on CalendarEventModel {
  CalendarEvent toDomain() => CalendarEvent(
        id: id,
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        googleEventId: googleEventId,
        notebookId: notebookId,
        repeat: repeat,
        isSynced: isSynced,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
