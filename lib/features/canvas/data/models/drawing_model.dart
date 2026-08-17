import 'dart:convert';

class DrawingModel {
  final String id;
  final String pageId;
  final String notebookId;
  final List<StrokeModel> strokes;
  final String thumbnailUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  DrawingModel({
    required this.id,
    required this.pageId,
    required this.notebookId,
    required this.strokes,
    this.thumbnailUrl = '',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'pageId': pageId,
        'notebookId': notebookId,
        'strokes': strokes.map((s) => s.toJson()).toList(),
        'thumbnailUrl': thumbnailUrl,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory DrawingModel.fromJson(Map<String, dynamic> json) => DrawingModel(
        id: json['id'] as String,
        pageId: json['pageId'] as String,
        notebookId: json['notebookId'] as String,
        strokes: (json['strokes'] as List<dynamic>)
            .map((s) => StrokeModel.fromJson(s as Map<String, dynamic>))
            .toList(),
        thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  String toBase64Json() => base64Encode(utf8.encode(jsonEncode(toJson())));

  factory DrawingModel.fromBase64Json(String base64) =>
      DrawingModel.fromJson(jsonDecode(utf8.decode(base64Decode(base64))));
}

class StrokeModel {
  final List<OffsetPoint> points;
  final double strokeWidth;
  final int color; // ARGB integer
  final bool isEraser;
  final bool isHighlighter;
  final double pressure;

  StrokeModel({
    required this.points,
    required this.strokeWidth,
    required this.color,
    this.isEraser = false,
    this.isHighlighter = false,
    this.pressure = 1.0,
  });

  Map<String, dynamic> toJson() => {
        'points': points.map((p) => p.toJson()).toList(),
        'strokeWidth': strokeWidth,
        'color': color,
        'isEraser': isEraser,
        'isHighlighter': isHighlighter,
        'pressure': pressure,
      };

  factory StrokeModel.fromJson(Map<String, dynamic> json) => StrokeModel(
        points: (json['points'] as List<dynamic>)
            .map((p) => OffsetPoint.fromJson(p as Map<String, dynamic>))
            .toList(),
        strokeWidth: (json['strokeWidth'] as num).toDouble(),
        color: json['color'] as int,
        isEraser: json['isEraser'] as bool? ?? false,
        isHighlighter: json['isHighlighter'] as bool? ?? false,
        pressure: (json['pressure'] as num?)?.toDouble() ?? 1.0,
      );
}

class OffsetPoint {
  final double x;
  final double y;
  final double pressure;

  OffsetPoint({required this.x, required this.y, this.pressure = 1.0});

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'pressure': pressure,
      };

  factory OffsetPoint.fromJson(Map<String, dynamic> json) => OffsetPoint(
        x: json['x'] as double,
        y: json['y'] as double,
        pressure: json['pressure'] as double? ?? 1.0,
      );
}
