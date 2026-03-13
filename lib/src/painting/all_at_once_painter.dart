import 'package:flutter/material.dart';

import '../enums/paint_mode.dart';
import 'path_painter.dart';

/// Paints a list of [PathSegment] elements all-at-once to a canvas.
/// Each segment is drawn simultaneously with its progress tied to the animation value.
class AllAtOncePainter extends PathPainter {
  AllAtOncePainter(
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
        var subPath = segment.path
            .computeMetrics()
            .first
            .extractPath(0, segment.length * animation.value);

        canvas.drawPath(subPath, getPaintForSegment(segment));
      }

      super.onFinish(canvas, size);
    }
  }
}
