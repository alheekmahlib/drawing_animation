/// Defines how paths are painted on the canvas.
enum PaintMode {
  /// Only the stroke (outline) of the path is drawn.
  /// This is the default behavior.
  strokeOnly,

  /// Only the fill (interior) of the path is drawn, without any stroke.
  fillOnly,

  /// The stroke animation plays first, then the fill appears behind the strokes
  /// once the animation completes.
  fillAfterStroke,
}
