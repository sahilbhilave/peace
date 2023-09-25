List<String> makeListTasks(String responseBody) {
  String da = responseBody.toString();
  String input = da;
  //String input = responseBody;
  input = input.replaceAll("3.5", "");
  RegExp regex = RegExp(r'\d+\..*?\.');
  // Find all matches in the input string.
  Iterable<Match> matches = regex.allMatches(input);

  // Extract and store the matched strings in a list.
  List<String> resultList = [];
  for (Match match in matches) {
    String matchedString =
        match.group(0)!; // group(0) contains the entire matched string
    resultList.add(matchedString);
  }

  print(responseBody.length);

  // Print the extracted strings.
  for (String result in resultList) {
    print(result);
  }
  print(resultList.length);
  return resultList;
}
