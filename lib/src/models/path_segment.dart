import 'package:flutter/material.dart';

/// Represents a segment of a path, as returned by [Path.computeMetrics],
/// along with the associated painting parameters.
class PathSegment {
  PathSegment()
      : strokeWidth = 0.0,
        color = Colors.black,
        fillColor = Colors.transparent,
        strokeCap = StrokeCap.butt,
        paintingStyle = PaintingStyle.stroke,
        firstSegmentOfPathIndex = 0,
        relativeIndex = 0,
        pathIndex = 0;

  /// A continuous path/segment.
  late Path path;

  /// Stroke width for this segment.
  late double strokeWidth;

  /// Stroke color.
  late Color color;

  /// Fill color for this segment. Defaults to transparent (no fill).
  late Color fillColor;

  /// How to end the stroke.
  late StrokeCap strokeCap;

  /// Whether to paint as stroke or fill.
  late PaintingStyle paintingStyle;

  /// Length of the segment path.
  late double length;

  /// Denotes the index of the first segment of the containing path
  /// when [PathOrder.original] is used.
  int firstSegmentOfPathIndex;

  /// Corresponding containing path index.
  int pathIndex;

  /// Denotes relative index to [firstSegmentOfPathIndex].
  int relativeIndex;
}
