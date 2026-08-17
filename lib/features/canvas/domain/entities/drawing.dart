class Drawing {
  final String id;
  final String pageId;
  final String notebookId;
  final List<Stroke> strokes;
  final String thumbnailUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Drawing({
    required this.id,
    required this.pageId,
    required this.notebookId,
    required this.strokes,
    this.thumbnailUrl = '',
    required this.createdAt,
    required this.updatedAt,
  });
}

class Stroke {
  final List<OffsetPoint> points;
  final double strokeWidth;
  final int color;
  final bool isEraser;
  final bool isHighlighter;
  final double pressure;

  Stroke({
    required this.points,
    required this.strokeWidth,
    required this.color,
    this.isEraser = false,
    this.isHighlighter = false,
    this.pressure = 1.0,
  });

  Stroke copyWith({
    List<OffsetPoint>? points,
    double? strokeWidth,
    int? color,
    bool? isEraser,
    bool? isHighlighter,
    double? pressure,
  }) {
    return Stroke(
      points: points ?? this.points,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      color: color ?? this.color,
      isEraser: isEraser ?? this.isEraser,
      isHighlighter: isHighlighter ?? this.isHighlighter,
      pressure: pressure ?? this.pressure,
    );
  }
}

class OffsetPoint {
  final double x;
  final double y;
  final double pressure;

  OffsetPoint({required this.x, required this.y, this.pressure = 1.0});
}
