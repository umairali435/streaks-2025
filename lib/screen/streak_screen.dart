import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:streaks/bloc/streaks_bloc.dart';
import 'package:streaks/components/streak_container.dart';
import 'package:streaks/database/streaks_database.dart';
import 'package:streaks/purchases_bloc/purchases_bloc.dart';
import 'package:streaks/purchases_bloc/purchases_state.dart';
import 'package:streaks/res/assets.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/res/strings.dart';
import 'package:streaks/screen/add_screen.dart';
import 'package:streaks/screen/premium_user.dart';
import 'package:streaks/screen/purchases_screen.dart';
import 'package:streaks/screen/streak_details/streak_detail_screen.dart';
import 'package:streaks/screen/support_screen.dart';
import 'package:streaks/screen/updates_screen.dart';
import 'package:streaks/services/share_prefs_services.dart';
import 'package:streaks/services/url_launcher_service.dart';

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
      _showWhatsNewDialog();
    }
  }

  void _showWhatsNewDialog() async {
    final packageInfo = await PackageInfo.fromPlatform();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WhatsNewDialog(
          version: packageInfo.version,
          updates: const [
            UpdateItem(
              title: 'Rate App',
              description:
                  'Added a new feature to rate the app when you complete one streak',
              type: UpdateType.feature,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Streaks 2025",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w900,
            fontSize: 18.0,
          ),
        ),
        leading: PopupMenuButton<String>(
          icon: const Icon(
            LucideIcons.settings,
          ),
          onSelected: (value) async {
            if (value == 'privacy_policy') {
              await UrlLauncherService.launchURL(AppText.privacyPolicy);
            } else if (value == 'support') {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => SupportPage()));
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem(
                value: 'privacy_policy',
                child: Text('Privacy Policy'),
              ),
              const PopupMenuItem(
                value: 'support',
                child: Text('Support'),
              ),
            ];
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
                icon: const Icon(
                  LucideIcons.crown,
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
            icon: const Icon(
              LucideIcons.plusSquare,
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<StreaksBloc, StreaksState>(
          builder: (context, state) {
            if (state is StreaksLoading) {
              return const Center(child: CircularProgressIndicator());
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
                          color: AppColors.whiteColor,
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
                          MaterialPageRoute(
                            builder: (context) =>
                                StreakDetailScreen(streak: streak),
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
  }
}
