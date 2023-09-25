import 'package:demo/file_operation.dart';

class TimeRange {
  final DateTime startTime;
  final DateTime endTime;

  TimeRange(this.startTime, this.endTime);

  Duration calculateFreeTime(TimeRange other) {
    // Calculate the overlap between two time ranges
    DateTime overlapStart =
        startTime.isBefore(other.startTime) ? other.startTime : startTime;
    DateTime overlapEnd =
        endTime.isBefore(other.endTime) ? endTime : other.endTime;

    // Calculate the duration of overlap (free time)
    Duration overlapDuration = overlapEnd.isAfter(overlapStart)
        ? overlapEnd.difference(overlapStart)
        : Duration();

    return overlapDuration;
  }
}

Map<String, String> processHours(String workingHoursString) {
  //I have added this because there was some space at the last of the string so not properly generating a list.
  //As the input is given directly from a file.
  workingHoursString =
      workingHoursString.substring(0, workingHoursString.length - 1);
  print(workingHoursString);
  // Split the input string into individual time range strings
  List<String> timeRanges = workingHoursString.split(", ");
  print(timeRanges);
  // Initialize variables to store free time in different slots
  Duration morningFreeTime = Duration();
  Duration afternoonFreeTime = Duration();
  Duration eveningFreeTime = Duration();
  Duration nightFreeTime = Duration();

  // Loop through the time range strings
  for (int i = 0; i < timeRanges.length; i += 2) {
    TimeRange workingHours1 = TimeRange(parseTime(timeRanges[i].split(": ")[1]),
        parseTime(timeRanges[i + 1].split(": ")[1]));

    // Define time slots
    TimeRange morningSlot =
        TimeRange(parseTime("06:00 AM"), parseTime("11:59 AM"));
    TimeRange afternoonSlot =
        TimeRange(parseTime("12:00 PM"), parseTime("4:59 PM"));
    TimeRange eveningSlot =
        TimeRange(parseTime("5:00 PM"), parseTime("7:59 PM"));
    TimeRange nightSlot =
        TimeRange(parseTime("8:00 PM"), parseTime("05:59 AM"));

    // Calculate free time for each slot
    morningFreeTime += morningSlot.calculateFreeTime(workingHours1);
    afternoonFreeTime += afternoonSlot.calculateFreeTime(workingHours1);
    eveningFreeTime += eveningSlot.calculateFreeTime(workingHours1);
    nightFreeTime += nightSlot.calculateFreeTime(workingHours1);
  }

  // Output the results
  String output = """
  Morning : ${morningFreeTime.inHours}
  Afternoon : ${afternoonFreeTime.inHours}
  Evening : ${eveningFreeTime.inHours}
  Night : ${nightFreeTime.inHours}
""";

  Map<String, String> timeOutput = {
    'Morning': '${morningFreeTime.inHours}',
    'Afternoon': '${afternoonFreeTime.inHours}',
    'Evening': '${eveningFreeTime.inHours}',
    'Night': '${nightFreeTime.inHours}',
  };

  print("Test $output");
  //writeFile('/timeranges.txt', output);

  return timeOutput;
}

DateTime parseTime(String timeString) {
  final components = timeString.split(' ');
  final time = components[0];
  final ampm = components[1];
  final hoursMinutes = time.split(':');
  int hours = int.parse(hoursMinutes[0]);
  int minutes = int.parse(hoursMinutes[1]);
  if (ampm == 'PM' && hours != 12) {
    hours += 12;
  }
  return DateTime(1970, 1, 1, hours, minutes);
}
