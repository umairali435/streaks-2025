import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:streaks/bloc/streaks_bloc.dart';
import 'package:streaks/components/sale_offer_banner.dart';
import 'package:streaks/components/streak_container.dart';
import 'package:streaks/database/streaks_database.dart';
import 'package:streaks/purchases_bloc/purchases_bloc.dart';
import 'package:streaks/purchases_bloc/purchases_state.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/bloc/theme_bloc.dart';
import 'package:streaks/screen/add_screen.dart';
import 'package:streaks/screen/premium_user.dart';
import 'package:streaks/screen/purchases_screen.dart';
import 'package:streaks/screen/sale_offer_screen.dart';
import 'package:streaks/screen/streak_details/streak_detail_screen.dart';
import 'package:streaks/screen/settings_screen.dart';
import 'package:streaks/services/share_prefs_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _firstHabitDialogScheduled = false;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  static const Duration _saleOfferDuration = Duration(days: 4, hours: 4);
  Timer? _offerTimer;
  Duration _offerRemaining = Duration.zero;
  DateTime? _offerExpiry;
  bool _showOfferBanner = false;
  int _lastRemainingSeconds = -1;
  bool _lastOfferVisibility = false;

  @override
  void initState() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    _loadSaleOfferBanner();
    super.initState();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _offerTimer?.cancel();
    super.dispose();
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
                onPressed: _openAddHabit,
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
                Widget content;

                if (state is StreaksLoading) {
                  if (_pulseController.isAnimating) {
                    _pulseController.stop();
                    _pulseController.reset();
                  }
                  content = Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                } else if (state is StreaksError) {
                  if (_pulseController.isAnimating) {
                    _pulseController.stop();
                    _pulseController.reset();
                  }
                  content = Center(child: Text('Error: ${state.message}'));
                } else if (state is StreaksUpdated) {
                  if (state.streaks.isEmpty) {
                    if (!_pulseController.isAnimating) {
                      _pulseController.repeat(reverse: true);
                    }
                    _scheduleFirstHabitDialogIfNeeded(isDark);
                    content = Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: ListView(
                          padding: EdgeInsets.symmetric(horizontal: 22.0),
                          children: [
                            _buildEmptyStateCard(isDark),
                            const SizedBox(height: 28),
                            _buildAnimatedAddHabitButton(isDark),
                          ],
                        ),
                      ),
                    );
                  } else {
                    if (_pulseController.isAnimating) {
                      _pulseController.stop();
                      _pulseController.reset();
                    }
                    if (SharePrefsService.shouldShowFirstHabitDialog()) {
                      SharePrefsService.markFirstHabitDialogShown();
                    }
                    content = ListView.builder(
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
                  content = const Center(child: Text('Unknown state'));
                }

                return Column(
                  children: [
                    BlocBuilder<PurchasesBloc, PurchasesState>(
                      builder: (context, purchaseState) {
                        final showBanner =
                            !purchaseState.isSubscriptionActive &&
                                _showOfferBanner &&
                                _offerRemaining > Duration.zero;
                        if (!showBanner) {
                          return const SizedBox.shrink();
                        }
                        return SaleOfferBanner(
                          remaining: _offerRemaining,
                          onDismiss: _handleOfferDismissed,
                          onTap: _handleOfferBannerTapped,
                        );
                      },
                    ),
                    Expanded(child: content),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadSaleOfferBanner() async {
    final isPremium = context.read<PurchasesBloc>().state.isSubscriptionActive;
    if (isPremium) {
      await SharePrefsService.setSaleOfferBannerDismissed(true);
      _offerTimer?.cancel();
      _offerTimer = null;
      _offerExpiry = null;
      _lastRemainingSeconds = -1;
      _lastOfferVisibility = false;
      setState(() {
        _offerRemaining = Duration.zero;
        _showOfferBanner = false;
      });
      return;
    }

    final expiry =
        await SharePrefsService.ensureSaleOfferExpiry(_saleOfferDuration);

    if (!mounted) return;

    final remaining = expiry.difference(DateTime.now());

    if (remaining <= Duration.zero) {
      _offerTimer?.cancel();
      _offerTimer = null;
      _offerExpiry = null;
      _lastRemainingSeconds = -1;
      _lastOfferVisibility = false;
      setState(() {
        _offerRemaining = Duration.zero;
        _showOfferBanner = false;
      });
      return;
    }

    _offerExpiry = expiry;
    _offerRemaining = remaining;
    _showOfferBanner = !SharePrefsService.isSaleOfferBannerDismissed();
    _lastRemainingSeconds = remaining.inSeconds;
    _lastOfferVisibility = _showOfferBanner;
    setState(() {});
    _startOfferTimer();
  }

  void _startOfferTimer() {
    _offerTimer?.cancel();

    if (_offerExpiry == null) {
      return;
    }

    _offerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _offerExpiry == null) {
        timer.cancel();
        return;
      }

      if (context.read<PurchasesBloc>().state.isSubscriptionActive) {
        unawaited(SharePrefsService.setSaleOfferBannerDismissed(true));
        timer.cancel();
        _offerExpiry = null;
        _lastRemainingSeconds = -1;
        _lastOfferVisibility = false;
        if (!mounted) return;
        setState(() {
          _offerRemaining = Duration.zero;
          _showOfferBanner = false;
        });
        return;
      }

      final remaining = _offerExpiry!.difference(DateTime.now());
      final remainingSeconds = remaining.inSeconds;

      if (remaining <= Duration.zero) {
        timer.cancel();
        _offerExpiry = null;
        unawaited(SharePrefsService.setSaleOfferBannerDismissed(true));
        unawaited(SharePrefsService.clearSaleOfferExpiry());
        if (!mounted) {
          return;
        }
        setState(() {
          _offerRemaining = Duration.zero;
          _showOfferBanner = false;
        });
        _lastRemainingSeconds = -1;
        _lastOfferVisibility = false;
      } else {
        final isDismissed = SharePrefsService.isSaleOfferBannerDismissed();
        final shouldShow = !isDismissed;
        if (!mounted) {
          return;
        }
        if (remainingSeconds != _lastRemainingSeconds ||
            shouldShow != _lastOfferVisibility) {
          setState(() {
            _offerRemaining = remaining;
            _showOfferBanner = shouldShow;
          });
          _lastRemainingSeconds = remainingSeconds;
          _lastOfferVisibility = shouldShow;
        }
      }
    });
  }

  void _handleOfferDismissed() {
    unawaited(SharePrefsService.setSaleOfferBannerDismissed(true));
    setState(() {
      _showOfferBanner = false;
    });
    _lastOfferVisibility = false;
  }

  Future<void> _handleOfferBannerTapped() async {
    final shouldOpenCheckout = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const SaleOfferScreen(),
      ),
    );

    if (!mounted) return;

    await _loadSaleOfferBanner();

    if (shouldOpenCheckout == true && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const PurchasesScreen(),
        ),
      );
    }
  }

  void _scheduleFirstHabitDialogIfNeeded(bool isDark) {
    if (!_firstHabitDialogScheduled &&
        SharePrefsService.shouldShowFirstHabitDialog()) {
      _firstHabitDialogScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (ModalRoute.of(context)?.isCurrent != true) {
          _firstHabitDialogScheduled = false;
          return;
        }
        _showFirstHabitDialog(isDark);
      });
    }
  }

  Future<void> _showFirstHabitDialog(bool isDark) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20.0),
          backgroundColor: AppColors.cardColorTheme(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    LucideIcons.compass,
                    size: 32,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Let’s build your first streak",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textColor(isDark),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "A habit only becomes legendary when it’s captured. Take sixty seconds right now to set up the ritual you’ll protect for the next 66 days.",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.greyColorTheme(isDark),
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    _buildDialogStep(
                      number: "1",
                      text:
                          "Name the identity you’re stepping into—make it vivid and personal.",
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildDialogStep(
                      number: "2",
                      text:
                          "Choose when it happens so notifications nudge you at the perfect moment.",
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildDialogStep(
                      number: "3",
                      text:
                          "Tap save and instantly see your streak dashboard come alive.",
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () {
                    SharePrefsService.markFirstHabitDialogShown();
                    Navigator.of(dialogContext).pop();
                    _openAddHabit();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.darkBackgroundColor,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text("Create my first habit"),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () {
                      SharePrefsService.markFirstHabitDialogShown();
                      Navigator.of(dialogContext).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.greyColorTheme(isDark),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text("I’ll explore a bit first"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyStateCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      margin: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              LucideIcons.sparkles,
              size: 34,
              color: AppColors.darkBackgroundColor,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            "Your streak canvas is ready",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.textColor(isDark),
              fontWeight: FontWeight.w800,
              fontSize: 26,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Start with one habit. Give it a name, set the cadence, and watch your dashboard light up with momentum.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.greyColorTheme(isDark),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedAddHabitButton(bool isDark) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: InkWell(
        onTap: () {
          SharePrefsService.markFirstHabitDialogShown();
          _openAddHabit();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withValues(alpha: 0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.55),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.plus,
                color: AppColors.darkBackgroundColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                "Add my first streak",
                style: GoogleFonts.poppins(
                  color: AppColors.darkBackgroundColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAddHabit() {
    SharePrefsService.markFirstHabitDialogShown();
    _firstHabitDialogScheduled = false;
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => const AddStrekScreen(),
      ),
    )
        .then((_) {
      context.read<StreaksBloc>().add(LoadStreaks());
    });
  }

  Widget _buildDialogStep({
    required String number,
    required String text,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.backgroundColor(isDark),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textColor(isDark),
            ),
          ),
        ),
      ],
    );
  }
}
