import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../enums/animation_direction.dart';
import '../enums/line_animation.dart';
import '../models/debug_options.dart';
import '../models/path_segment.dart';
import '../ordering/path_order.dart';
import '../painting/path_painter.dart';
import '../painting/path_painter_builder.dart';
import '../parsing/svg_parser.dart';
import '../models/animation_range.dart';
import '../widget/animated_drawing.dart';

/// Base class for drawing animation states.
abstract class AbstractAnimatedDrawingState extends State<AnimatedDrawing> {
  AbstractAnimatedDrawingState() {
    onFinishAnimation = _onFinishAnimationDefault;
  }

  AnimationController? controller;
  CurvedAnimation? curve;
  Curve? animationCurve;
  AnimationRange? range;
  String? assetPath;
  PathOrder? animationOrder;
  DebugOptions? debug;
  int lastPaintedPathIndex = -1;

  List<PathSegment> pathSegments = <PathSegment>[];
  List<PathSegment> pathSegmentsToAnimate = <PathSegment>[];
  List<PathSegment> pathSegmentsToPaintAsBackground = <PathSegment>[];

  VoidCallback? onFinishAnimation;
  bool onFinishEvoked = false;

  void _onFinishAnimationDefault() {
    if (widget.onFinish != null) {
      widget.onFinish!();
      if (debug!.recordFrames) resetFrame(debug);
    }
  }

  void onFinishFrame(int currentPaintedPathIndex) {
    if (_newPathPainted(currentPaintedPathIndex)) {
      _evokeOnPaintForNewlyPaintedPaths(currentPaintedPathIndex);
    }
    if (controller!.status == AnimationStatus.completed) {
      onFinishAnimation!();
    }
  }

  void _evokeOnPaintForNewlyPaintedPaths(int currentPaintedPathIndex) {
    final paintedPaths =
        pathSegments[currentPaintedPathIndex].pathIndex - lastPaintedPathIndex;
    for (var i = lastPaintedPathIndex + 1;
        i <= lastPaintedPathIndex + paintedPaths;
        i++) {
      _evokeOnPaintForPath(i);
    }
    lastPaintedPathIndex = currentPaintedPathIndex;
  }

  void _evokeOnPaintForPath(int i) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        widget.onPaint!(i, widget.paths[i]);
      });
    });
  }

  bool _newPathPainted(int currentPaintedPathIndex) {
    return widget.onPaint != null &&
        currentPaintedPathIndex != -1 &&
        pathSegments[currentPaintedPathIndex].pathIndex - lastPaintedPathIndex >
            0;
  }

  @override
  void didUpdateWidget(AnimatedDrawing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (animationOrder != widget.animationOrder) {
      _applyPathOrder();
    }
  }

  @override
  void initState() {
    super.initState();
    _updatePathData();
    _applyAnimationCurve();
    _applyDebugOptions();
  }

  void _applyDebugOptions() {
    debug = widget.debug;
    debug ??= DebugOptions();
  }

  void _applyAnimationCurve() {
    if (controller != null && widget.animationCurve != null) {
      curve =
          CurvedAnimation(parent: controller!, curve: widget.animationCurve!);
      animationCurve = widget.animationCurve;
    }
  }

  Animation<double> getAnimation() {
    if (widget.run == null || widget.run! == false) {
      return controller!;
    } else if (curve != null && animationCurve == widget.animationCurve) {
      return curve!;
    } else if (widget.animationCurve != null && controller != null) {
      curve =
          CurvedAnimation(parent: controller!, curve: widget.animationCurve!);
      animationCurve = widget.animationCurve;
      return curve!;
    } else {
      return controller!;
    }
  }

  void _applyPathOrder() {
    if (pathSegments.isEmpty) return;

    setState(() {
      if (_checkIfDefaultOrderSortingRequired()) {
        pathSegments.sort(Extractor.getComparator(PathOrders.original));
        animationOrder = PathOrders.original;
        return;
      }

      PathOrder? effectiveOrder = widget.animationOrder;

      if (effectiveOrder == null &&
          widget.animationDirection != AnimationDirection.original) {
        effectiveOrder =
            PathOrder.byAnimationDirection(widget.animationDirection);
      }

      if (effectiveOrder != animationOrder) {
        pathSegments.sort(Extractor.getComparator(effectiveOrder));
        animationOrder = effectiveOrder;
      }
    });
  }

  PathPainter? buildForegroundPainter() {
    if (pathSegmentsToAnimate.isEmpty) return null;
    var builder = _preparePathPainterBuilder(widget.lineAnimation);
    builder.setPathSegments(pathSegmentsToAnimate);
    return builder.build();
  }

  PathPainter? buildBackgroundPainter() {
    if (pathSegmentsToPaintAsBackground.isEmpty) return null;
    var builder = _preparePathPainterBuilder(widget.lineAnimation);
    builder.setPathSegments(pathSegmentsToPaintAsBackground);
    return builder.build();
  }

  PathPainterBuilder _preparePathPainterBuilder(LineAnimation? lineAnimation) {
    var builder = PathPainterBuilder(lineAnimation ?? LineAnimation.oneByOne);
    builder.setAnimation(getAnimation());
    builder.setCustomDimensions(_getCustomDimensions());
    builder.setPaints(widget.paints);
    builder.setOnFinishFrame(onFinishFrame);
    builder.setScaleToViewport(widget.scaleToViewport);
    builder.setDebugOptions(debug!);
    builder.setPaintMode(widget.paintMode);
    return builder;
  }

  void _assignPathSegmentsToPainters() {
    if (pathSegments.isEmpty) return;

    if (widget.range == null) {
      pathSegmentsToAnimate = pathSegments;
      range = null;
      pathSegmentsToPaintAsBackground.clear();
      return;
    }

    if (widget.range != range) {
      _checkValidRange();

      pathSegmentsToPaintAsBackground = pathSegments
          .where((x) => x.pathIndex < widget.range!.start!)
          .toList();

      pathSegmentsToAnimate = pathSegments
          .where((x) => (x.pathIndex >= widget.range!.start! &&
              x.pathIndex <= widget.range!.end!))
          .toList();

      range = widget.range;
    }
  }

  void _checkValidRange() {
    RangeError.checkValidRange(
        widget.range!.start!,
        widget.range!.end,
        widget.paths.length - 1,
        'start',
        'end',
        'The provided range is invalid for the provided number of paths.');
  }

  Size? _getCustomDimensions() {
    if (widget.height != null || widget.width != null) {
      return Size(widget.width!, widget.height!);
    }
    return null;
  }

  CustomPaint createCustomPaint(BuildContext context) {
    _updatePathData();
    return CustomPaint(
        foregroundPainter: buildForegroundPainter(),
        painter: buildBackgroundPainter(),
        size: Size.copy(MediaQuery.of(context).size));
  }

  void addListenersToAnimationController() {
    if (debug!.recordFrames) {
      controller!.view.addListener(() {
        setState(() {
          if (controller!.status == AnimationStatus.forward) {
            iterateFrame(debug!);
          }
        });
      });
    }

    controller!.view.addListener(() {
      setState(() {
        if (controller!.status == AnimationStatus.dismissed) {
          lastPaintedPathIndex = -1;
        }
      });
    });
  }

  void _updatePathData() {
    _parsePathData();
    _applyPathOrder();
    _assignPathSegmentsToPainters();
  }

  void _parsePathData() {
    var parser = SvgParser();
    if (_svgAssetProvided()) {
      if (widget.assetPath == assetPath) return;
      _parseFromSvgAsset(parser);
    } else if (_pathsProvided()) {
      _parseFromPaths(parser);
    }
  }

  void _parseFromPaths(SvgParser parser) {
    parser.loadFromPaths(widget.paths);
    setState(() {
      pathSegments = parser.getPathSegments();
    });
  }

  bool _pathsProvided() => widget.paths.isNotEmpty;

  bool _svgAssetProvided() => widget.assetPath.isNotEmpty;

  void _parseFromSvgAsset(SvgParser parser) {
    parser.loadFromFile(widget.assetPath).then((_) {
      setState(() {
        widget.paths.clear();
        widget.paths.addAll(parser.getPaths());
        pathSegments = parser.getPathSegments();
        assetPath = widget.assetPath;
      });
    });
  }

  bool _checkIfDefaultOrderSortingRequired() {
    final defaultSortingWhenNoOrderDefined =
        widget.lineAnimation == LineAnimation.allAtOnce &&
            animationOrder != PathOrders.original;
    return defaultSortingWhenNoOrderDefined || widget.lineAnimation == null;
  }
}
