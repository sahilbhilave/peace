import 'dart:convert';
import 'dart:io';
import 'package:demo/home.dart';
import 'package:demo/nutrition.dart';
import 'package:demo/user_report.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(ChatBotApp());
}

class ChatBotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatScreen(),
      routes: {
        '/home': (context) => Home(),
        '/stats': (context) => UserReport(arr: stats),
        '/Nutrition': (context) => NutritionReportApp(),
        '/chatbot': (context) => ChatBotApp(),
      },
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  String role_content = "";
  String wellnesstoday = "";
  String worktotal = "";
  String diettoday = "";
  String completedwork = "";
  String completedwellness = "";
  String healthcondition = "None";
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health ChatBot'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              reverse: true,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            ),
          ),
          _buildComposer(),
        ],
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
              backgroundColor: Colors.black),
        ],
        currentIndex: 4,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the selected index
          });
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/stats', arguments: stats);
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
    );
  }

  Widget _buildComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey), // Add borders
        borderRadius: BorderRadius.circular(20.0), // Add rounded corners
      ),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: _controller,
              onSubmitted: _handleSubmitted,
              decoration: const InputDecoration.collapsed(
                hintText: 'Send a message',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              _handleSubmitted(_controller.text);
            },
          ),
        ],
      ),
    );
  }

  void _handleSubmitted(String text) {
    _controller.clear();
    ChatMessage userMessage = ChatMessage(
      text: text,
      isUser: true,
    );
    setState(() {
      _messages.insert(0, userMessage);
    });
    readUserFiles();

    fetchDataFromOpenAI(text);
  }

  Future<void> readUserFiles() async {
    String filename1 = "WellnessToday.json";
    String filename2 = "WorkTotal.json";
    String filename3 = "DietToday.json";
    String filename4 = "CompletedWork.json";
    String filename5 = "CompletedWellness.json";
    String filename6 = "UserCondition.json";
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename1');
      String contents = await file.readAsString();

      setState(() {
        wellnesstoday = contents.toString();
      });
      print(wellnesstoday);
    } catch (e) {
      print('Error reading JSON data: $e');
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename2');
      String contents = await file.readAsString();

      setState(() {
        worktotal = contents.toString();
      });
      print(worktotal);
    } catch (e) {
      print('Error reading JSON data: $e');
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename3');
      String contents = await file.readAsString();

      setState(() {
        diettoday = contents.toString();
      });
      print(diettoday);
    } catch (e) {
      print('Error reading JSON data: $e');
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename4');
      String contents = await file.readAsString();

      setState(() {
        completedwork = contents.toString();
      });
      print(completedwork);
    } catch (e) {
      print('Error reading JSON data: $e');
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename5');
      String contents = await file.readAsString();

      setState(() {
        completedwellness = contents.toString();
      });
      print(completedwellness);
    } catch (e) {
      print('Error reading JSON data: $e');
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename6');
    String contents = await file.readAsString();
    List<dynamic> jsonData = jsonDecode(contents);

    //print(jsonData);
    setState(() {
      //healthConditions = jsonDecode(contents).toString();
      for (int i = 0; i < jsonData.length; i++) {
        healthcondition = "$healthcondition ${jsonData[i]},";
      }
    });
  }

  Future<void> fetchDataFromOpenAI(String inputText) async {
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
          "You are a professional doctor who provided suggestions to your user about the mind,social,fitness, work tasks.All the data is in JSON format please understand. The user has health conditions : $healthcondition. You also provided them with nutrition facts based on their health conditions. Wellness tasks are  $wellnesstoday, completed wellness tasks are $completedwellness, work tasks are $worktotal, completed worktasks are $completedwork , nutrition/diet info about what the user ate today is $diettoday. If a user asks to remove something then tell them that they can do so using the app features. Now the user is asking you questions : '$inputText'",
      "max_tokens": 300,
      "temperature": 1,
      "top_p": 1,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print(jsonResponse);
      final botMessage = jsonResponse['choices'][0]['text'];
      ChatMessage message = ChatMessage(
        text: botMessage,
        isUser: false,
      );
      setState(() {
        _messages.insert(0, message);
      });
    } else {
      print('Failed to get a response from the bot.');
    }
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    String name = isUser ? "User\n" : "ChatBot";
    String messageText = text;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: Container(
              margin: EdgeInsets.all(3),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue : Colors.green,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4), // Add spacing between name and text
                  Text(
                    messageText,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
