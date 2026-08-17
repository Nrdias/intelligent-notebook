enum MessageRole { user, assistant }

class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final List<ContextAttachment> attachments;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.attachments = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'attachments': attachments.map((a) => a.toJson()).toList(),
      };
}

class ContextAttachment {
  final String type;
  final String content;
  final String? thumbnailUrl;

  ContextAttachment({
    required this.type,
    required this.content,
    this.thumbnailUrl,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'content': content,
        'thumbnailUrl': thumbnailUrl,
      };
}
