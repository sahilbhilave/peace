import 'dart:convert';
import 'dart:io'; // Import the 'dart:io' library for file operations
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:demo/usercondition.dart';
import 'package:demo/user_input.dart';
import 'package:demo/taskcheck.dart';
import 'package:demo/process_output.dart';
import 'package:demo/home.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/userinput': (context) => const UserInput(),
        '/usercondition': (context) => const UserHealth(),
        '/main': (context) => const MyApp(),
        '/home': (context) => Home(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController textEditingController = TextEditingController();

  String body = """1.Loading.
      2.Loadinga.
      3.Loadingb.
      4.Loadingc.
      1.Loadingd.
      2.Loadinge.
      3.Loadingf.
      4.Loadingg.
      1.Loadingh.
      2.Loadingj.
      3.Loadingk.
      4.Loadingl.""";
  // String body = "1.Loading....";
  bool onClick = false;

  Future<void> fetchDataFromOpenAI(String inputText) async {
    try {
      const apiKey =
          "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"; // Replace with your OpenAI API key
      const apiUrl = "https://api.openai.com/v1/completions";

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      };

      final data = {
        "model": "gpt-3.5-turbo-instruct",
        "prompt":
            "You are a professional psychiatrist who specializes in suggesting students various tasks based on how they are feeling. You suggest tasks such that they can improve students Mind, Social life, Fitness. Your provide 4 tasks for each category. Make sure you give each student unique tasks and not repetative.In this format Mind 1.Task1. 2.Task2. 3.Task3. 4.Task4. Now a students approaches you and says '$inputText': . Suggest him some tasks.",
        "max_tokens": 450,
        "temperature": 1,
        "top_p": 1,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body).toString();
        print("Response: $responseBody");
        setState(() {
          body = responseBody;
        });

        if (body.length > 50) {
        } else {
          _showAlertDialog(context);
        }
      } else {
        print("Error: ${response.statusCode}");
        print("Response: ${response.body}");
        _showAlertDialog(context);
      }
    } catch (e) {
      _showAlertDialog(context);
    }

    setState(() {
      onClick = true;
    });
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Return an AlertDialog widget
        return AlertDialog(
          title: const Text('Improper Input or Network Error'),
          content: const Text(
              'Please provide proper input! This input field should contain how you wish to spend your day.'),
          actions: <Widget>[
            // Define actions to be displayed in the dialog
            TextButton(
              child: Text('OK'),
              onPressed: () {
                // Close the dialog when the OK button is pressed
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> checkFileExists() async {
    String fileName = 'WellnessToday.json';
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');

    return await file.exists();
  }

  @override
  void initState() {
    super.initState();
    checkFileExists().then((exists) {
      if (exists) {
        Navigator.pushNamed(context, '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select your mind tasks"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    controller: textEditingController,
                    decoration: const InputDecoration(
                      hintText: "Enter your input text",
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      String inputText = textEditingController.text;
                      if (inputText.isNotEmpty) {
                        fetchDataFromOpenAI(inputText);
                      }
                      setState(() {
                        onClick = true;
                      });
                    },
                    child: const Text("Generate some tasks"),
                  ),
                ],
              ),
            ),
            if (onClick) CheckboxList(elements: makeListTasks(body))
          ],
        ),
      ),
    );
  }
}
