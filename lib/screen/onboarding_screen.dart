import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streaks/purchases_bloc/purchases_bloc.dart';
import 'package:streaks/purchases_bloc/purchases_event.dart';
import 'package:streaks/res/assets.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/screen/purchases_screen.dart';
import 'package:streaks/screen/streak_details/widgets/custom_button.dart';
import 'package:streaks/screen/streak_screen.dart';
import 'package:streaks/services/share_prefs_services.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  void initState() {
    context.read<PurchasesBloc>().add(InitPurchases());
    super.initState();
  }

  final PageController _pageController = PageController();
  final List<String> onboardingImages = [
    AppAssets.onboarding1,
    AppAssets.onboarding2,
    AppAssets.onboarding3,
    AppAssets.onboarding4,
    AppAssets.onboarding5,
  ];
  int currentIndex = 0;
  final List<String> titles = [
    "Track Habits\nOne Day at a Time",
    "Visualize Your\nWinning Streaks",
    "Stay Consistent\nWith Daily Dots",
    "Mark Progress\nRight on the Calendar",
    "Create Your Habit\nWith Style & Purpose",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Gap(40.0),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            width: double.infinity,
            child: PageView.builder(
              onPageChanged: (value) {
                setState(() {
                  currentIndex = value;
                });
              },
              controller: _pageController,
              itemCount: onboardingImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.asset(
                      onboardingImages[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),
          Gap(30.0),
          Text(
            titles[currentIndex],
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 28.0,
              color: AppColors.whiteColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          Gap(30.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: CustomButton(
              label: "Continue",
              width: double.infinity,
              onTap: () {
                if (currentIndex < onboardingImages.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  SharePrefsService.setFirstTime();
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StreakScreen()),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PurchasesScreen()),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
