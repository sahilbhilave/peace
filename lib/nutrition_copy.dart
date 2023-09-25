import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(NutritionReportApp());

class NutritionReportApp extends StatefulWidget {
  @override
  _NutritionReportAppState createState() => _NutritionReportAppState();
}

class _NutritionReportAppState extends State<NutritionReportApp> {
  final apiKey =
      "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"; // Replace with your OpenAI API key
  final apiUrl = "https://api.openai.com/v1/completions";
  List<Map<String, dynamic>> nutritionReports = [];
  Map<String, dynamic> dataa = {};
  String converttoString = "";
  List<Map<String, dynamic>> datab = [];

  TextEditingController inputController = TextEditingController();
  bool isLoading = false;

  Future<void> fetchDataFromOpenAI(String inputText) async {
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $apiKey",
    };

    var data = {
      "model": "gpt-3.5-turbo-instruct",
      "prompt":
          "You are a dietitian and a computer specialist who specializes providing detail description of what they have just eaten like all the nutrition and how it will benefit them and tell them if the food they ate is unhealthy.  Now a student approaches you and says '$inputText' . Deliver your response in valid json format with the following keys: 'food' for the name of the food, 'contents' tell the Nutrition Facts, 'information' talk about the food if it is healthy or not, 'nurition points' rate their food choice on a scale of 1 to 10.",
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
      });
    } else {
      print("Error: ${response.statusCode}");
      print("Response: ${response.body}");
      isLoading = false;
    }
  }

  void deleteReport(int index) {
    setState(() {
      nutritionReports.removeAt(index);
      datab.removeAt(index); // Remove corresponding data
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                      itemCount: nutritionReports.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: EdgeInsets.all(10.0),
                          child: ListTile(
                            title: Text(
                                "Your input : ${nutritionReports[index]["input"]}"),
                            subtitle: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Food: ${datab[index]['food']}\n",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  TextSpan(
                                    text:
                                        "${datab[index]['contents']}\n\n${datab[index]['information']}\n\n",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  TextSpan(
                                    text:
                                        "Nutrition Score : ${datab[index]['nutrition points']}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                print(datab);
                                print(nutritionReports);
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
      ),
    );
  }
}
