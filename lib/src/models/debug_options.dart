/// Options for debugging the drawing animation.
///
/// If [recordFrames] is true, the canvas of the AnimatedWidget remains white
/// while writing each frame to the file [outPutDir]/[fileName]_[frame].png.
class DebugOptions {
  DebugOptions({
    this.showBoundingBox = false,
    this.showViewPort = false,
    this.recordFrames = false,
    this.resolutionFactor = 1.0,
    this.fileName = '',
    this.outPutDir = '',
  });

  final bool showBoundingBox;
  final bool showViewPort;
  final bool recordFrames;
  final String outPutDir;
  final String fileName;

  /// The final resolution is obtained by multiplying [resolutionFactor]
  /// with the resolution of the device.
  final double resolutionFactor;

  /// Keeping track of new frames.
  int _frameCount = -1;
}

void resetFrame(DebugOptions? options) {
  options!._frameCount = -1;
}

void iterateFrame(DebugOptions options) {
  options._frameCount++;
}

int getFrameCount(DebugOptions options) {
  return options._frameCount;
}
