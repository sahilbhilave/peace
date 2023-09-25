import 'dart:io';

import 'package:demo/chatbot.dart';
import 'package:demo/file_operation.dart';
import 'package:demo/home.dart';
import 'package:demo/main.dart';
import 'package:demo/user_report.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

void main() => runApp(NutritionReportApp());

class NutritionReportApp extends StatefulWidget {
  @override
  _NutritionReportAppState createState() => _NutritionReportAppState();
}

String fileName = 'DietToday.json';
String conditionFile = 'UserCondition.json';

class _NutritionReportAppState extends State<NutritionReportApp> {
  int _currentIndex = 0;
  String healthConditions = "";
  int avgNutritionPoints = 0;

  final apiKey =
      "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"; // Replace with your OpenAI API key
  final apiUrl = "https://api.openai.com/v1/completions";
  List<Map<String, dynamic>> nutritionReports = [];
  Map<String, dynamic> dataa = {};
  String converttoString = "";
  List<Map<String, dynamic>> datab = [];
  TextEditingController inputController = TextEditingController();
  bool isLoading = false;

  Future<bool> checkFileExists() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');

    return await file.exists();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    checkFileExists().then((exists) async {
      if (exists) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        String contents = await file.readAsString();
        List<dynamic> jsonData = jsonDecode(contents);
        List<dynamic> test = [];
        int i;
        //print(jsonData);
        setState(() {
          for (i = 0; i < jsonData.length; i++) {
            datab.add({
              "food": jsonData[i]['food'],
              "contents": jsonData[i]['contents'],
              "information": jsonData[i]['information'],
              "nutrition points": jsonData[i]['nutrition points']
            });
            avgNutritionPoints =
                avgNutritionPoints + (jsonData[i]['nutrition points'] as int);
          }
          avgNutritionPoints = avgNutritionPoints ~/ i;

          writetofile('NutritionPoints.json', avgNutritionPoints);
        });
      } else {
        print("file does not exist");
      }

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$conditionFile');
      String contents = await file.readAsString();
      List<dynamic> jsonData = jsonDecode(contents);

      //print(jsonData);
      setState(() {
        //healthConditions = jsonDecode(contents).toString();
        for (int i = 0; i < jsonData.length; i++) {
          healthConditions = "$healthConditions ${jsonData[i]},";
        }
      });
      print(healthConditions);
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> getAverageValue() async {
    avgNutritionPoints = 0;
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    String contents = await file.readAsString();
    List<dynamic> jsonData = jsonDecode(contents);
    int i;
    //print(jsonData);
    setState(() {
      for (i = 0; i < jsonData.length; i++) {
        avgNutritionPoints =
            avgNutritionPoints + (jsonData[i]['nutrition points'] as int);
      }
      avgNutritionPoints = avgNutritionPoints ~/ i;
      writetofile('NutritionPoints.json', avgNutritionPoints);
    });
  }

  Future<void> fetchDataFromOpenAI(String inputText) async {
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $apiKey",
    };
    String condition = "";
    if (healthConditions.length > 2) {
      condition = "The person has health conditions '$healthConditions'";
    } else {
      print("No health conditions");
    }

    var data = {
      "model": "gpt-3.5-turbo-instruct",
      "prompt":
          "You are a dietitian and a computer specialist who specializes providing detail description of what they have just eaten like all the nutrition and how it will benefit them and tell them if the food they ate is unhealthy.  Now a student approaches you and says '$inputText' . $condition Deliver your response in valid json format with the following keys: 'food' for the name of the food, 'contents' tell the Nutrition Facts, 'information' talk about the food if it is healthy or not, 'nurition points' rate their food choice on a scale of 1 to 10.",
      "max_tokens": 700,
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

      setState(() {
        nutritionReports.add({"input": inputText, "report": responseBody});
        dataa = json.decode(response.body);
        final reportData = json.decode(dataa['choices'][0]['text']);
        datab.add(reportData);
        print("datax text : $datab");
        isLoading = false;
        writeListToJson('DietToday.json', datab);
        getAverageValue();
      });
    } else {
      print("Error: ${response.statusCode}");
      print("Response: ${response.body}");
      isLoading = false;
    }
  }

  void deleteReport(int index) {
    setState(() {
      //nutritionReports.removeAt(index);
      datab.removeAt(index);
      writeListToJson('DietToday.json', datab);
      getAverageValue();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/main': (context) => const MyApp(),
        '/home': (context) => Home(),
        '/stats': (context) => UserReport(arr: stats),
        '/chatbot': (context) => ChatBotApp(),
      },
      home: Scaffold(
        appBar: AppBar(
          title: Text('Nutrition Report App'),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                controller: inputController,
                decoration: InputDecoration(
                  hintText: 'Enter what you ate...',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                      });
                      fetchDataFromOpenAI(inputController.text);
                    },
                  ),
                ),
              ),
            ),
            isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: datab.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: EdgeInsets.all(10.0),
                          child: ListTile(
                            // title: Text(
                            //     "Your input : ${nutritionReports[index]["input"]}"),
                            title: Text(
                              "${datab[index]['food']}",
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            subtitle: RichText(
                              text: TextSpan(
                                children: [
                                  // TextSpan(
                                  //   text: "Food: ${datab[index]['food']}\n",
                                  //   style: const TextStyle(
                                  //       fontWeight: FontWeight.bold,
                                  //       color: Colors.black),
                                  // ),
                                  TextSpan(
                                    text:
                                        "\n${datab[index]['contents']}\n\n${datab[index]['information']}\n\n",
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  TextSpan(
                                    text:
                                        "Nutrition Score : ${datab[index]['nutrition points']}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                deleteReport(index);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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
                label: 'Nutrients',
                backgroundColor: Colors.black),
            BottomNavigationBarItem(
                icon: Icon(Icons.music_note),
                label: 'Meditate',
                backgroundColor: Colors.black),
            BottomNavigationBarItem(
                icon: Icon(Icons.message),
                label: 'ChatBot',
                backgroundColor: Colors.black),
          ],
          currentIndex: 2,
          selectedItemColor: Colors.blue,
          onTap: (index) {
            setState(() {
              _currentIndex = index; // Update the selected index
              getAverageValue();
            });
            switch (index) {
              case 0:
                Navigator.pushNamed(context, '/home');
                break;
              case 1:
                Navigator.pushNamed(context, '/stats', arguments: stats);
                break;
              case 2:
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
