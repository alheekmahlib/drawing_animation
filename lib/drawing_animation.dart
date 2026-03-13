/// # drawing_animation
///
/// The rendering library exposes a central widget called `AnimatedDrawing` which
/// allows to render SVG paths (via `AnimatedDrawing.svg`) or Flutter Path objects
/// (via `AnimatedDrawing.paths`) in a drawing like fashion.
///
/// ## Getting Started
///
/// ```dart
/// AnimatedDrawing.svg(
///   "assets/my_drawing.svg",
///   run: this.run,
///   duration: Duration(seconds: 3),
///   onFinish: () => setState(() {
///     this.run = false;
///   }),
/// )
/// ```
///
/// ### Paint Modes
///
/// Control how paths are rendered using [PaintMode]:
/// - [PaintMode.strokeOnly] — draws only the stroke (default)
/// - [PaintMode.fillOnly] — draws only the fill
/// - [PaintMode.fillAfterStroke] — animates stroke first, then reveals fill
///
/// ```dart
/// AnimatedDrawing.svg(
///   "assets/my_drawing.svg",
///   run: true,
///   duration: Duration(seconds: 3),
///   paintMode: PaintMode.fillAfterStroke,
/// )
/// ```
library;

// Enums
export 'src/enums/animation_direction.dart';
export 'src/enums/line_animation.dart';
export 'src/enums/paint_mode.dart';

// Models
export 'src/models/debug_options.dart'
    hide resetFrame, iterateFrame, getFrameCount;
export 'src/models/animation_range.dart';

// Ordering
export 'src/ordering/path_order.dart' hide Extractor;

// Widget
export 'src/widget/animated_drawing.dart';
