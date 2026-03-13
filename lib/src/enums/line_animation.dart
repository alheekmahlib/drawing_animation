/// The enum [LineAnimation] selects an internal painter for animating each path segment.
enum LineAnimation {
  /// Paints every path segment one after another to the canvas.
  oneByOne,

  /// When selected each path segment is drawn simultaneously to the canvas.
  allAtOnce,
}
