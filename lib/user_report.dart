import 'dart:convert';
import 'dart:io';

import 'package:demo/chatbot.dart';
import 'package:demo/file_operation.dart';
import 'package:demo/home.dart';
import 'package:demo/nutrition_copy.dart';
import 'package:demo/user_input.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(UserReport(arr: []));
}

Future<bool> checkIfFileExists(String filename) async {
  try {
    // Get the application documents directory
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String filePath = '${appDocDir.path}/$filename';

    // Check if the file exists
    return File(filePath).exists();
  } catch (e) {
    // Handle any errors that may occur during file checking
    print('Error checking file: $e');
    return false;
  }
}

class UserReport extends StatefulWidget {
  final List<int> arr;

  UserReport({
    required this.arr,
  });

  @override
  _UserReportState createState() => _UserReportState();
}

class _UserReportState extends State<UserReport> {
  int cmindTasks = 0;
  int csocialTasks = 0;
  int cfitnessTasks = 0;
  int cnutrition = 0;
  int cwork = 0;
  int healthscore = 0;

  @override
  void initState() {
    super.initState();
    collectData();
  }

  int countTasks(Map<String, dynamic> taskMap, String taskType) {
    int count = 0;
    taskMap.forEach((key, value) {
      if (value == taskType) {
        count++;
      }
    });
    return count;
  }

  Future<void> collectData() async {
    String fileName = "CompletedWellness.json";
    bool fileExists = await checkIfFileExists(fileName);
    Map<String, dynamic> wellness = {};

    if (fileExists) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        String contents = await file.readAsString();
        wellness = jsonDecode(contents);

        setState(() {
          cmindTasks = countTasks(wellness, 'mind');
          csocialTasks = countTasks(wellness, 'social');
          cfitnessTasks = countTasks(wellness, 'fitness');
        });
      } catch (e) {
        print('Error reading JSON data: $e');
      }

      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/CompletedWork.json');
        String contents = await file.readAsString();
        String work = jsonDecode(contents).toString();
        RegExp regex = RegExp(r':');
        Iterable<Match> matches = regex.allMatches(work);
        int colonCount = matches.length;
        print(work);
        setState(() {
          cwork = colonCount ~/ 2;
        });
        print("work $colonCount");
      } catch (e) {
        print('Error reading JSON data: $e');
      }

      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/NutritionPoints.json');
        String contents = await file.readAsString();
        int nutrition = jsonDecode(contents);

        print(contents);
        setState(() {
          cnutrition = nutrition;
          healthscore = calculateHealthScore(
              cmindTasks, csocialTasks, cfitnessTasks, cnutrition, cwork);
        });
        print("work $cnutrition");
      } catch (e) {
        print('Error reading JSON data: $e');
      }
    }
  }

  static int calculateHealthScore(
      int mind, int social, int fitness, int nutrition, int work) {
    int healthScore = ((mind * 3) +
        (social * 3) +
        (fitness * 3) +
        (nutrition * 1) +
        (work * 3));

    // Ensure the healthScore does not exceed 100
    if (healthScore > 100) {
      healthScore = 100;
    }

    return healthScore;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/userinput': (context) => const UserInput(),
        '/Nutrition': (context) => NutritionReportApp(),
        '/home': (context) => Home(),
        '/chatbot': (context) => ChatBotApp(),
      },
      home: Scaffold(
        appBar: AppBar(
          title: Text('User Report'),
        ),
        body: UserReportWidget(
          healthScore: healthscore,
          wellnessTasks: widget.arr.isNotEmpty ? widget.arr[0] : 0,
          workTasks: widget.arr.length > 1 ? widget.arr[1] : 0,
          mindTasks: cmindTasks,
          socialTasks: csocialTasks,
          fitnessTasks: cfitnessTasks,
          nutrition: cnutrition,
          work: cwork,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Stats',
              backgroundColor: Colors.black,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.food_bank),
              label: 'Add Task',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.music_note),
              label: 'Meditate',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: 'ChatBot',
            ),
          ],
          currentIndex: 1,
          selectedItemColor: Colors.blue,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushNamed(context, '/home');
                break;
              case 2:
                Navigator.pushNamed(context, '/Nutrition');
                break;
              case 3:
                Navigator.pushNamed(context, '/meditate');
                break;
              case 4:
                Navigator.pushNamed(context, '/chatbot');
                break;
            }
          },
        ),
      ),
    );
  }
}

class UserReportWidget extends StatelessWidget {
  final int healthScore;
  final int wellnessTasks;
  final int workTasks;
  final int mindTasks;
  final int socialTasks;
  final int fitnessTasks;
  final int nutrition;
  final int work;

  UserReportWidget({
    required this.healthScore,
    required this.wellnessTasks,
    required this.workTasks,
    required this.mindTasks,
    required this.socialTasks,
    required this.fitnessTasks,
    required this.nutrition,
    required this.work,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Text(
          //   'Wellness Tasks: $wellnessTasks',
          //   style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          //   textAlign: TextAlign.start,
          // ),
          // Text(
          //   'Work Tasks: $workTasks',
          //   style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          //   textAlign: TextAlign.start,
          // ),
          const SizedBox(height: 40),
          // Health Score Circle
          Container(
            width: 150,
            height: 150,
            child: Stack(
              children: [
                // Background Circle
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blueGrey,
                      width: 8.0,
                    ),
                  ),
                ),
                // Health Score Arc
                Positioned.fill(
                  child: CustomPaint(
                    painter: HealthScorePainter(healthScore),
                  ),
                ),
                // Health Score Text
                Center(
                  child: Text(
                    '$healthScore',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Task Counts
          Text('Mind : $mindTasks'),
          Text('Social : $socialTasks'),
          Text('Fitness : $fitnessTasks'),
          Text('Nutrition : $nutrition'),
          Text('Work : $work'),
        ],
      ),
    );
  }
}

class HealthScorePainter extends CustomPainter {
  final int healthScore;

  HealthScorePainter(this.healthScore);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
        center: size.center(Offset.zero), radius: size.width / 2);

    final paint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16.0;

    final startAngle = -90 * (3.14159265359 / 180);
    final sweepAngle = (healthScore / 100) * 360 * (3.14159265359 / 180);

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
