import 'dart:convert';

import 'package:demo/file_operation.dart';
import 'package:demo/usercondition.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const UserInput());
}

class UserInput extends StatelessWidget {
  const UserInput({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: const TaskListPage(),
        debugShowCheckedModeBanner: false,
        routes: {'/usercondition': (context) => const UserHealth()});
  }
}

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final TextEditingController taskController = TextEditingController();
  final List<Task> tasks = [];
  bool hasDeadline = false;
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task List"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: TextField(
                controller: taskController,
                decoration: const InputDecoration(labelText: "Task Name"),
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Checkbox(
                    value: hasDeadline,
                    onChanged: (value) {
                      setState(() {
                        hasDeadline = value!;
                      });
                    },
                  ),
                  const Text("Has Deadline"),
                ],
              ),
            ),
            if (hasDeadline)
              ListTile(
                title: ElevatedButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(DateTime.now().year + 1),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  child: Text(
                    selectedDate == null
                        ? "Pick a Deadline Date"
                        : DateFormat("MMM d, yyyy").format(selectedDate!),
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: () {
                final taskName = taskController.text;
                if (taskName.isNotEmpty) {
                  final task = Task(
                    name: taskName,
                    deadline: selectedDate,
                  );
                  setState(() {
                    tasks.add(task);
                    taskController.clear();
                    selectedDate = null;
                  });
                }
              },
              child: const Text("Add Task"),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: tasks.map((task) {
                return ListTile(
                  title: Text(task.name),
                  subtitle: task.deadline != null
                      ? Text(
                          "Deadline: ${DateFormat("MMM d, yyyy").format(task.deadline!)}")
                      : null,
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () async {
                Map<String, dynamic> taskMap = {};
                String taskName, taskDeadline = "";
                for (final task in tasks) {
                  taskName = task.name;
                  if (task.deadline != null) {
                    taskDeadline =
                        DateFormat("MMM d, yyyy").format(task.deadline!);
                  } else {
                    taskDeadline = "";
                  }
                  taskMap[taskName] = taskDeadline;
                }

                //String jsonString = jsonEncode(taskMap);
                updateJsonToFile('WorkTotal.json', taskMap);
                readJsonFromFile('WorkTotal.json');

                Navigator.pushNamed(context, '/usercondition');
              },
              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}

class Task {
  final String name;
  final DateTime? deadline;

  Task({
    required this.name,
    this.deadline,
  });
}
