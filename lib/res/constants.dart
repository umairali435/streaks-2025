import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();
  static const double sidePadding = 14.0;
  static const double borderRadius = 8.0;

  static List<Color> colors = [
    Color(0xFF5C7CFA),
    Color(0xFF4D96FF),
    Color(0xFF6B8CFF),
    Color(0xFF2EE6D6),
    Color(0xFF3DDC97),
    Color(0xFF4FD1C5),
    Color(0xFF9B8CFF),
    Color(0xFFA78BFA),
    Color(0xFF8B5CF6),
    Color(0xFFFF8F6B),
    Color(0xFFFF9F80),
    Color(0xFFFF7A7A),
    Color(0xFF9BE264),
    Color(0xFF7ED957),
    Color(0xFF6BCF9A),
    Color(0xFF00E676),
    Color(0xFF40C4FF),
    Color(0xFFFF4081),
    Color(0xFFFFD600),
    Color(0xFF7C4DFF),
    Color(0xFF69F0AE),
    Color(0xFFFF5722),
    Color(0xFF1DE9B6),
    Color(0xFFFFAB40),
    Color(0xFFFF5252),
    Color(0xFF448AFF),
    Color(0xFFFFC400),
    Color(0xFF18FFFF),
    Color(0xFF82B1FF),
    Color(0xFFFF6E40),
    Color(0xFF64FFDA),
    Color(0xFF536DFE),
    Color(0xFFFF8A80),
    Color(0xFF00BFA5),
    Color(0xFFFFA726),
    Color(0xFF00B8D4),
    Color(0xFFFFC107),
    Color(0xFFEA80FC),
    Color(0xFFB9F6CA),
  ];

  static int getWeekDay(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 0;
      case DateTime.tuesday:
        return 1;
      case DateTime.wednesday:
        return 2;
      case DateTime.thursday:
        return 3;
      case DateTime.friday:
        return 4;
      case DateTime.saturday:
        return 5;
      case DateTime.sunday:
        return 6;
      default:
        return -1;
    }
  }

  static List<String> activeDaysSelection = [
    "Sun",
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat"
  ];

  static List<String> reorderDaysByIndex(int selectedIndex) {
    if (selectedIndex < 0 || selectedIndex >= activeDaysSelection.length) {
      return activeDaysSelection;
    }
    return activeDaysSelection.sublist(selectedIndex) +
        activeDaysSelection.sublist(0, selectedIndex);
  }

  static int selectedDayIndex(String day) {
    switch (day) {
      case "Sun":
        return 0;
      case "Mon":
        return 1;
      case "Tue":
        return 2;
      case "Wed":
        return 3;
      case "Thu":
        return 4;
      case "Fri":
        return 5;
      case "Sat":
        return 6;
      default:
        return -1;
    }
  }

  static int selectedWeekIndex(String day) {
    switch (day) {
      case "Sunday":
        return 0;
      case "Monday":
        return 1;
      case "Tuesday":
        return 2;
      case "Wednesday":
        return 3;
      case "Thursday":
        return 4;
      case "Friday":
        return 5;
      case "Saturday":
        return 5;
      default:
        return -1;
    }
  }

  static String getWeekDayByIndex(int index) {
    switch (index) {
      case 0:
        return "M";
      case 1:
        return "T";
      case 2:
        return "W";
      case 3:
        return "T";
      case 4:
        return "F";
      case 5:
        return "S";
      case 6:
        return "S";
      default:
        return "Unknown";
    }
  }

  static String getRandomMotivationalMessage(String streakName) {
    final List<String> motivationalMessages = [
      "You’re building something powerful. Keep your $streakName going today.",
      "One small action is all it takes. Check in for your $streakName now.",
      "Consistency beats motivation. Log today’s $streakName.",
      "Don’t break the chain — your $streakName matters.",
      "Progress happens when you show up. Complete your $streakName today.",
      "Your future self is counting on this. Keep your $streakName alive.",
      "Small steps today create big wins tomorrow. Tap to finish $streakName.",
      "You’ve come this far — don’t stop now. Log your $streakName.",
      "Momentum is built daily. Protect your $streakName streak.",
      "Just one tap keeps your $streakName moving forward.",
      "Success is quiet and consistent. Check in for $streakName.",
      "Every streak starts with showing up. Finish today’s $streakName.",
      "You’re proving you can stay consistent. Log $streakName now.",
      "This is how habits stick. Complete your $streakName today.",
      "You don’t need motivation — just action. Tap to log $streakName.",
      "Even a small effort counts today. Keep your $streakName alive.",
      "You’re building discipline one day at a time. Log $streakName.",
      "Great things are built daily. Don’t skip your $streakName.",
      "One check today makes tomorrow easier. Finish $streakName.",
      "You’re closer than you think. Keep your $streakName going.",
      "Habits shape your future. Log today’s $streakName.",
      "Stay consistent. Stay proud. Complete your $streakName.",
      "Discipline creates freedom. Check in for $streakName.",
      "This is how progress is made. Finish today’s $streakName.",
      "You’re showing up — that matters. Log $streakName now.",
      "One day at a time builds real change. Keep $streakName alive.",
      "Don’t let momentum slip. Complete your $streakName today.",
      "Your effort today counts. Log your $streakName.",
      "Small wins add up. Protect your $streakName streak.",
      "You’re building a habit that builds you. Finish $streakName.",
      "This is part of your routine now. Log $streakName.",
      "Consistency is your advantage. Complete today’s $streakName.",
      "You’ve got this. One tap for $streakName.",
      "Keep showing up — it’s working. Log $streakName.",
      "Habits grow stronger with repetition. Finish $streakName today.",
      "You’re on the right track. Keep your $streakName alive.",
      "Daily actions create lasting results. Log $streakName.",
      "Stay steady. Stay consistent. Complete $streakName.",
      "Your progress deserves recognition. Check in for $streakName.",
      "One habit closer to your best self. Finish $streakName now.",
    ];

    motivationalMessages.shuffle();
    return motivationalMessages.first;
  }
}
