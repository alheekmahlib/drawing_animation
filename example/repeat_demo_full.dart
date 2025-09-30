import 'package:drawing_animation/drawing_animation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(RepeatDemoApp());
}

class RepeatDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawing Animation Repeat Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RepeatDemoPage(),
    );
  }
}

class RepeatDemoPage extends StatefulWidget {
  @override
  _RepeatDemoPageState createState() => _RepeatDemoPageState();
}

class _RepeatDemoPageState extends State<RepeatDemoPage>
    with TickerProviderStateMixin {
  bool run1 = true;
  bool run2 = true;
  bool repeat1 = true;
  bool repeat2 = false;
  int animationCount1 = 0;
  int animationCount2 = 0;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drawing Animation Repeat Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'Drawing Animation Repeat Feature Demo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'عرض توضيحي لميزة التكرار في أنميشن الرسم',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Example 1: With Repeat
            _buildAnimationExample(
              title: 'Animation with Repeat (repeat: true)',
              subtitle: 'أنميشن مع التكرار (repeat: true)',
              description: 'This animation will loop infinitely',
              descriptionAr: 'هذا الأنميشن سيتكرر إلى ما لا نهاية',
              animationWidget: AnimatedDrawing.svg(
                "assets/circle.svg",
                run: run1,
                duration: Duration(seconds: 2),
                repeat: repeat1,
                onFinish: () {
                  setState(() {
                    animationCount1++;
                  });
                  print('Animation 1 finished! Count: $animationCount1');
                },
              ),
              run: run1,
              repeat: repeat1,
              animationCount: animationCount1,
              onToggleRun: () => setState(() => run1 = !run1),
              onToggleRepeat: () => setState(() {
                repeat1 = !repeat1;
                run1 = true;
                animationCount1 = 0;
              }),
            ),

            SizedBox(height: 32),

            // Example 2: Without Repeat
            _buildAnimationExample(
              title: 'Animation without Repeat (repeat: false)',
              subtitle: 'أنميشن بدون تكرار (repeat: false)',
              description: 'This animation will run once and stop',
              descriptionAr: 'هذا الأنميشن سيعمل مرة واحدة ويتوقف',
              animationWidget: AnimatedDrawing.svg(
                "assets/circle.svg",
                run: run2,
                duration: Duration(seconds: 2),
                repeat: repeat2,
                onFinish: () {
                  setState(() {
                    animationCount2++;
                    if (!repeat2) {
                      run2 = false;
                    }
                  });
                  print('Animation 2 finished! Count: $animationCount2');
                },
              ),
              run: run2,
              repeat: repeat2,
              animationCount: animationCount2,
              onToggleRun: () => setState(() => run2 = !run2),
              onToggleRepeat: () => setState(() {
                repeat2 = !repeat2;
                run2 = true;
                animationCount2 = 0;
              }),
            ),

            SizedBox(height: 32),

            // Usage Examples
            _buildUsageExamples(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationExample({
    required String title,
    required String subtitle,
    required String description,
    required String descriptionAr,
    required Widget animationWidget,
    required bool run,
    required bool repeat,
    required int animationCount,
    required VoidCallback onToggleRun,
    required VoidCallback onToggleRepeat,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(description),
          Text(descriptionAr, style: TextStyle(fontStyle: FontStyle.italic)),

          SizedBox(height: 16),

          // Animation Container
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Center(child: animationWidget),
          ),

          SizedBox(height: 16),

          // Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Status: ${run ? "Running" : "Stopped"}'),
              Text('Repeat: ${repeat ? "Enabled" : "Disabled"}'),
              Text('Count: $animationCount'),
            ],
          ),

          SizedBox(height: 12),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: onToggleRun,
                child: Text(run ? 'Stop' : 'Start'),
              ),
              ElevatedButton(
                onPressed: onToggleRepeat,
                child: Text(repeat ? 'Disable Repeat' : 'Enable Repeat'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageExamples() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Usage Examples - أمثلة الاستخدام',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'With Repeat (Default):',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '''AnimatedDrawing.svg(
  "assets/drawing.svg",
  run: true,
  duration: Duration(seconds: 3),
  repeat: true, // Animation loops infinitely
)''',
              style: TextStyle(fontFamily: 'monospace'),
            ),
          ),
          Text(
            'Without Repeat:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '''AnimatedDrawing.svg(
  "assets/drawing.svg",
  run: this.run,
  duration: Duration(seconds: 3),
  repeat: false, // Animation runs once
  onFinish: () => setState(() {
    this.run = false; // Stop after completion
  }),
)''',
              style: TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
