import 'package:flutter/painting.dart';

import '../enums/animation_direction.dart';
import '../models/path_segment.dart';

/// Denotes the order of [PathSegment] elements.
///
/// A [PathSegment] represents a continuous Path element which itself can be
/// contained in a [Path].
class PathOrder {
  /// The [PathSegment] order is defined according to their respective length,
  /// starting with the longest element. If [reverse] is true, the smallest
  /// element is selected first.
  PathOrder.byLength({reverse = false})
      : _comparator = _byLength(reverse: reverse);

  /// The [PathSegment] order is defined according to its position in the
  /// overall bounding box.
  PathOrder.byPosition({required AxisDirection direction})
      : _comparator = _byPosition(direction: direction);

  /// Creates PathOrder based on animation direction.
  PathOrder.byAnimationDirection(AnimationDirection direction)
      : _comparator = _byAnimationDirection(direction);

  /// Internal constructor.
  PathOrder._(this._comparator);

  /// Restores the original order of PathSegments.
  PathOrder._original() : _comparator = _originalComparator();

  final Comparator<PathSegment> _comparator;

  Comparator<PathSegment> _getComparator() {
    return _comparator;
  }

  static Comparator<PathSegment> _byLength({reverse = false}) {
    return (reverse == true)
        ? (PathSegment a, PathSegment b) => a.length.compareTo(b.length)
        : (PathSegment a, PathSegment b) => b.length.compareTo(a.length);
  }

  static Comparator<PathSegment> _byPosition(
      {required AxisDirection direction}) {
    switch (direction) {
      case AxisDirection.left:
        return (PathSegment a, PathSegment b) => b.path
            .getBounds()
            .center
            .dx
            .compareTo(a.path.getBounds().center.dx);
      case AxisDirection.right:
        return (PathSegment a, PathSegment b) => a.path
            .getBounds()
            .center
            .dx
            .compareTo(b.path.getBounds().center.dx);
      case AxisDirection.up:
        return (PathSegment a, PathSegment b) => b.path
            .getBounds()
            .center
            .dy
            .compareTo(a.path.getBounds().center.dy);
      case AxisDirection.down:
        return (PathSegment a, PathSegment b) => a.path
            .getBounds()
            .center
            .dy
            .compareTo(b.path.getBounds().center.dy);
    }
  }

  static Comparator<PathSegment> _byAnimationDirection(
      AnimationDirection direction) {
    switch (direction) {
      case AnimationDirection.leftToRight:
        return _byPosition(direction: AxisDirection.right);
      case AnimationDirection.rightToLeft:
        return _byPosition(direction: AxisDirection.left);
      case AnimationDirection.original:
        return _originalComparator();
    }
  }

  static Comparator<PathSegment> _originalComparator() {
    return (PathSegment a, PathSegment b) {
      var comp = a.firstSegmentOfPathIndex.compareTo(b.firstSegmentOfPathIndex);
      if (comp == 0) comp = a.relativeIndex.compareTo(b.relativeIndex);
      return comp;
    };
  }

  /// Returns a new PathOrder that first sorts by this instance and then by
  /// [secondPathOrder] for ties.
  PathOrder combine(PathOrder secondPathOrder) {
    return PathOrder._((PathSegment a, PathSegment b) {
      var comp = _comparator(a, b);
      if (comp == 0) comp = secondPathOrder._comparator(a, b);
      return comp;
    });
  }
}

/// A collection of common [PathOrder] constants.
class PathOrders {
  static PathOrder original = PathOrder._original();

  static PathOrder leftToRight =
      PathOrder.byPosition(direction: AxisDirection.right);

  static PathOrder rightToLeft =
      PathOrder.byPosition(direction: AxisDirection.left);

  static PathOrder topToBottom =
      PathOrder.byPosition(direction: AxisDirection.down);

  static PathOrder bottomToTop =
      PathOrder.byPosition(direction: AxisDirection.up);

  static PathOrder increasingLength = PathOrder.byLength(reverse: true);

  static PathOrder decreasingLength = PathOrder.byLength();
}

/// Utility to extract the comparator from a [PathOrder].
class Extractor {
  static Comparator<PathSegment> getComparator(PathOrder? pathOrder) {
    return pathOrder!._getComparator();
  }
}
