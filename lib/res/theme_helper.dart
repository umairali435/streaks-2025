import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streaks/bloc/theme_bloc.dart';
import 'package:streaks/res/colors.dart';

/// Extension to easily access theme state from BuildContext
extension ThemeExtension on BuildContext {
  /// Get whether the current theme is dark
  bool get isDarkTheme {
    final themeState = read<ThemeBloc>().state;
    return themeState is ThemeLoaded ? themeState.isDark : true;
  }

  /// Get theme-aware background color
  Color get backgroundColor => AppColors.backgroundColor(isDarkTheme);

  /// Get theme-aware text color
  Color get textColor => AppColors.textColor(isDarkTheme);

  /// Get theme-aware card color
  Color get cardColor => AppColors.cardColorTheme(isDarkTheme);

  /// Get theme-aware secondary color
  Color get secondaryColor => AppColors.secondaryColorTheme(isDarkTheme);

  /// Get theme-aware grey color
  Color get greyColor => AppColors.greyColorTheme(isDarkTheme);
}

