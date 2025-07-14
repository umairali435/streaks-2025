import 'dart:math' as math;
import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();
  static const double sidePadding = 14.0;
  static const double borderRadius = 8.0;

  static List<Color> colors = [
    Color(0xFF00E676), // Bright Mint Green
    Color(0xFF40C4FF), // Vivid Sky Blue
    Color(0xFFFF4081), // Hot Pink
    Color(0xFFFFD600), // Bright Yellow
    Color(0xFF7C4DFF), // Electric Purple
    Color(0xFF69F0AE), // Light Green
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF1DE9B6), // Aqua Mint
    Color(0xFFFFAB40), // Orange Accent
    Color(0xFFFF5252), // Bright Red
    Color(0xFF448AFF), // Bold Blue
    Color(0xFFFFC400), // Neon Amber
    Color(0xFF18FFFF), // Bright Cyan
    Color(0xFF82B1FF), // Light Indigo
    Color(0xFFFF6E40), // Neon Coral
    Color(0xFF64FFDA), // Fresh Teal
    Color(0xFF536DFE), // Indigo Accent
    Color(0xFFFF8A80), // Soft Red
    Color(0xFF00BFA5), // Emerald
    Color(0xFFFFA726), // Bright Orange
    Color(0xFF00B8D4), // Turquoise Blue
    Color(0xFFFFC107), // Amber
    Color(0xFFEA80FC), // Light Purple
    Color(0xFFB9F6CA), // Mint Pastel
  ];
  static List<Color> primaryContainerColors = [
    Color(0xFF1B1B1B), // Jet Black
    Color(0xFF263238), // Blue Gray
    Color(0xFF2E3A59), // Midnight Blue
    Color(0xFF37474F), // Charcoal Gray
    Color(0xFF1A237E), // Deep Indigo
    Color(0xFF004D40), // Dark Teal
    Color(0xFF3E2723), // Rich Brown
    Color(0xFF311B92), // Dark Purple
    Color(0xFF212121), // True Black
    Color(0xFF263238), // Repeat for balance
    Color(0xFF1C1C1C), // Near Black
    Color(0xFF374151), // Slate Gray
    Color(0xFF2C2C2C), // Muted Black
    Color(0xFF1F2937), // Tailwind's Gray-800
    Color(0xFF0F172A), // Deep Navy
    Color(0xFF111827), // Cool Gray
    Color(0xFF1A1A2E), // Ink Black
    Color(0xFF2D2D44), // Grayish Navy
    Color(0xFF242424), // Softened Black
    Color(0xFF101010), // Almost pure black
    Color(0xFF20232A), // Dark Mode Neutral
    Color(0xFF1A202C), // Steel Gray
    Color(0xFF171717), // True Dark
    Color(0xFF111111), // UI Black
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
      "🔥 You're on fire! Keep that $streakName streak alive – tap to check in now!",
      "⏰ Just a minute a day keeps the streak alive! Tap to complete your $streakName streak!",
      "🎯 Small steps, big results. Let’s crush your $streakName today!",
      "🚀 Momentum is magic – don’t lose it! Complete your $streakName now!",
      "🌟 Consistency creates success. Tap now and keep your $streakName going strong!",
      "👣 One tap closer to your goals. Don’t break the $streakName streak!",
      "🏁 You’re doing amazing – finish today’s $streakName and stay on track!",
      "💪 Show up for yourself! Hit your $streakName goal today. Let’s go!",
      "🧠 Your future self will thank you – log today’s $streakName progress!",
      "✨ Greatness is built daily – keep your $streakName alive with just one tap!"
    ];

    final math.Random random = math.Random();
    int index = random.nextInt(motivationalMessages.length);
    return motivationalMessages[index];
  }
}
