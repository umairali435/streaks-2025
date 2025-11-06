import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streaks/bloc/streaks_bloc.dart';
import 'package:streaks/bloc/theme_bloc.dart';
import 'package:streaks/bloc/leaderboard_bloc.dart';
import 'package:streaks/purchases_bloc/purchases_bloc.dart';
import 'package:streaks/purchases_bloc/purchases_event.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/screen/onboarding_screen.dart';
import 'package:streaks/screen/main_navigation_screen.dart';
import 'package:streaks/database/streaks_database.dart';
import 'package:streaks/screen/add_screen.dart';
import 'package:streaks/services/notification_service.dart';
import 'package:streaks/services/share_prefs_services.dart';
import 'package:streaks/services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:streaks/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AuthService.initialize(); // Initialize Google Sign In
  await NotificationService.initilizeTime();
  await SharePrefsService.init();
  await StreaksDatabase.init();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _buildThemeData(bool isDark) {
    return ThemeData(
      useMaterial3: false,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundColor(isDark),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.darkBackgroundColor, // Always black
        elevation: 0,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
      datePickerTheme: DatePickerThemeData(
        headerBackgroundColor: AppColors.primaryColor,
        dayOverlayColor: WidgetStatePropertyAll(AppColors.primaryColor),
        todayBorder: BorderSide(
          color: AppColors.primaryColor,
        ),
        todayForegroundColor: WidgetStatePropertyAll(AppColors.primaryColor),
        todayBackgroundColor: WidgetStatePropertyAll(
          isDark ? AppColors.darkTextColor : AppColors.darkBackgroundColor,
        ),
        backgroundColor: AppColors.cardColorTheme(isDark),
      ),
      timePickerTheme: TimePickerThemeData(
        helpTextStyle: TextStyle(
          color: AppColors.textColor(isDark),
        ),
        backgroundColor: AppColors.cardColorTheme(isDark),
        dialBackgroundColor: AppColors.cardColorTheme(isDark),
        hourMinuteTextColor: AppColors.textColor(isDark),
        dayPeriodTextColor: AppColors.textColor(isDark),
        hourMinuteColor: AppColors.primaryColor,
        dialHandColor: AppColors.primaryColor,
        dialTextColor: AppColors.textColor(isDark),
        dayPeriodColor: AppColors.primaryColor,
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: AppColors.textColor(isDark),
        ),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: AppColors.textColor(isDark),
        ),
        entryModeIconColor: AppColors.textColor(isDark),
        inputDecorationTheme: InputDecorationTheme(
          floatingLabelStyle: TextStyle(
            color: AppColors.textColor(isDark),
          ),
          helperStyle: TextStyle(
            color: AppColors.textColor(isDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.primaryColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.primaryColor,
            ),
          ),
          labelStyle: TextStyle(
            color: AppColors.textColor(isDark),
          ),
          hintStyle: TextStyle(
            color: AppColors.greyColorTheme(isDark),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => StreaksBloc()..add(LoadStreaks()),
        ),
        BlocProvider(
          create: (context) => PurchasesBloc()..add(InitPurchases()),
        ),
        BlocProvider(
          create: (context) => IconBloc(),
        ),
        BlocProvider(
          create: (context) => ThemeBloc(),
        ),
        BlocProvider(
          create: (context) => LeaderboardBloc(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState is ThemeLoaded ? themeState.isDark : true;

          // Update system UI overlay style based on theme
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: AppColors.primaryColor,
              statusBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarColor: AppColors.backgroundColor(isDark),
              systemNavigationBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
            ),
          );

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: _buildThemeData(false), // Light theme
            darkTheme: _buildThemeData(true), // Dark theme
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            home: SharePrefsService.isFirstTime()
                ? OnBoardingScreen()
                : const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}
