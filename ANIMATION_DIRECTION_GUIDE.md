# Animation Direction Feature - ميزة اتجاه الأنميشن

تم إضافة خاصية جديدة للتحكم في اتجاه الأنميشن في باكج `drawing_animation`. هذه الخاصية تسمح للمستخدم بالتحكم في اتجاه رسم المسارات.

## الخيارات المتاحة - Available Options

### AnimationDirection enum
- `AnimationDirection.leftToRight` - الرسم من اليسار إلى اليمين
- `AnimationDirection.rightToLeft` - الرسم من اليمين إلى اليسار  
- `AnimationDirection.original` - الرسم بالترتيب الأصلي (افتراضي)

## طريقة الاستخدام - Usage

### مع AnimatedDrawing.svg
```dart
AnimatedDrawing.svg(
  "assets/my_drawing.svg",
  run: true,
  duration: Duration(seconds: 3),
  animationDirection: AnimationDirection.rightToLeft, // اتجاه من اليمين لليسار
  onFinish: () => setState(() {
    this.run = false;
  }),
)
```

### مع AnimatedDrawing.paths
```dart
AnimatedDrawing.paths(
  [
    // Path objects here
  ],
  paints: [
    Paint()..style = PaintingStyle.stroke,
  ],
  run: true,
  duration: Duration(seconds: 3),
  animationDirection: AnimationDirection.leftToRight, // اتجاه من اليسار لليمين
)
```

## مثال كامل - Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:drawing_animation/drawing_animation.dart';

class AnimationDirectionDemo extends StatefulWidget {
  @override
  _AnimationDirectionDemoState createState() => _AnimationDirectionDemoState();
}

class _AnimationDirectionDemoState extends State<AnimationDirectionDemo> {
  bool run = true;
  AnimationDirection selectedDirection = AnimationDirection.original;

  void _changeDirection(AnimationDirection direction) {
    setState(() {
      selectedDirection = direction;
      run = false;
    });
    // إعادة تشغيل الأنميشن بالاتجاه الجديد
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
        title: Text('Animation Direction Demo'),
      ),
      body: Column(
        children: [
          // أزرار التحكم في الاتجاه
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _changeDirection(AnimationDirection.leftToRight),
                child: Text('يسار لـ يمين'),
              ),
              ElevatedButton(
                onPressed: () => _changeDirection(AnimationDirection.rightToLeft),
                child: Text('يمين لـ يسار'),
              ),
              ElevatedButton(
                onPressed: () => _changeDirection(AnimationDirection.original),
                child: Text('أصلي'),
              ),
            ],
          ),
          
          // منطقة عرض الأنميشن
          Expanded(
            child: AnimatedDrawing.svg(
              "assets/my_drawing.svg",
              run: run,
              duration: Duration(seconds: 3),
              animationDirection: selectedDirection,
              onFinish: () => setState(() {
                run = false;
              }),
            ),
          ),
        ],
      ),
    );
  }
}
```

## ملاحظات - Notes

1. **التوافق مع animationOrder**: يمكن استخدام `animationDirection` مع `animationOrder`. إذا تم تحديد كلاهما، فسيتم إعطاء الأولوية لـ `animationOrder`.

2. **الأداء**: لا يؤثر استخدام `animationDirection` على أداء الأنميشن حيث أنه يستخدم نفس آليات الترتيب الموجودة.

3. **التطبيق على LineAnimation.oneByOne**: هذه الخاصية تعمل فقط مع `LineAnimation.oneByOne` (الافتراضي).

## API Reference

### AnimationDirection
```dart
enum AnimationDirection {
  leftToRight,  // من اليسار إلى اليمين
  rightToLeft,  // من اليمين إلى اليسار
  original,     // الترتيب الأصلي
}
```

### AnimatedDrawing Parameters
```dart
AnimatedDrawing.svg(
  String assetPath,
  {
    // ... other parameters
    AnimationDirection animationDirection = AnimationDirection.original,
    // ... other parameters
  }
)

AnimatedDrawing.paths(
  List<Path> paths,
  {
    // ... other parameters  
    AnimationDirection animationDirection = AnimationDirection.original,
    // ... other parameters
  }
)
```
