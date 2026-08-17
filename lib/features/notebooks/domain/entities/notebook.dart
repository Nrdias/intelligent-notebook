import 'page.dart';

class Notebook {
  final String id;
  final String name;
  final String description;
  final String color;
  final List<Page> pages;
  final DateTime createdAt;
  final DateTime updatedAt;

  Notebook({
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
}
