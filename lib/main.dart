import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streaks/bloc/streaks_bloc.dart';
import 'package:streaks/purchases_bloc/purchases_bloc.dart';
import 'package:streaks/purchases_bloc/purchases_event.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/screen/onboarding_screen.dart';
import 'package:streaks/screen/streak_screen.dart';
import 'package:streaks/database/streaks_database.dart';
import 'package:streaks/screen/add_screen.dart';
import 'package:streaks/services/share_prefs_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharePrefsService.init();
  await StreaksDatabase.init();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: AppColors.primaryColor,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: false,
          scaffoldBackgroundColor: AppColors.blackColor,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.blackColor,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
          datePickerTheme: DatePickerThemeData(
            headerBackgroundColor: AppColors.primaryColor,
            dayOverlayColor: WidgetStatePropertyAll(AppColors.primaryColor),
            todayBorder: BorderSide(
              color: AppColors.primaryColor,
            ),
            todayForegroundColor:
                WidgetStatePropertyAll(AppColors.primaryColor),
            todayBackgroundColor:
                const WidgetStatePropertyAll(AppColors.whiteColor),
          ),
          timePickerTheme: TimePickerThemeData(
            helpTextStyle: const TextStyle(
              color: AppColors.whiteColor,
            ),
            backgroundColor: FlexColor.lightFlexInverseSurface,
            dialBackgroundColor: FlexColor.lightFlexInverseSurface,
            hourMinuteTextColor: AppColors.whiteColor,
            dayPeriodTextColor: AppColors.whiteColor,
            hourMinuteColor: AppColors.primaryColor,
            dialHandColor: AppColors.primaryColor,
            dialTextColor: AppColors.whiteColor,
            dayPeriodColor: AppColors.primaryColor,
            confirmButtonStyle: TextButton.styleFrom(
              foregroundColor: AppColors.whiteColor,
            ),
            cancelButtonStyle: TextButton.styleFrom(
              foregroundColor: AppColors.whiteColor,
            ),
            entryModeIconColor: AppColors.whiteColor,
            inputDecorationTheme: InputDecorationTheme(
              floatingLabelStyle: const TextStyle(
                color: AppColors.whiteColor,
              ),
              helperStyle: const TextStyle(
                color: AppColors.whiteColor,
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
              labelStyle: const TextStyle(
                color: AppColors.whiteColor,
              ),
              hintStyle: const TextStyle(
                color: AppColors.whiteColor,
              ),
            ),
          ),
        ),
        home: SharePrefsService.isFirstTime()
            ? OnBoardingScreen()
            : const StreakScreen(),
      ),
    );
  }
}
