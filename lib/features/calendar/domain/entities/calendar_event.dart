enum EventRepeat { none, daily, weekly, monthly, yearly }

class CalendarEvent {
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

  CalendarEvent({
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
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'googleEventId': googleEventId,
        'notebookId': notebookId,
        'repeat': repeat.name,
        'isSynced': isSynced,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
