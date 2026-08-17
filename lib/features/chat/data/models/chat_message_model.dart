import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageRole { user, assistant }

class ChatMessageModel {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final List<ContextAttachment> attachments;

  ChatMessageModel({
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
        'timestamp': Timestamp.fromDate(timestamp),
        'attachments': attachments.map((a) => a.toJson()).toList(),
      };

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => ChatMessageModel(
        id: json['id'] as String,
        role: MessageRole.values.byName(json['role'] as String),
        content: json['content'] as String,
        timestamp: (json['timestamp'] as Timestamp).toDate(),
        attachments: (json['attachments'] as List<dynamic>?)
                ?.map((a) => ContextAttachment.fromJson(a as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class ContextAttachment {
  final String type; // note, drawing, text
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

  factory ContextAttachment.fromJson(Map<String, dynamic> json) => ContextAttachment(
        type: json['type'] as String,
        content: json['content'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String?,
      );
}
