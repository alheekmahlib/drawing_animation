import 'package:drawing_animation/drawing_animation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawing Animation Repeat Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Drawing Animation Repeat Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool run = true;
  bool repeatEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 300,
              height: 300,
              child: AnimatedDrawing.svg(
                "assets/circle.svg",
                run: run,
                duration: Duration(seconds: 3),
                repeat: repeatEnabled, // استخدام خاصية التكرار الجديدة
                onFinish: () {
                  print('Animation finished! Repeat enabled: $repeatEnabled');
                  if (!repeatEnabled) {
                    setState(() {
                      run = false;
                    });
                  }
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Repeat: ${repeatEnabled ? "Enabled" : "Disabled"}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'Animation: ${run ? "Running" : "Stopped"}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      repeatEnabled = !repeatEnabled;
                      run =
                          true; // إعادة تشغيل الأنميشن عند تغيير إعداد التكرار
                    });
                  },
                  child:
                      Text(repeatEnabled ? 'Disable Repeat' : 'Enable Repeat'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      run = !run;
                    });
                  },
                  child: Text(run ? 'Stop' : 'Start'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
