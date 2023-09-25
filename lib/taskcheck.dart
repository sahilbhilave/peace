import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:demo/file_operation.dart';

class CheckboxList extends StatefulWidget {
  final List<String> elements;

  const CheckboxList({super.key, required this.elements});

  @override
  _CheckboxListState createState() => _CheckboxListState();
}

class _CheckboxListState extends State<CheckboxList> {
  List<bool> _isCheckedList = [];
  List<String> category = ["Mind", "Social", "Fitness"];
  bool _isButtonEnabled = false; // Track button enable/disable state

  @override
  void initState() {
    super.initState();
    _isCheckedList = List.generate(widget.elements.length, (index) => false);
  }

  // Function to check if any checkbox is checked
  bool _isAnyCheckboxChecked() {
    for (int i = 0; i < _isCheckedList.length; i++) {
      if (_isCheckedList[i]) {
        return true;
      }
    }
    return false;
  }

  // Function to update the button state
  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _isAnyCheckboxChecked();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(category[0],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
        for (int i = 0; i < widget.elements.length; i++)
          Column(
            children: <Widget>[
              ListTile(
                title: Text(widget.elements[i]),
                trailing: Checkbox(
                  value: _isCheckedList[i],
                  onChanged: (value) {
                    setState(() {
                      _isCheckedList[i] = value!;
                      _updateButtonState(); // Update the button state when a checkbox changes
                    });
                  },
                ),
              ),
              if ((i + 1) % 4 == 0 && i != widget.elements.length - 1)
                Text(category[(i + 1) ~/ 4],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 25)),
              // Add a Divider after every 4 elements except the last one
            ],
          ),
        ElevatedButton(
          onPressed:
              _isButtonEnabled // Disable the button when no checkbox is checked
                  ? () async {
                      String taskType = "";
                      String taskName = "";
                      Map<String, dynamic> data = {};
                      final pattern = RegExp(r'[0-9]');
                      for (int i = 0; i < widget.elements.length; i++) {
                        if (_isCheckedList[i]) {
                          taskName = widget.elements[i].replaceAll(pattern, '');
                          taskName = taskName.replaceAll('.', '');
                          if (i >= 0 && i <= 3) {
                            taskType = "mind";
                          } else if (i >= 4 && i <= 7) {
                            taskType = "social";
                          } else {
                            taskType = "fitness";
                          }

                          data[taskName] = taskType;
                        }
                      }
                      String jsonString = jsonEncode(data);
                      await writeJsonToFile('WellnessToday.json', jsonString);

                      readJsonFromFile('WellnessToday.json');
                      Navigator.pushNamed(context, '/userinput');
                    }
                  : null, // Set onPressed to null to disable the button
          child: Text("Next"),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }
}
