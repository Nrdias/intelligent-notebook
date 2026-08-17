import 'page_model.dart';

class NotebookModel {
  final String id;
  final String name;
  final String description;
  final String color;
  final List<PageModel> pages;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotebookModel({
    required this.id,
    required this.name,
    this.description = '',
    this.color = '#6750A4',
    required this.pages,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'color': color,
        'pages': pages.map((p) => p.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory NotebookModel.fromJson(Map<String, dynamic> json) => NotebookModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        color: json['color'] as String? ?? '#6750A4',
        pages: (json['pages'] as List<dynamic>?)
                ?.map((p) => PageModel.fromJson(p as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
