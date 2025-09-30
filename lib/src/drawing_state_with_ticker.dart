import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'abstract_drawing_state.dart';
import 'drawing_widget.dart';

/// A state implementation with an implemented animation controller to simplify the animation process
class AnimatedDrawingWithTickerState extends AbstractAnimatedDrawingState
    with SingleTickerProviderStateMixin {
  AnimatedDrawingWithTickerState() : super() {
    onFinishAnimation = () {
      if (onFinishEvoked == false) {
        onFinishEvoked = true;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          onFinishAnimationDefault();
        });
        //Animation is completed when last frame is painted not when animation controller is finished
        // Only mark as finished if repeat is disabled - لا نضع علامة انتهاء إلا إذا كان التكرار معطلاً
        if (!widget.repeat &&
            (controller!.status == AnimationStatus.dismissed ||
                controller!.status == AnimationStatus.completed)) {
          finished = true;
        }
      }
    };
  }

  //Manage state
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

//
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

        // Check if repeat is enabled - فحص ما إذا كان التكرار مفعلاً
        if (widget.repeat) {
          // Use repeat() method for infinite loop - استخدام دالة repeat() للتكرار اللانهائي
          controller!.repeat();
        } else {
          // Run animation only once - تشغيل الأنميشن مرة واحدة فقط
          await controller!.forward();
        }
      } else if ((controller!.status == AnimationStatus.forward) &&
          widget.run == false) {
        controller!.stop();
        paused = true;
      }
    } on TickerCanceled {
      // TODO usecase?
    }
  }
}
