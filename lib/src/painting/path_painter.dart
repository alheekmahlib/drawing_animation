import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../enums/paint_mode.dart';
import '../models/debug_options.dart';
import '../models/path_segment.dart';
import '../utils/types.dart';

/// Abstract implementation of painting a list of [PathSegment] elements to a canvas.
abstract class PathPainter extends CustomPainter {
  PathPainter(
      this.animation,
      this.pathSegments,
      this.customDimensions,
      this.paints,
      this.onFinishCallback,
      this.scaleToViewport,
      this.debugOptions,
      {this.paintMode = PaintMode.strokeOnly})
      : canPaint = false,
        super(repaint: animation) {
    calculateBoundingBox();
  }

  /// Total bounding box of all paths.
  Rect? pathBoundingBox;

  /// For expanding the bounding box when a large stroke breaks the bounding box.
  double? strokeWidth;

  /// User defined dimensions for canvas.
  Size? customDimensions;

  final Animation<double> animation;

  /// Each [PathSegment] represents a continuous Path element of the parsed SVG.
  List<PathSegment>? pathSegments;

  /// Substitutes the paint object for each [PathSegment].
  List<Paint> paints;

  /// Status of animation.
  bool canPaint;

  bool scaleToViewport;

  /// Evoked when frame is painted.
  PaintedSegmentCallback? onFinishCallback;

  /// Painting mode: stroke only, fill only, or fill after stroke.
  PaintMode paintMode;

  // For debug.
  DebugOptions debugOptions;
  late ui.PictureRecorder recorder;

  /// Creates a [Paint] for stroke rendering of a [PathSegment].
  Paint createStrokePaint(PathSegment segment) {
    return Paint()
      ..color = segment.color
      ..style = PaintingStyle.stroke
      ..strokeCap = segment.strokeCap
      ..strokeWidth = segment.strokeWidth;
  }

  /// Creates a [Paint] for fill rendering of a [PathSegment].
  Paint createFillPaint(PathSegment segment) {
    return Paint()
      ..color = segment.fillColor
      ..style = PaintingStyle.fill;
  }

  /// Returns the appropriate [Paint] for a segment based on [paintMode].
  Paint getPaintForSegment(PathSegment segment) {
    if (paints.isNotEmpty) {
      return paints[segment.pathIndex];
    }
    switch (paintMode) {
      case PaintMode.fillOnly:
        return createFillPaint(segment);
      case PaintMode.strokeOnly:
      case PaintMode.fillAfterStroke:
        return createStrokePaint(segment);
    }
  }

  /// Draws filled paths behind strokes when animation is complete.
  /// Used by [PaintMode.fillAfterStroke].
  void paintFillLayer(Canvas canvas) {
    if (paintMode != PaintMode.fillAfterStroke || animation.value < 1.0) return;
    if (pathSegments == null) return;

    for (final segment in pathSegments!) {
      if (segment.fillColor != Colors.transparent) {
        canvas.drawPath(segment.path, createFillPaint(segment));
      }
    }
  }

  void calculateBoundingBox() {
    var bb = pathSegments!.first.path.getBounds();
    var sw = 0.0;

    for (final e in pathSegments!) {
      bb = bb.expandToInclude(e.path.getBounds());
      if (sw < e.strokeWidth) {
        sw = e.strokeWidth;
      }
    }

    if (paints.isNotEmpty) {
      for (final e in paints) {
        if (sw < e.strokeWidth) {
          sw = e.strokeWidth;
        }
      }
    }
    pathBoundingBox = bb.inflate(sw / 2);
    strokeWidth = sw;
  }

  void onFinish(Canvas canvas, Size size, {int lastPainted = -1}) {
    if (debugOptions.recordFrames) {
      final picture = recorder.endRecording();
      var frame = getFrameCount(debugOptions);
      if (frame >= 0) {
        writeToFile(
            picture,
            '${debugOptions.outPutDir}/${debugOptions.fileName}_$frame.png',
            size);
      }
    }
    onFinishCallback?.call(lastPainted);
  }

  Canvas paintOrDebug(Canvas canvas, Size size) {
    if (debugOptions.recordFrames) {
      recorder = ui.PictureRecorder();
      canvas = Canvas(recorder);
      canvas.scale(
          debugOptions.resolutionFactor, debugOptions.resolutionFactor);
    }
    paintPrepare(canvas, size);
    return canvas;
  }

  void paintPrepare(Canvas canvas, Size size) {
    canPaint = animation.status == AnimationStatus.forward ||
        animation.status == AnimationStatus.completed;

    if (canPaint) viewBoxToCanvas(canvas, size);
  }

  Future<void> writeToFile(
      ui.Picture picture, String fileName, Size size) async {
    var scale = calculateScaleFactor(size);
    var byteData = await ((await picture.toImage(
            (scale.x * debugOptions.resolutionFactor * pathBoundingBox!.width)
                .round(),
            (scale.y * debugOptions.resolutionFactor * pathBoundingBox!.height)
                .round()))
        .toByteData(format: ui.ImageByteFormat.png));
    final buffer = byteData!.buffer;
    await File(fileName).writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }

  ScaleFactor calculateScaleFactor(Size viewBox) {
    var dx = (viewBox.width) / pathBoundingBox!.width;
    var dy = (viewBox.height) / pathBoundingBox!.height;

    late double ddx, ddy;

    assert(!(dx == 0 && dy == 0));

    if (!viewBox.isEmpty) {
      if (customDimensions != null) {
        ddx = dx;
        ddy = dy;
      } else {
        ddx = ddy = min(dx, dy);
      }
    } else if (dx == 0) {
      ddx = ddy = dy;
    } else if (dy == 0) {
      ddx = ddy = dx;
    }
    return ScaleFactor(ddx, ddy);
  }

  void viewBoxToCanvas(Canvas canvas, Size size) {
    if (debugOptions.showViewPort) {
      var clipRect1 = Offset.zero & size;
      var ppp = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.green
        ..strokeWidth = 10.50;
      canvas.drawRect(clipRect1, ppp);
    }

    if (scaleToViewport) {
      var viewBox =
          (customDimensions != null) ? customDimensions : Size.copy(size);
      var scale = calculateScaleFactor(viewBox!);
      canvas.scale(scale.x, scale.y);

      var offset = Offset.zero - pathBoundingBox!.topLeft;
      canvas.translate(offset.dx, offset.dy);

      if (debugOptions.recordFrames != true) {
        var center = Offset((size.width / scale.x - pathBoundingBox!.width) / 2,
            (size.height / scale.y - pathBoundingBox!.height) / 2);
        canvas.translate(center.dx, center.dy);
      }
    }

    var clipRect = pathBoundingBox;
    if (!(debugOptions.showBoundingBox || debugOptions.showViewPort)) {
      canvas.clipRect(clipRect!);
    }

    if (debugOptions.showBoundingBox) {
      var pp = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.red
        ..strokeWidth = 0.500;
      canvas.drawRect(clipRect!, pp);
    }
  }

  @override
  bool shouldRepaint(PathPainter old) => animation.value != old.animation.value;
}

class ScaleFactor {
  const ScaleFactor(this.x, this.y);
  final double x;
  final double y;
}
