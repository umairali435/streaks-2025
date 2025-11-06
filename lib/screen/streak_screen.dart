import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:streaks/bloc/streaks_bloc.dart';
import 'package:streaks/components/streak_container.dart';
import 'package:streaks/database/streaks_database.dart';
import 'package:streaks/purchases_bloc/purchases_bloc.dart';
import 'package:streaks/purchases_bloc/purchases_state.dart';
import 'package:streaks/res/assets.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/bloc/theme_bloc.dart';
import 'package:streaks/screen/add_screen.dart';
import 'package:streaks/screen/premium_user.dart';
import 'package:streaks/screen/purchases_screen.dart';
import 'package:streaks/screen/streak_details/streak_detail_screen.dart';
import 'package:streaks/screen/updates_screen.dart';
import 'package:streaks/screen/settings_screen.dart';
import 'package:streaks/services/share_prefs_services.dart';

class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  @override
  void initState() {
    _checkAndShowWhatsNew();
    super.initState();
  }

  Future<void> _checkAndShowWhatsNew() async {
    await Future.delayed(const Duration(milliseconds: 500));

    bool shouldShow = await SharePrefsService.shouldShowWhatsNew();

    if (shouldShow && mounted) {
      _navigateToWhatsNew();
    }
  }

  void _navigateToWhatsNew() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const WhatsNewScreen(
          showMarkAsSeenButton: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState is ThemeLoaded ? themeState.isDark : true;
        return Scaffold(
          backgroundColor: AppColors.backgroundColor(isDark),
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            title: Text(
              "Streaks 2025",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w900,
                fontSize: 18.0,
                color: AppColors.darkBackgroundColor,
              ),
            ),
            leading: IconButton(
              icon: Icon(
                LucideIcons.settings,
                color: AppColors.darkBackgroundColor,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
              },
            ),
            actions: [
              BlocBuilder<PurchasesBloc, PurchasesState>(
                builder: (context, state) {
                  return IconButton(
                    onPressed: () {
                      if (state.isSubscriptionActive) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AlreadyPremiumPage(),
                          ),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PurchasesScreen(),
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      LucideIcons.crown,
                      color: AppColors.darkBackgroundColor,
                    ),
                  );
                },
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) => const AddStrekScreen(),
                    ),
                  )
                      .then((_) {
                    context.read<StreaksBloc>().add(LoadStreaks());
                  });
                },
                icon: Icon(
                  LucideIcons.plusSquare,
                  color: AppColors.darkBackgroundColor,
                ),
              ),
            ],
          ),
          body: SafeArea(
            bottom: false,
            child: BlocBuilder<StreaksBloc, StreaksState>(
              builder: (context, state) {
                if (state is StreaksLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                } else if (state is StreaksError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is StreaksUpdated) {
                  if (state.streaks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            AppAssets.noHabits,
                            height: 300.0,
                          ),
                          Text(
                            'No streaks found',
                            style: GoogleFonts.poppins(
                              color: AppColors.textColor(isDark),
                              fontWeight: FontWeight.bold,
                              fontSize: 32.0,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 20.0),
                      controller:
                          PageController(viewportFraction: 0.8, keepPage: true),
                      itemCount: state.streaks.length,
                      itemBuilder: (context, index) {
                        Streak streak = state.streaks[index];
                        return InkWell(
                          child: StreakContainer(
                            streak: streak,
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        StreakDetailScreen(streak: streak),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                transitionDuration:
                                    const Duration(milliseconds: 200),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                } else {
                  return const Center(child: Text('Unknown state'));
                }
              },
            ),
          ),
        );
      },
    );
  }
}
