import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'abstract_drawing_state.dart';
import '../widget/animated_drawing.dart';

/// A state implementation which allows controlling the animation through
/// an animation controller when provided externally.
class AnimatedDrawingState extends AbstractAnimatedDrawingState {
  AnimatedDrawingState() : super() {
    onFinishAnimation = () {
      if (onFinishEvoked == false) {
        onFinishEvoked = true;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _onFinishAnimationDefault();
        });
      }
    };
  }

  void _onFinishAnimationDefault() {
    if (widget.onFinish != null) {
      widget.onFinish!();
    }
  }

  @override
  void initState() {
    super.initState();
    controller = widget.controller!;
    addListenersToAnimationController();
  }

  @override
  void didUpdateWidget(AnimatedDrawing oldWidget) {
    super.didUpdateWidget(oldWidget);
    controller = widget.controller!;
  }

  @override
  Widget build(BuildContext context) {
    return createCustomPaint(context);
  }
}
