import 'package:flutter/material.dart';

import '../enums/animation_direction.dart';
import '../enums/line_animation.dart';
import '../enums/paint_mode.dart';
import '../models/animation_range.dart';
import '../models/debug_options.dart';
import '../ordering/path_order.dart';
import '../animation/abstract_drawing_state.dart';
import '../animation/drawing_state.dart';
import '../animation/drawing_state_with_ticker.dart';

/// Callback when path is painted.
typedef PaintedPathCallback = void Function(int, Path);

/// A widget that iteratively draws path segment data to a defined canvas
/// (drawing line animation).
///
/// Path data can be either passed directly ([AnimatedDrawing.paths]) or via
/// an SVG file ([AnimatedDrawing.svg]).
class AnimatedDrawing extends StatefulWidget {
  /// Parses path data from an SVG asset.
  ///
  /// In order to use assets in your project specify those in `pubspec.yaml`:
  /// ```yaml
  /// assets:
  ///   - assets/my_drawing.svg
  /// ```
  AnimatedDrawing.svg(
    this.assetPath, {
    this.controller,
    this.run,
    this.duration,
    this.animationCurve,
    this.onFinish,
    this.onPaint,
    this.animationOrder,
    this.animationDirection = AnimationDirection.original,
    this.repeat = true,
    this.width,
    this.height,
    this.range,
    this.lineAnimation = LineAnimation.oneByOne,
    this.paintMode = PaintMode.strokeOnly,
    this.scaleToViewport = true,
    this.debug,
  })  : paths = [],
        paints = [] {
    assertAnimationParameters();
    assert(assetPath.isNotEmpty);
  }

  /// Creates an instance of [AnimatedDrawing] by directly passing path
  /// elements to the constructor.
  AnimatedDrawing.paths(
    this.paths, {
    this.paints = const <Paint>[],
    this.controller,
    this.run,
    this.duration,
    this.animationCurve,
    this.onFinish,
    this.onPaint,
    this.animationOrder,
    this.animationDirection = AnimationDirection.original,
    this.repeat = true,
    this.width,
    this.height,
    this.range,
    this.lineAnimation = LineAnimation.oneByOne,
    this.paintMode = PaintMode.strokeOnly,
    this.scaleToViewport = true,
    this.debug,
  }) : assetPath = '' {
    assertAnimationParameters();
    assert(paths.isNotEmpty);
    if (paints.isNotEmpty) assert(paints.length == paths.length);
  }

  /// Provide path data via an SVG asset.
  final String assetPath;

  /// Provide path data via a list of Path objects.
  final List<Path> paths;

  /// When specified, each [Path] object in [paths] is painted by applying
  /// the corresponding [Paint] object.
  final List<Paint> paints;

  /// When an animation controller is specified, the progress of the animation
  /// can be controlled externally.
  final AnimationController? controller;

  /// Easing curves adjust the rate of change of an animation over time.
  final Curve? animationCurve;

  /// Callback evoked after one animation cycle has finished.
  final VoidCallback? onFinish;

  /// Callback evoked when a complete path is painted to the canvas.
  final PaintedPathCallback? onPaint;

  /// Denotes the order in which path elements are drawn to canvas when
  /// [lineAnimation] is set to [LineAnimation.oneByOne].
  final PathOrder? animationOrder;

  /// Controls the direction of the animation.
  final AnimationDirection animationDirection;

  /// Controls whether the animation should repeat infinitely.
  final bool repeat;

  /// When no custom animation controller is provided, the state of the
  /// animation can be controlled via [run].
  final bool? run;

  /// When no custom animation controller is provided, the duration of the
  /// animation can be controlled via [duration].
  final Duration? duration;

  /// When [width] is specified parent constraints are ignored.
  final double? width;

  /// When [height] is specified parent constraints are ignored.
  final double? height;

  /// Specifies a start and end point from where to start and stop the animation.
  final AnimationRange? range;

  /// Specifies in which way the path elements are drawn to the canvas.
  final LineAnimation? lineAnimation;

  /// Controls how paths are painted: stroke only, fill only, or fill after stroke.
  final PaintMode paintMode;

  /// Denotes if the path elements should be scaled to fit into viewport.
  final bool scaleToViewport;

  /// For debugging, not for production use.
  final DebugOptions? debug;

  @override
  AbstractAnimatedDrawingState createState() {
    if (controller != null) {
      return AnimatedDrawingState();
    }
    return AnimatedDrawingWithTickerState();
  }

  void assertAnimationParameters() {
    assert(!(controller == null && (run == null || duration == null)));
  }
}
