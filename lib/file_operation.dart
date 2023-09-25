import 'dart:convert';
import 'dart:io';
import 'package:demo/Process/processTime.dart';
import 'package:path_provider/path_provider.dart';

List<Map<String, String>> wellnessTasks = [];
List<Map<String, String>> workTasks = [];
Map<String, String> time = {};

String getCurrentDate() {
  DateTime now = DateTime.now();
  int year = now.year;
  int month = now.month;
  int day = now.day;
  String currentDate = "$day.$month.$year";
  return currentDate;
}

Future<void> writeJsonToFile(String fileName, String jsonString) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');
  try {
    await file.writeAsString(jsonString);
    print('JSON data written to $fileName');
  } catch (e) {
    print('Error writing JSON data: $e');
  }
}

Future<void> updateListToJson(
    String fileName, List<Map<String, dynamic>> dataList) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');

  final jsonData = jsonEncode(dataList);

  if (await file.exists()) {
    // If the file exists, append data to it
    final existingData = await file.readAsString();
    final updatedData = jsonEncode([...jsonDecode(existingData), ...dataList]);
    file.writeAsStringSync(updatedData);
    print("File wrote successfully $updatedData");
  } else {
    // If the file does not exist, create a new one
    file.writeAsStringSync(jsonData);
  }
}

Future<void> readJsonFromFile(String fileName) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    String contents = await file.readAsString();
    Map<String, dynamic> jsonData = jsonDecode(contents);
    print(jsonData);
  } catch (e) {
    print('Error reading JSON data: $e');
  }
}

Future<void> writetofile(String fileName, int numberToSave) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');
  file.writeAsStringSync(numberToSave.toString());
  print('Number $numberToSave saved to $fileName');
}

Future<void> writeListToJson(
    String fileName, List<Map<String, dynamic>> dataList) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    // Encode the list as JSON
    final jsonData = jsonEncode(dataList);

    // Write the JSON data to the file
    file.writeAsStringSync(jsonData);
    print('JSON data updated and written to $fileName');
  } catch (e) {
    print('Error updating JSON data: $e');
  }
}

Future<void> updateJsonToFile(
    String fileName, Map<String, dynamic> updatedData) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');

    // Check if the file exists, if not, create it with the initial data
    if (!(await file.exists())) {
      await file.create(recursive: true);
      await file.writeAsString('{}'); // Initialize with an empty JSON object
    }

    // Read existing JSON data from the file
    String contents = await file.readAsString();
    Map<String, dynamic> jsonData = jsonDecode(contents);

    // Update the existing data with the new data
    jsonData.addAll(updatedData);

    // Convert the updated data back to JSON string
    String updatedJsonString = jsonEncode(jsonData);

    // Write the updated JSON data back to the file
    await file.writeAsString(updatedJsonString);

    print('JSON data updated and written to $fileName');
  } catch (e) {
    print('Error updating JSON data: $e');
  }
}

Future<void> deleteFile(String fileName) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');

    if (await file.exists()) {
      await file.delete();
      print('File deleted successfully.');
    } else {
      print('File not found, cannot delete.');
    }
  } catch (e) {
    print('Error deleting file: $e');
  }
}
