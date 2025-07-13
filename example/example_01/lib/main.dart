import 'dart:math';

import 'package:drawing_animation/drawing_animation.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool run = true;
  AnimationDirection animationDirection = AnimationDirection.original;

  @override
  void initState() {
    super.initState();
  }

  // Function to change animation direction - دالة لتغيير اتجاه الأنميشن
  void _changeDirection(AnimationDirection direction) {
    setState(() {
      animationDirection = direction;
      run = false; // Stop current animation - توقف الأنميشن الحالي
    });
    // Restart with new direction - إعادة التشغيل بالاتجاه الجديد
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        run = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () => setState(() {
                run = !run;
              }),
          child: Icon((run) ? Icons.stop : Icons.play_arrow)),

      // Add direction control buttons - إضافة أزرار التحكم في الاتجاه
      bottomNavigationBar: Container(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => _changeDirection(AnimationDirection.leftToRight),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    animationDirection == AnimationDirection.leftToRight
                        ? Colors.blue
                        : Colors.grey,
              ),
              child: Text('يسار → يمين'),
            ),
            ElevatedButton(
              onPressed: () => _changeDirection(AnimationDirection.rightToLeft),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    animationDirection == AnimationDirection.rightToLeft
                        ? Colors.blue
                        : Colors.grey,
              ),
              child: Text('يمين ← يسار'),
            ),
            ElevatedButton(
              onPressed: () => _changeDirection(AnimationDirection.original),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    animationDirection == AnimationDirection.original
                        ? Colors.blue
                        : Colors.grey,
              ),
              child: Text('أصلي'),
            ),
          ],
        ),
      ),

      body: Center(
          child: Column(children: <Widget>[
        //Simplfied AnimatedDrawing using Flutter Path objects
        Expanded(
            child: AnimatedDrawing.paths(
          [
            (Path()
                  ..addOval(Rect.fromCircle(center: Offset.zero, radius: 75.0)))
                .transform(Matrix4.rotationX(-pi)
                    .storage), //A circle which is slightly rotated
          ],
          paints: [
            Paint()..style = PaintingStyle.stroke,
          ],
          run: run,
          animationOrder: PathOrders.original,
          animationDirection:
              animationDirection, // Use selected direction - استخدام الاتجاه المحدد
          duration: Duration(seconds: 2),
          lineAnimation: LineAnimation.oneByOne,
          animationCurve: Curves.linear,
          onFinish: () => setState(() {
            run = false;
          }),
        )),

        //Simplfied AnimatedDrawing parsing Path objects from an Svg asset
        Expanded(
            child: AnimatedDrawing.svg(
          'assets/circle.svg',
          run: run,
          animationDirection:
              animationDirection, // Use selected direction - استخدام الاتجاه المحدد
          duration: Duration(seconds: 2),
          lineAnimation: LineAnimation.oneByOne,
          animationCurve: Curves.linear,
          onFinish: () => setState(() {
            run = false;
          }),
        )),
      ])),
    );
  }
}
