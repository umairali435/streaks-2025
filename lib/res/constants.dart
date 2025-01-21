import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();
  static const double sidePadding = 14.0;
  static const double borderRadius = 8.0;

  static List<Color> colors = [
    const Color(0xFF1E3A8A),
    const Color(0xFF3B82F6),
    const Color(0xFF6B21A8),
    const Color(0xFF064E3B),
    const Color(0xFF10B981),
    const Color(0xFF0EA5E9),
    const Color(0xFFB91C1C),
    const Color(0xFF9C4C03),
    const Color(0xFFF59E0B),
    const Color(0xFF3B3F2B),
    const Color(0xFF7E3B26),
    const Color(0xFF333333),
    const Color(0xFF134E4A),
    const Color(0xFF4B5563),
    const Color(0xFFEC4899),
    const Color(0xFFF97316),
    const Color(0xFF6B21A8),
    const Color(0xFF4C1D95),
    const Color(0xFF9B2C2C),
    const Color(0xFFD1D5DB),
    const Color(0xFF1D4ED8),
    const Color(0xFF2F3A46),
    const Color(0xFF9C4F22),
    const Color(0xFF6EE7B7),
    const Color(0xFFFCA5A5),
    const Color(0xFF10B981),
    const Color(0xFF8B5CF6),
    const Color(0xFF0F766E),
  ];

  static List<Color> primaryContainerColors = [
    const Color(0xFF93C5FD),
    const Color(0xFF60A5FA),
    const Color(0xFFD8B4FE),
    const Color(0xFF6EE7B7),
    const Color(0xFF6EE7A9),
    const Color(0xFF38BDF8),
    const Color(0xFFFCA5A5),
    const Color(0xFFFBBF24),
    const Color(0xFFFDE68A),
    const Color(0xFFA3B18C),
    const Color(0xFFE2D6C8),
    const Color(0xFFA0A0A0),
    const Color(0xFF64D5D2),
    const Color(0xFF6B7280),
    const Color(0xFFFBCFE8),
    const Color(0xFFFDBA74),
    const Color(0xFFD8B5FE),
    const Color(0xFFA5B4FC),
    const Color(0xFFF4A6A1),
    const Color(0xFFF1F5F9),
    const Color(0xFF93C5FD),
    const Color(0xFF6B7280),
    const Color(0xFFF4C7A4),
    const Color(0xFFA7F3D0),
    const Color(0xFFFFBB98),
    const Color(0xFFA7F3D0),
    const Color(0xFFA5B4FC),
    const Color(0xFF5F9A97),
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

  static List<String> activeDaysSelection = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

  static List<String> reorderDaysByIndex(int selectedIndex) {
    if (selectedIndex < 0 || selectedIndex >= activeDaysSelection.length) {
      return activeDaysSelection;
    }
    return activeDaysSelection.sublist(selectedIndex) + activeDaysSelection.sublist(0, selectedIndex);
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
}
