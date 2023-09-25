import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:demo/chatbot.dart';
import 'package:demo/file_operation.dart';
import 'package:demo/main.dart';
import 'package:demo/nutrition.dart';
import 'package:demo/user_report.dart';
import 'package:demo/user_input.dart';
import 'package:demo/usercondition.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(Home());
List<int> stats = [];

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyToDoList(),
      routes: {
        '/userinput': (context) => const UserInput(),
        '/main': (context) => const MyApp(),
        '/home': (context) => Home(),
        '/stats': (context) => UserReport(arr: stats),
        '/usercondition': (context) => const UserHealth(),
        '/Nutrition': (context) => NutritionReportApp(),
        '/chatbot': (context) => ChatBotApp(),
      },
    );
  }
}

class MyToDoList extends StatefulWidget {
  @override
  _MyToDoListState createState() => _MyToDoListState();
}

class _MyToDoListState extends State<MyToDoList> {
  int _currentIndex = 0; // Index of the selected navigation item
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> worktasks = [];
  Map<String, dynamic> work = {};
  Map<String, Color> categoryColors = {};
  Map<String, dynamic> completedwellness = {};
  Map<String, dynamic> completedwork = {};
  @override
  void initState() {
    super.initState();
    loadTasks();
    loadWorkTasks();
  }

  Future<void> loadTasks() async {
    String fileName = 'WellnessToday.json';
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      String contents = await file.readAsString();
      Map<String, dynamic> jsonData = jsonDecode(contents);
      List<Map<String, dynamic>> dataList = [];

      jsonData.forEach((key, value) {
        // Check if the category already has a color assigned
        Color? categoryColor = categoryColors[value];
        if (categoryColor == null) {
          // Generate a random color for the category
          categoryColor = generateRandomColor();
          categoryColors[value] = categoryColor;
        }

        dataList.add(
            {'task': key, 'category': value, 'categoryColor': categoryColor});
      });

      setState(() {
        tasks = dataList;
      });
    } catch (e) {
      print('Error reading JSON data: $e');
    }
  }

  Future<void> loadWorkTasks() async {
    String fileName = 'WorkTotal.json';
    try {
      print("working tasks");
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      String contents = await file.readAsString();
      Map<String, dynamic> jsonData = jsonDecode(contents);
      List<Map<String, dynamic>> dataList = [];

      jsonData.forEach((key, value) {
        // Generate a random color for the category
        Color categoryColor = generateRandomColor();

        dataList.add(
            {'task': key, 'deadline': value, 'categoryColor': categoryColor});
      });
      setState(() {
        work = jsonData;
        worktasks = dataList;
      });
    } catch (e) {
      print('Error reading JSON data: $e');
    }
  }

  Future<void> sleepOneSecond() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> processDeleted() async {
    deleteFile('WellnessToday.json');

    completedwork.forEach((completedKey, completedValue) {
      work.removeWhere((key, value) => key == completedKey);
    });
    String workjsonString = jsonEncode(work);

    updateJsonToFile('CompletedWellness.json', completedwellness);
    updateJsonToFile('CompletedWork.json', completedwork);
    writeJsonToFile('WorkTotal.json', workjsonString);
    readJsonFromFile('CompletedWellness.json');
    await sleepOneSecond();
    Navigator.pushNamed(context, '/main');
  }

  void addWorkTasks() {
    Navigator.pushNamed(context, '/userinput');
  }

  void addhealthconditions() {
    Navigator.pushNamed(context, '/usercondition');
  }

  Color generateRandomColor() {
    final random = Random();
    return Color.fromARGB(
      150,
      random.nextInt(255),
      random.nextInt(255),
      random.nextInt(255),
    );
  }

  void handle() {
    int a = tasks.length - completedwellness.length;
    setState(() {
      stats.add(a);
      stats.add(work.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Lists For The Day'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ListTile(
              title: ElevatedButton(
                onPressed: processDeleted,
                child: const Text(
                  'End The Day', // Button text
                  style: TextStyle(fontSize: 20), // Text style
                ),
              ),
            ),
            ListTile(
              title: ElevatedButton(
                onPressed: addhealthconditions,
                child: const Text(
                  'Add Health Conditions', // Button text
                  style: TextStyle(fontSize: 20), // Text style
                ),
              ),
            ),
            ListTile(
              title: ElevatedButton(
                onPressed: addWorkTasks,
                child: const Text(
                  'Add Work Tasks', // Button text
                  style: TextStyle(fontSize: 20), // Text style
                ),
              ),
            ),
            const ListTile(
              title: Text(
                'Wellness Tasks',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];

                return ListTile(
                  title: Text(
                    task['task'] ?? 'No title',
                    style: TextStyle(
                      decoration: task['completed'] ?? false
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Text(task['category'] ?? 'No category'),
                  leading: CircleAvatar(
                    backgroundColor: task['categoryColor'],
                  ),
                  trailing: Checkbox(
                    value: task['completed'] ?? false,
                    onChanged: (value) {
                      setState(() {
                        task['completed'] = value;
                        if (value == true) {
                          completedwellness[task['task']] = task['category'];
                        } else {
                          completedwellness.remove(task['task']);
                        }
                      });
                    },
                  ),
                );
              },
            ),
            const ListTile(
              title: Text(
                'Work Tasks',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: worktasks.length,
              itemBuilder: (context, index) {
                final task2 = worktasks[index];

                return ListTile(
                  title: Text(
                    task2['task'] ?? 'No title',
                    style: TextStyle(
                      decoration: task2['completed'] ?? false
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Text(task2['deadline'] ?? 'No deadline'),
                  leading: CircleAvatar(
                    backgroundColor: task2['categoryColor'],
                  ),
                  trailing: Checkbox(
                    value: task2['completed'] ?? false,
                    onChanged: (value) {
                      setState(() {
                        task2['completed'] = value;
                        if (value == true) {
                          completedwork[task2['task']] = task2['deadline'];
                        } else {
                          completedwork.remove(task2['task']);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Stats',
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
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the selected index
          });
          switch (index) {
            case 0:
              break;
            case 1:
              handle();
              Navigator.pushNamed(context, '/stats', arguments: stats);
              break;
            case 2:
              handle();
              Navigator.pushNamed(context, '/Nutrition');
              break;
            case 3:
              handle();
              Navigator.pushNamed(context, '/meditate');
              break;
            case 4:
              handle();
              Navigator.pushNamed(context, '/chatbot');
              break;
          }
        },
      ),
    );
  }
}
