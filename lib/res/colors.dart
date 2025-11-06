import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary color (same for both themes)
  static const Color primaryColor = Color(0xFFb8ea6c);

  // Dark theme colors
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSecondaryColor = Color(0xFF313747);
  static const Color darkTextColor = Color(0xFFF2F9FF);
  static const Color darkCardColor = Color(0xFF21242b);
  static const Color darkGreyColor = Color(0xFFBFCFE7);

  // Light theme colors
  static const Color lightBackgroundColor = Color(0xFFF5F5F5);
  static const Color lightSecondaryColor = Color(0xFFE0E0E0);
  static const Color lightTextColor = Color(0xFF121212);
  static const Color lightCardColor = Color(0xFFFFFFFF);
  static const Color lightGreyColor = Color(0xFF757575);

  // Legacy support (defaults to dark theme for backward compatibility)
  static Color get blackColor => darkBackgroundColor;
  static Color get whiteColor => darkTextColor;
  static Color get secondaryColor => darkSecondaryColor;
  static Color get cardColor => darkCardColor;
  static Color get greyColor => darkGreyColor;

  // Theme-aware color getters
  static Color backgroundColor(bool isDark) {
    return isDark ? darkBackgroundColor : lightBackgroundColor;
  }

  static Color textColor(bool isDark) {
    return isDark ? darkTextColor : lightTextColor;
  }

  static Color cardColorTheme(bool isDark) {
    return isDark ? darkCardColor : lightCardColor;
  }

  static Color secondaryColorTheme(bool isDark) {
    return isDark ? darkSecondaryColor : lightSecondaryColor;
  }

  static Color greyColorTheme(bool isDark) {
    return isDark ? darkGreyColor : lightGreyColor;
  }
}
