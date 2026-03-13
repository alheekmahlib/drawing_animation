import 'package:drawing_animation/src/parsing/svg_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var parser = SvgParser();

  test('Test Svg path parsing - Unsupported', () {
    //No RGBA
    expect(
        () => parser.loadFromString(
            '<svg height="210" width="400"> <path d="M150 0 L75 200 L225 200 Z" style="stroke:rgba(255,255,255);stroke-width:5.75277775" /> </svg>'),
        throwsUnsupportedError);
  });

  test('Test Svg path parsing - Supported', () {
    //Style attributes successful
    parser.loadFromString(
        '<svg height="210" width="400"> <path d="M150 0 L75 200 L225 200 Z" style="stroke:#FFFFFF;stroke-width:5.0" /> </svg>');
    expect(parser.getPathSegments().first.color, Colors.white);
    expect(parser.getPathSegments().first.strokeWidth, 5.0);
    //Node attributes successful
    parser.loadFromString(
        '<svg height="210" width="400"> <path d="M150 0 L75 200 L225 200 Z" stroke="#FFFFFF" stroke-width="5.0" /> </svg>');
    expect(parser.getPathSegments().first.color, Colors.white);
    expect(parser.getPathSegments().first.strokeWidth, 5.0);
  });

  test('Test path segment parsing', () {
    //Default color
    parser.loadFromPaths(
        [Path()..addRect(Rect.fromCircle(center: Offset.zero, radius: 2.0))]);
    expect(parser.getPathSegments().first.color, Colors.black);
    //Bounding box
    parser.loadFromPaths(
        [Path()..addRect(Rect.fromCircle(center: Offset.zero, radius: 2.0))]);
    expect(parser.getPathSegments().first.length, 16);
  });

  // --- Fill parsing tests ---

  test('Test fill parsing - SVG attribute fill="#FF0000"', () {
    parser.loadFromString(
        '<svg height="210" width="400"> <path d="M150 0 L75 200 L225 200 Z" fill="#FF0000" stroke="#000000" stroke-width="1.0" /> </svg>');
    expect(parser.getPathSegments().first.fillColor,
        Color(0xFFFF0000).withValues(alpha: 1.0));
  });

  test('Test fill parsing - SVG attribute fill="none"', () {
    parser.loadFromString(
        '<svg height="210" width="400"> <path d="M150 0 L75 200 L225 200 Z" fill="none" stroke="#000000" stroke-width="1.0" /> </svg>');
    expect(parser.getPathSegments().first.fillColor, Colors.transparent);
  });

  test('Test fill parsing - CSS style fill', () {
    parser.loadFromString(
        '<svg height="210" width="400"> <path d="M150 0 L75 200 L225 200 Z" style="fill:#00FF00;stroke:#000000;stroke-width:1.0" /> </svg>');
    expect(parser.getPathSegments().first.fillColor,
        Color(0xFF00FF00).withValues(alpha: 1.0));
  });

  test('Test fill parsing - default fill is transparent', () {
    parser.loadFromString(
        '<svg height="210" width="400"> <path d="M150 0 L75 200 L225 200 Z" stroke="#000000" stroke-width="1.0" /> </svg>');
    expect(parser.getPathSegments().first.fillColor, Colors.transparent);
  });

  test('Test stroke-linecap parsing - round', () {
    parser.loadFromString(
        '<svg height="210" width="400"> <path d="M150 0 L75 200 L225 200 Z" stroke="#000000" stroke-width="1.0" stroke-linecap="round" /> </svg>');
    expect(parser.getPathSegments().first.strokeCap, StrokeCap.round);
  });

  test('Test stroke-linecap parsing - square', () {
    parser.loadFromString(
        '<svg height="210" width="400"> <path d="M150 0 L75 200 L225 200 Z" stroke="#000000" stroke-width="1.0" stroke-linecap="square" /> </svg>');
    expect(parser.getPathSegments().first.strokeCap, StrokeCap.square);
  });

  test('Test stroke-linecap parsing - CSS style', () {
    parser.loadFromString(
        '<svg height="210" width="400"> <path d="M150 0 L75 200 L225 200 Z" style="stroke:#000000;stroke-width:1.0;stroke-linecap:round" /> </svg>');
    expect(parser.getPathSegments().first.strokeCap, StrokeCap.round);
  });
}
