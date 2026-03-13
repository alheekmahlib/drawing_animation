import 'package:flutter/material.dart';

import '../enums/line_animation.dart';
import '../enums/paint_mode.dart';
import '../models/debug_options.dart';
import '../models/path_segment.dart';
import 'all_at_once_painter.dart';
import 'one_by_one_painter.dart';
import 'path_painter.dart';

/// Builds a [PathPainter] based on configuration parameters.
class PathPainterBuilder {
  PathPainterBuilder(this.lineAnimation);

  late List<Paint> paints;
  void Function(int currentPaintedPathIndex)? onFinishFrame;
  late bool scaleToViewport;
  late DebugOptions debugOptions;
  late List<PathSegment> pathSegments;
  LineAnimation lineAnimation;
  late Animation<double> animation;
  Size? customDimensions;
  PaintMode paintMode = PaintMode.strokeOnly;

  PathPainter build() {
    switch (lineAnimation) {
      case LineAnimation.oneByOne:
        return OneByOnePainter(animation, pathSegments, customDimensions,
            paints, onFinishFrame, scaleToViewport, debugOptions,
            paintMode: paintMode);
      case LineAnimation.allAtOnce:
        return AllAtOncePainter(animation, pathSegments, customDimensions,
            paints, onFinishFrame, scaleToViewport, debugOptions,
            paintMode: paintMode);
    }
  }

  void setAnimation(Animation<double> animation) {
    this.animation = animation;
  }

  void setCustomDimensions(Size? customDimensions) {
    this.customDimensions = customDimensions;
  }

  void setPaints(List<Paint> paints) {
    this.paints = paints;
  }

  void setOnFinishFrame(
      void Function(int currentPaintedPathIndex) onFinishFrame) {
    this.onFinishFrame = onFinishFrame;
  }

  void setScaleToViewport(bool scaleToViewport) {
    this.scaleToViewport = scaleToViewport;
  }

  void setDebugOptions(DebugOptions debug) {
    debugOptions = debug;
  }

  void setPathSegments(List<PathSegment> pathSegments) {
    this.pathSegments = pathSegments;
  }

  void setPaintMode(PaintMode paintMode) {
    this.paintMode = paintMode;
  }
}
