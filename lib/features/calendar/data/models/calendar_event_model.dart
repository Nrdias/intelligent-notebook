import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/calendar_event.dart';

class CalendarEventModel {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String? googleEventId;
  final String? notebookId;
  final EventRepeat repeat;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  CalendarEventModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.startTime,
    required this.endTime,
    this.googleEventId,
    this.notebookId,
    this.repeat = EventRepeat.none,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'googleEventId': googleEventId,
        'notebookId': notebookId,
        'repeat': repeat.name,
        'isSynced': isSynced,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) => CalendarEventModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        startTime: (json['startTime'] as Timestamp).toDate(),
        endTime: (json['endTime'] as Timestamp).toDate(),
        googleEventId: json['googleEventId'] as String?,
        notebookId: json['notebookId'] as String?,
        repeat: EventRepeat.values.byName(json['repeat'] as String? ?? 'none'),
        isSynced: json['isSynced'] as bool? ?? false,
        createdAt: (json['createdAt'] as Timestamp).toDate(),
        updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      );
}
