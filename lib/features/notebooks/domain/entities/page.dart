import 'block.dart';

class Page {
  final String id;
  final String notebookId;
  final String title;
  final String markdownContent;
  final List<Block> blocks;
  final String? thumbnailUrl;
  final String? pdfPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;

  Page({
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

  bool get isPdf => pdfPath != null && pdfPath!.isNotEmpty;

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
}
