enum BlockType { text, drawing, image, checklist, code }

class BlockModel {
  final String id;
  final BlockType type;
  final String content;
  final Map<String, dynamic>? metadata;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  BlockModel({
    required this.id,
    required this.type,
    required this.content,
    this.metadata,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'content': content,
        'metadata': metadata,
        'order': order,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory BlockModel.fromJson(Map<String, dynamic> json) => BlockModel(
        id: json['id'] as String,
        type: BlockType.values.byName(json['type'] as String),
        content: json['content'] as String,
        metadata: json['metadata'] as Map<String, dynamic>?,
        order: json['order'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
