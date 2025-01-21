class AppText {
  AppText._();
  static const String privacyPolicy = "https://streaks2025.blogspot.com/2025/01/privacy-policy.html";
  static const String support = "https://streaks2025.blogspot.com/2025/01/streak-support.html";
  static const List<String> weekDays = [
    "S",
    "M",
    "T",
    "W",
    "T",
    "F",
    "S",
  ];

  static String getDayOfWeek(int day) {
    switch (day) {
      case 0:
        return "Sunday";
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      default:
        return "";
    }
  }

  static List<String> generateDaysList(int count) {
    List<String> daysList = [];
    for (int i = 0; i < count; i++) {
      daysList.add(weekDays[i % 7]);
    }
    return daysList;
  }
}
