import 'package:drawing_animation/drawing_animation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animation Direction Demo - عرض توضيحي لاتجاه الأنميشن',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AnimationDirectionDemo(),
    );
  }
}

class AnimationDirectionDemo extends StatefulWidget {
  @override
  _AnimationDirectionDemoState createState() => _AnimationDirectionDemoState();
}

class _AnimationDirectionDemoState extends State<AnimationDirectionDemo> {
  bool run = true;
  AnimationDirection selectedDirection = AnimationDirection.original;

  void _startAnimation(AnimationDirection direction) {
    setState(() {
      selectedDirection = direction;
      run = false;
    });
    // Restart animation after a small delay - إعادة تشغيل الأنميشن بعد تأخير قصير
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        run = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Animation Direction Demo - عرض توضيحي لاتجاه الأنميشن'),
      ),
      body: Column(
        children: [
          // Control buttons - أزرار التحكم
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      _startAnimation(AnimationDirection.leftToRight),
                  child: Text('يسار لـ يمين\nLeft to Right'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedDirection == AnimationDirection.leftToRight
                            ? Colors.blue
                            : Colors.grey,
                  ),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _startAnimation(AnimationDirection.rightToLeft),
                  child: Text('يمين لـ يسار\nRight to Left'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedDirection == AnimationDirection.rightToLeft
                            ? Colors.blue
                            : Colors.grey,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _startAnimation(AnimationDirection.original),
                  child: Text('الترتيب الأصلي\nOriginal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedDirection == AnimationDirection.original
                            ? Colors.blue
                            : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Animation display area - منطقة عرض الأنميشن
          Expanded(
            child: Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AnimatedDrawing.svg(
                  "assets/circle.svg", // Make sure to add your SVG file - تأكد من إضافة ملف SVG الخاص بك
                  run: run,
                  duration: Duration(seconds: 3),
                  animationDirection: selectedDirection,
                  onFinish: () {
                    // Optional: Auto restart animation - اختياري: إعادة تشغيل الأنميشن تلقائياً
                    setState(() {
                      run = false;
                    });
                    Future.delayed(Duration(milliseconds: 500), () {
                      setState(() {
                        run = true;
                      });
                    });
                  },
                ),
              ),
            ),
          ),

          // Information text - نص المعلومات
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'اختر اتجاه الأنميشن من الأزرار أعلاه\nChoose animation direction from buttons above',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
