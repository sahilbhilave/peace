import 'dart:io';
import 'package:demo/file_operation.dart';
import 'package:demo/home.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const UserHours());

class UserHours extends StatelessWidget {
  const UserHours({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Input Work Hours',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FreeTimeCalculator(),
      routes: {
        '/home': (context) => Home(),
      },
    );
  }
}

class FreeTimeCalculator extends StatefulWidget {
  @override
  _FreeTimeCalculatorState createState() => _FreeTimeCalculatorState();
}

class _FreeTimeCalculatorState extends State<FreeTimeCalculator> {
  List<TimeRange> timeRanges = [];
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  void addTimeRange(TimeOfDay? startTime, TimeOfDay? endTime) {
    if (startTime != null && endTime != null) {
      setState(() {
        TimeRange newTimeRange =
            TimeRange(startTime: startTime, endTime: endTime);
        timeRanges.add(newTimeRange);
      });
    }
  }

  void calculateFreeTime() async {
    // Prepare the data to be saved
    String data = '';
    for (TimeRange timeRange in timeRanges) {
      data +=
          'Start Time: ${timeRange.startTime!.format(context)}, End Time: ${timeRange.endTime!.format(context)}\n';
    }

    // Get the documents directory
    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = directory.path + '/timeranges.txt';

    // Write the data to the file
    File file = File(filePath);
    await file.writeAsString(data);

    Navigator.pushNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Work Hours'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: timeRanges.length,
                itemBuilder: (context, index) {
                  return TimeRangeWidget(
                    timeRange: timeRanges[index],
                    onDelete: () {
                      setState(() {
                        timeRanges.removeAt(index);
                      });
                    },
                  );
                },
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (selectedTime != null) {
                        setState(() {
                          startTime = selectedTime;
                        });
                      }
                    },
                    child: Text(startTime != null
                        ? 'Start Time: ${startTime!.format(context)}'
                        : 'Select Start Time'),
                  ),
                ),
                const SizedBox(width: 16.0), // Add spacing between buttons
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (selectedTime != null) {
                        setState(() {
                          endTime = selectedTime;
                        });
                      }
                    },
                    child: Text(endTime != null
                        ? 'End Time: ${endTime!.format(context)}'
                        : 'Select End Time'),
                  ),
                ),
              ],
            ),
            const SizedBox(
                height: 16.0), // Add spacing between input and buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    addTimeRange(startTime, endTime);
                    setState(() {
                      startTime = null;
                      endTime = null;
                    });
                  },
                  child: Text('Add Time Range'),
                ),
                const SizedBox(width: 16.0), // Add spacing between buttons
                ElevatedButton(
                  onPressed: calculateFreeTime,
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TimeRange {
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  TimeRange({required this.startTime, required this.endTime});

  int get durationInMinutes {
    final startMinutes = startTime!.hour * 60 + startTime!.minute;
    final endMinutes = endTime!.hour * 60 + endTime!.minute;
    return endMinutes - startMinutes;
  }
}

class TimeRangeWidget extends StatelessWidget {
  final TimeRange timeRange;
  final VoidCallback onDelete;

  TimeRangeWidget({
    required this.timeRange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3, // Add a slight shadow to the card
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          'Time Range: ${timeRange.startTime!.format(context)} - ${timeRange.endTime!.format(context)}',
          style: TextStyle(fontSize: 16.0),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
