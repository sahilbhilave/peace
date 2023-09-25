import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:demo/Process/processTime.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(Home());

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyToDoList(),
    );
  }
}

class MyToDoList extends StatefulWidget {
  @override
  _MyToDoListState createState() => _MyToDoListState();
}

class _MyToDoListState extends State<MyToDoList> {
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> worktasks = [];
  Map<String, String> timerange = {};

  @override
  void initState() {
    super.initState();
    loadTasks();
    loadWorkTasks();
    timeRange();
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
        dataList.add({'task': key, 'category': value});
        //print('$key: $value');
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
        dataList.add({'task': key, 'deadline': value});
        print('$key: $value');
      });
      setState(() {
        worktasks = dataList;
      });
    } catch (e) {
      print('Error reading JSON data: $e');
    }
  }

  Future<void> timeRange() async {
    String fileName = 'timeranges.txt';
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      String fileContents = await file.readAsString();
      Map<String, String> time = processHours(fileContents);
      setState(() {
        timerange = time;
      });
    } catch (e) {
      print("Error reading file: $e");
    }
  }

  Color generateRandomColor() {
    final random = Random();
    return Color(0xFF000000 + random.nextInt(0x00FFFFFF));
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
                      });
                    },
                  ),
                );
              },
            ),
            ListTile(
              title: Text(
                'Your Work Time \n ${timerange.isNotEmpty ? timerange.toString() : 'Default Value if null'}',
                style: const TextStyle(
                  fontSize: 18.0,
                ),
              ),
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
            icon: Icon(Icons.food_bank),
            label: 'Add Task',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Meditate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Message',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          // Handle navigation button taps here
          // You can implement navigation logic based on the index
        },
      ),
    );
  }
}
