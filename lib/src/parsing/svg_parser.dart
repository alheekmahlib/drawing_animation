import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_parsing/path_parsing.dart';
import 'package:xml/xml.dart';

import '../models/path_segment.dart';
import 'path_modifier.dart';

/// Parses a minimal subset of an SVG file and extracts all path segments.
class SvgParser {
  final List<PathSegment> _pathSegments = <PathSegment>[];
  List<Path> _paths = <Path>[];

  /// Parses a hex color string or 'none'.
  Color parseColor(String cStr) {
    if (cStr.isEmpty || cStr.trim().isEmpty) {
      throw UnsupportedError('Empty color field found.');
    }
    if (cStr[0] == '#') {
      return Color(int.parse(cStr.substring(1), radix: 16))
          .withValues(alpha: 1.0);
    } else if (cStr == 'none') {
      return Colors.transparent;
    } else {
      throw UnsupportedError(
          'Only hex color format currently supported. String: $cStr');
    }
  }

  /// Extracts segments of each path and creates [PathSegment] representations.
  void addPathSegments(
    Path path,
    int index, {
    double? strokeWidth,
    Color? color,
    Color? fillColor,
    StrokeCap? strokeCap,
  }) {
    var firstPathSegmentIndex = _pathSegments.length;
    var relativeIndex = 0;
    path.computeMetrics().forEach((metric) {
      var segment = PathSegment()
        ..path = metric.extractPath(0, metric.length)
        ..length = metric.length
        ..firstSegmentOfPathIndex = firstPathSegmentIndex
        ..pathIndex = index
        ..relativeIndex = relativeIndex;

      if (color != null) segment.color = color;
      if (strokeWidth != null) segment.strokeWidth = strokeWidth;
      if (fillColor != null) segment.fillColor = fillColor;
      if (strokeCap != null) segment.strokeCap = strokeCap;

      _pathSegments.add(segment);
      relativeIndex++;
    });
  }

  /// Parses SVG from a string, extracting path data and styling attributes.
  void loadFromString(String svgString) {
    _pathSegments.clear();
    _paths.clear();
    var index = 0;
    var doc = XmlDocument.parse(svgString);

    doc
        .findAllElements('path')
        .map((node) => node.attributes)
        .forEach((attributes) {
      var dPath = attributes.firstWhereOrNull((attr) => attr.name.local == 'd');
      if (dPath != null) {
        var path = Path();
        writeSvgPathDataToPath(dPath.value, PathModifier(path));

        Color? color;
        double? strokeWidth;
        Color? fillColor;
        StrokeCap? strokeCap;

        // [1] CSS-style attributes
        var style =
            attributes.firstWhereOrNull((attr) => attr.name.local == 'style');
        if (style != null) {
          _parseCssStyle(style.value).forEach((key, value) {
            switch (key) {
              case 'stroke':
                color = parseColor(value);
              case 'stroke-width':
                strokeWidth = double.tryParse(value);
              case 'fill':
                fillColor = parseColor(value);
              case 'stroke-linecap':
                strokeCap = _parseStrokeCap(value);
            }
          });
        }

        // [2] SVG attribute overrides
        var strokeAttr =
            attributes.firstWhereOrNull((attr) => attr.name.local == 'stroke');
        if (strokeAttr != null) {
          color = parseColor(strokeAttr.value);
        }

        var strokeWidthAttr = attributes
            .firstWhereOrNull((attr) => attr.name.local == 'stroke-width');
        if (strokeWidthAttr != null) {
          strokeWidth = double.tryParse(strokeWidthAttr.value);
        }

        var fillAttr =
            attributes.firstWhereOrNull((attr) => attr.name.local == 'fill');
        if (fillAttr != null) {
          fillColor = parseColor(fillAttr.value);
        }

        var strokeCapAttr = attributes
            .firstWhereOrNull((attr) => attr.name.local == 'stroke-linecap');
        if (strokeCapAttr != null) {
          strokeCap = _parseStrokeCap(strokeCapAttr.value);
        }

        _paths.add(path);
        addPathSegments(
          path,
          index,
          strokeWidth: strokeWidth,
          color: color,
          fillColor: fillColor,
          strokeCap: strokeCap,
        );
        index++;
      }
    });
  }

  /// Parses CSS style string into key-value pairs.
  Map<String, String> _parseCssStyle(String style) {
    final result = <String, String>{};
    for (final part in style.split(';')) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;
      final colonIndex = trimmed.indexOf(':');
      if (colonIndex == -1) continue;
      final key = trimmed.substring(0, colonIndex).trim();
      final value = trimmed.substring(colonIndex + 1).trim();
      if (key.isNotEmpty) {
        result[key] = value;
      }
    }
    return result;
  }

  /// Parses stroke-linecap SVG attribute.
  StrokeCap _parseStrokeCap(String value) {
    switch (value) {
      case 'round':
        return StrokeCap.round;
      case 'square':
        return StrokeCap.square;
      case 'butt':
      default:
        return StrokeCap.butt;
    }
  }

  /// Loads path data from a list of [Path] objects directly.
  void loadFromPaths(List<Path> paths) {
    _pathSegments.clear();
    _paths = paths;

    var index = 0;
    for (final p in paths) {
      addPathSegments(p, index);
      index++;
    }
  }

  /// Parses SVG from a provided asset path.
  Future<void> loadFromFile(String file) async {
    _pathSegments.clear();
    var svgString = await rootBundle.loadString(file);
    loadFromString(svgString);
  }

  /// Returns extracted [PathSegment] elements of parsed SVG.
  List<PathSegment> getPathSegments() {
    return _pathSegments;
  }

  /// Returns extracted [Path] elements of parsed SVG.
  List<Path> getPaths() {
    return _paths;
  }
}
