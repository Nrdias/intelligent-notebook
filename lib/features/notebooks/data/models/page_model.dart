import 'block_model.dart';

class PageModel {
  final String id;
  final String notebookId;
  final String title;
  final String markdownContent;
  final List<BlockModel> blocks;
  final String? thumbnailUrl;
  final String? pdfPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;

  PageModel({
    required this.id,
    required this.notebookId,
    required this.title,
    required this.markdownContent,
    required this.blocks,
    this.thumbnailUrl,
    this.pdfPath,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'notebookId': notebookId,
        'title': title,
        'markdownContent': markdownContent,
        'blocks': blocks.map((b) => b.toJson()).toList(),
        'thumbnailUrl': thumbnailUrl,
        'pdfPath': pdfPath,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isPinned': isPinned,
      };

  factory PageModel.fromJson(Map<String, dynamic> json) => PageModel(
        id: json['id'] as String,
        notebookId: json['notebookId'] as String,
        title: json['title'] as String,
        markdownContent: json['markdownContent'] as String? ?? '',
        blocks: (json['blocks'] as List<dynamic>?)
                ?.map((b) => BlockModel.fromJson(Map<String, dynamic>.from(b as Map)))
                .toList() ??
            const [],
        thumbnailUrl: json['thumbnailUrl'] as String?,
        pdfPath: json['pdfPath'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        isPinned: json['isPinned'] as bool? ?? false,
      );
}
