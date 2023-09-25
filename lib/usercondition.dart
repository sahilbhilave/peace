import 'dart:convert';
import 'dart:io';

import 'package:demo/file_operation.dart';
import 'package:demo/home.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const UserHealth());
}

class UserHealth extends StatelessWidget {
  const UserHealth({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HealthConditionInput(),
      debugShowCheckedModeBanner: false,
      routes: {'/home': (context) => Home()},
    );
  }
}

class HealthConditionInput extends StatefulWidget {
  const HealthConditionInput({super.key});

  @override
  _HealthConditionInputState createState() => _HealthConditionInputState();
}

class _HealthConditionInputState extends State<HealthConditionInput> {
  final TextEditingController healthConditionController =
      TextEditingController();
  final List<dynamic> healthConditions = [];

  String fileName = 'UserCondition.json';
  List<String> list = [];
  void initState() {
    super.initState();
    checkFileExists().then((exists) async {
      if (exists) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        String contents = await file.readAsString();
        List<dynamic> jsonData = jsonDecode(contents);
        print(jsonData);
        //print(jsonData);
        setState(() {
          for (int i = 0; i < jsonData.length; i++) {
            healthConditions.add(jsonData[i]);
          }
        });
      } else {
        print("file does not exist");
      }
    });
  }

  Future<bool> checkFileExists() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');

    return await file.exists();
  }

  Future<void> saveListToJson(List<dynamic> data) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      final jsonString = jsonEncode(data); // Convert the list to a JSON string
      file.writeAsStringSync(jsonString); // Write the JSON string to a file
      print('Data saved to $fileName');
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Health Conditions"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: TextField(
                controller: healthConditionController,
                decoration:
                    const InputDecoration(labelText: "Enter Health Condition"),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  final condition = healthConditionController.text.trim();
                  if (condition.isNotEmpty) {
                    setState(() {
                      healthConditions.add(condition);
                      healthConditionController.clear();
                    });
                  }
                },
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: healthConditions.asMap().entries.map((entry) {
                final index = entry.key;
                final condition = entry.value;
                return ListTile(
                  title: Text(condition),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        healthConditions.removeAt(index);
                        saveListToJson(healthConditions);
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () {
                saveListToJson(healthConditions);
                Navigator.pushNamed(context, '/home');
              },
              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}
