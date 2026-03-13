import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'abstract_drawing_state.dart';
import '../widget/animated_drawing.dart';

/// A state implementation with an internal animation controller to simplify
/// the animation process.
class AnimatedDrawingWithTickerState extends AbstractAnimatedDrawingState
    with SingleTickerProviderStateMixin {
  AnimatedDrawingWithTickerState() : super() {
    onFinishAnimation = () {
      if (onFinishEvoked == false) {
        onFinishEvoked = true;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _onFinishAnimationDefault();
        });
        if (!widget.repeat &&
            (controller!.status == AnimationStatus.dismissed ||
                controller!.status == AnimationStatus.completed)) {
          finished = true;
        }
      }
    };
  }

  void _onFinishAnimationDefault() {
    if (widget.onFinish != null) {
      widget.onFinish!();
    }
  }

  bool paused = false;
  bool finished = true;

  @override
  void didUpdateWidget(AnimatedDrawing oldWidget) {
    super.didUpdateWidget(oldWidget);
    controller!.duration = widget.duration;
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    addListenersToAnimationController();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    buildAnimation();
    return createCustomPaint(context);
  }

  Future<void> buildAnimation() async {
    try {
      if ((paused ||
              (finished &&
                  (controller!.status == AnimationStatus.forward) == false)) &&
          widget.run == true) {
        paused = false;
        finished = false;
        controller!.reset();
        onFinishEvoked = false;

        if (widget.repeat) {
          controller!.repeat();
        } else {
          await controller!.forward();
        }
      } else if ((controller!.status == AnimationStatus.forward) &&
          widget.run == false) {
        controller!.stop();
        paused = true;
      }
    } on TickerCanceled {
      // Widget was disposed during animation.
    }
  }
}
