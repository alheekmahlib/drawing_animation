import 'package:flutter/material.dart';

import '../enums/paint_mode.dart';
import '../models/path_segment.dart';
import '../ordering/path_order.dart';
import 'path_painter.dart';

/// Paints a list of [PathSegment] elements one-by-one to a canvas.
/// Each segment is drawn sequentially based on its cumulative length.
class OneByOnePainter extends PathPainter {
  OneByOnePainter(
      super.animation,
      super.pathSegments,
      super.customDimensions,
      super.paints,
      super.onFinishCallback,
      super.scaleToViewport,
      super.debugOptions,
      {super.paintMode = PaintMode.strokeOnly})
      : totalPathSum = 0 {
    if (pathSegments != null) {
      for (final e in pathSegments!) {
        totalPathSum += e.length;
      }
    }
  }

  /// The total length of all summed up [PathSegment] elements.
  double totalPathSum;

  /// The index of the last fully painted segment.
  int paintedSegmentIndex = 0;

  /// The total painted path length minus the length of the last partially painted segment.
  double _paintedLength = 0.0;

  /// Path segments which will be painted to canvas at current frame.
  List<PathSegment> toPaint = <PathSegment>[];

  @override
  void paint(Canvas canvas, Size size) {
    canvas = super.paintOrDebug(canvas, size);

    if (canPaint) {
      // Paint fill layer first (behind strokes) for fillAfterStroke mode
      paintFillLayer(canvas);

      // [1] Calculate upper bound of total path length to paint
      var upperBound = animation.value * totalPathSum;
      var currentIndex = paintedSegmentIndex;
      var currentLength = _paintedLength;
      while (currentIndex < pathSegments!.length - 1) {
        if (currentLength + pathSegments![currentIndex].length < upperBound) {
          toPaint.add(pathSegments![currentIndex]);
          currentLength += pathSegments![currentIndex].length;
          currentIndex++;
        } else {
          break;
        }
      }

      // [2] Extract subPath of last path which breaks the upper bound
      var subPathLength = upperBound - currentLength;
      var lastPathSegment = pathSegments![currentIndex];

      var subPath = lastPathSegment.path
          .computeMetrics()
          .first
          .extractPath(0, subPathLength);
      paintedSegmentIndex = currentIndex;
      _paintedLength = currentLength;

      // [3] Paint all selected paths to canvas
      late Path tmp;
      if (animation.value == 1.0) {
        toPaint.clear();
        toPaint.addAll(pathSegments!);
      } else {
        // Add last subPath temporarily
        tmp = Path.from(lastPathSegment.path);
        lastPathSegment.path = subPath;
        toPaint.add(lastPathSegment);
      }

      // Restore rendering order and paint
      toPaint.sort(Extractor.getComparator(PathOrders.original));
      for (final segment in toPaint) {
        canvas.drawPath(segment.path, getPaintForSegment(segment));
      }

      if (animation.value != 1.0) {
        // Remove last subPath
        toPaint.remove(lastPathSegment);
        lastPathSegment.path = tmp;
      }

      super.onFinish(canvas, size, lastPainted: toPaint.length - 1);
    } else {
      paintedSegmentIndex = 0;
      _paintedLength = 0.0;
      toPaint.clear();
    }
  }
}
