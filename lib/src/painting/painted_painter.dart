import 'package:flutter/material.dart';

import '../enums/paint_mode.dart';
import 'path_painter.dart';

/// Paints a list of [PathSegment] elements statically to a canvas (no animation).
/// Used as a background painter for segments below the animation range.
class PaintedPainter extends PathPainter {
  PaintedPainter(
      super.animation,
      super.pathSegments,
      super.customDimensions,
      super.paints,
      super.onFinishCallback,
      super.scaleToViewport,
      super.debugOptions,
      {super.paintMode = PaintMode.strokeOnly});

  @override
  void paint(Canvas canvas, Size size) {
    canvas = super.paintOrDebug(canvas, size);
    if (canPaint) {
      // Paint fill layer first (behind strokes) for fillAfterStroke mode
      paintFillLayer(canvas);

      for (final segment in pathSegments!) {
        canvas.drawPath(segment.path, getPaintForSegment(segment));
      }
    }
  }
}
