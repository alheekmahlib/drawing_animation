import 'package:flutter/animation.dart';

/// Compresses another function by left and right border.
class YCompressionCurve extends Curve {
  YCompressionCurve(this.a, this.b) {
    assert(b >= a);
  }

  // For bounded curves.
  final double total = 1.0;

  // Lower bound.
  final double a;

  // Upper bound.
  final double b;

  @override
  double transform(double t) => t * (b - a) / total + a;
}
