enum BlockType { text, drawing, image, checklist, code }

class Block {
  final String id;
  final BlockType type;
  final String content;
  final Map<String, dynamic>? metadata;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  Block({
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
}
