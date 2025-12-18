import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:streaks/bloc/theme_bloc.dart';
import 'package:streaks/components/streak_stat_card.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/screen/main_navigation_screen.dart';
import 'package:streaks/screen/review_request_screen.dart';
import 'package:streaks/screen/streak_details/widgets/custom_button.dart';
import 'package:streaks/services/notification_service.dart';
import 'package:streaks/services/share_prefs_services.dart';

class _OnboardingSlide {
  final String title;
  final String description;
  final List<String> highlights;
  final Widget Function(BuildContext context, bool isDark) previewBuilder;

  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.highlights,
    required this.previewBuilder,
  });
}

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;
  bool _isRequestingNotifications = false;
  late final List<_OnboardingSlide> _slides;
  late final int _notificationSlideIndex;

  @override
  void initState() {
    super.initState();
    _slides = [
      _OnboardingSlide(
        title: "Welcome to the streaks renaissance",
        description:
            "Streaks 2026 is where ambitious routines turn into daily victories. "
            "We craft the structure so you can focus on chasing the version of you that stays consistent, energized, and clear on the next micro-win.",
        highlights: [
          "Wake up to a gentle command center that celebrates yesterday and primes today's focus.",
          "Craft rituals with intention—icons, cadence, reminders, and accountability in one elegant flow.",
          "See your year with clarity, not guesswork, so every check-in feels like momentum.",
        ],
        previewBuilder: (context, isDark) => _buildHeroPreview(isDark),
      ),
      _OnboardingSlide(
        title: "Experience your streak story in real time",
        description:
            "Our streak detail view gives you a living snapshot of progress. The heat, the highs, and the steady climb—it’s all there to keep your discipline visible.",
        highlights: [
          "Watch your longest streak grow and never lose sight of the current run you're protecting.",
          "Track completion rate with progress bars that glow brighter as discipline compounds.",
          "Zoom in on the rhythm of your week with a quick cadence map of completed days.",
        ],
        previewBuilder: (context, isDark) => _buildStreakDetailPreview(isDark),
      ),
      _OnboardingSlide(
        title: "Turn your data into momentum",
        description:
            "The report room transforms raw check-ins into meaningful coaching. We surface patterns, wins, gaps, and time-of-day insights so you know precisely where to push.",
        highlights: [
          "Spot your most consistent habits, plus the ones that need a different strategy.",
          "Judge trends across weeks and months with charts designed for quick decoding.",
          "Pull personalized insights and next actions so there’s always a clear move forward.",
        ],
        previewBuilder: (context, isDark) => _buildAnalyticsPreview(isDark),
      ),
      _OnboardingSlide(
        title: "Stay in rhythm with reminders",
        description:
            "Let Streaks tap you on the shoulder at the perfect moment so momentum never slips.",
        highlights: [
          "Preview the kind of nudges you'll see when it’s time to check in.",
          "Stack reminders for different habits so no streak gets left behind.",
          "You’re in control—enable now or revisit notification preferences anytime.",
        ],
        previewBuilder: _buildNotificationPreview,
      ),
      _OnboardingSlide(
        title: "Join a leaderboard built on real consistency",
        description:
            "You’re never building alone. Earn your badge, climb the ranks, and measure yourself against a community that sweats the same details.",
        highlights: [
          "Premium badges signal your dedication and unlock deeper performance tracking.",
          "Refresh the board anytime for a live glimpse of where you stand worldwide.",
          "Sync seamlessly across devices—your progress is safe, synced, and always ready.",
        ],
        previewBuilder: (context, isDark) => _buildCommunityPreview(isDark),
      ),
    ];

    _notificationSlideIndex = _slides.indexWhere(
      (slide) => slide.title == "Stay in rhythm with reminders",
    );
  }

  Future<bool> _requestNotificationPermission() async {
    setState(() {
      _isRequestingNotifications = true;
    });

    try {
      await NotificationService.initializeNotifications();
      return true;
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingNotifications = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState is ThemeLoaded ? themeState.isDark : true;
        return Scaffold(
          backgroundColor: AppColors.backgroundColor(isDark),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.greyColorTheme(isDark),
                      ),
                      onPressed: _completeOnboarding,
                      child: const Text("Skip"),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _slides.length,
                      onPageChanged: (value) {
                        setState(() {
                          currentIndex = value;
                        });
                      },
                      itemBuilder: (context, index) {
                        final slide = _slides[index];
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Streaks 2026",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.greyColorTheme(isDark),
                                ),
                              ),
                              const Gap(12),
                              Text(
                                slide.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 30,
                                  height: 1.2,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textColor(isDark),
                                ),
                              ),
                              const Gap(24),
                              slide.previewBuilder(context, isDark),
                              const Gap(24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: slide.highlights.map((point) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 28,
                                          width: 28,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryColor
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            LucideIcons.sparkles,
                                            size: 16,
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            point,
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              height: 1.5,
                                              color:
                                                  AppColors.textColor(isDark),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Gap(16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) {
                        final bool isActive = index == currentIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 10,
                          width: isActive ? 28 : 10,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primaryColor
                                : AppColors.greyColorTheme(isDark)
                                    .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        );
                      },
                    ),
                  ),
                  const Gap(20),
                  CustomButton(
                    label: (currentIndex == _notificationSlideIndex &&
                            _notificationSlideIndex != -1)
                        ? "Enable notifications"
                        : (currentIndex == _slides.length - 1
                            ? "Begin my streak journey"
                            : "Next chapter"),
                    width: double.infinity,
                    isLoading: currentIndex == _notificationSlideIndex &&
                        _isRequestingNotifications,
                    onTap: () async {
                      if (_isRequestingNotifications) return;

                      final bool isNotificationSlide =
                          currentIndex == _notificationSlideIndex &&
                              _notificationSlideIndex != -1;
                      final bool isLastSlide =
                          currentIndex == _slides.length - 1;

                      if (isNotificationSlide) {
                        await _requestNotificationPermission();
                        if (!mounted) return;
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                        return;
                      }

                      if (isLastSlide) {
                        if (!mounted) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ReviewRequestScreen(
                              onFinished: _completeOnboarding,
                            ),
                          ),
                        );
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _completeOnboarding() {
    SharePrefsService.setFirstTime();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const MainNavigationScreen(
          showSubscriptionOnLaunch: true,
        ),
      ),
      (route) => false,
    );
  }

  Widget _buildNotificationPreview(BuildContext context, bool isDark) {
    const String statusText =
        "Enable notifications to receive timely nudges like the preview below.";
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withValues(alpha: 0.18),
            AppColors.primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.2),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Notification preview",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor(isDark),
            ),
          ),
          const Gap(16),
          _notificationMockCard(
            isDark: isDark,
            accent: AppColors.primaryColor,
            icon: LucideIcons.flame,
            title: "Hydration streak check-in",
            body:
                "Five minutes to go. Log your water ritual to keep the 14-day run alive.",
            timeLabel: "7:00 AM",
          ),
          const Gap(12),
          _notificationMockCard(
            isDark: isDark,
            accent: Colors.deepOrangeAccent,
            icon: LucideIcons.sparkles,
            title: "Evening reflection moment",
            body:
                "Your calm-close streak is two taps away. Capture today before midnight.",
            timeLabel: "9:00 PM",
          ),
          const Gap(24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardColorTheme(isDark),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primaryColor.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.bellRing,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    statusText,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.textColor(isDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationMockCard({
    required bool isDark,
    required Color accent,
    required IconData icon,
    required String title,
    required String body,
    required String timeLabel,
  }) {
    final Color cardColor =
        AppColors.cardColorTheme(isDark).withValues(alpha: 0.92);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.1),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor(isDark),
                        ),
                      ),
                    ),
                    Text(
                      timeLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.greyColorTheme(isDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.greyColorTheme(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildHeroPreview(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withValues(alpha: 0.18),
            AppColors.primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.25),
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      AppColors.cardColorTheme(isDark).withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Today • Momentum dial",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textColor(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                LucideIcons.sun,
                color: AppColors.primaryColor,
                size: 22,
              ),
            ],
          ),
          const Gap(20),
          Text(
            "“Stay loyal to the vision,\neven when motivation fades.”",
            style: GoogleFonts.poppins(
              fontSize: 20,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: AppColors.textColor(isDark),
            ),
          ),
          const Gap(20),
          LinearProgressIndicator(
            value: 0.72,
            minHeight: 8,
            backgroundColor: AppColors.cardColorTheme(isDark),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
          const Gap(12),
          Text(
            "3 of 4 rituals complete • You’re ahead of your weekly pace",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildStreakDetailPreview(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColorTheme(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.dumbbell,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Morning Strength Ritual",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor(isDark),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Day 28",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Gap(20),
          Column(
            children: [
              Row(
                children: [
                  StreakStatCard(
                    title: "Current",
                    value: "12",
                    suffix: "days",
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  StreakStatCard(
                    title: "Longest",
                    value: "24",
                    suffix: "days",
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  StreakStatCard(
                    title: "Completion",
                    value: "87",
                    suffix: "%",
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
          const Gap(20),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: 0.88,
              minHeight: 8,
              backgroundColor: AppColors.backgroundColor(isDark),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          ),
          const Gap(8),
          Text(
            "You’ve hit every scheduled Monday for 6 straight weeks.",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.greyColorTheme(isDark),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildAnalyticsPreview(bool isDark) {
    final cardColor = AppColors.backgroundColor(isDark);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColorTheme(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Insight Console",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textColor(isDark),
            ),
          ),
          const Gap(16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Overall completion rate",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.greyColorTheme(isDark),
                  ),
                ),
                const Gap(6),
                Text(
                  "92%",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryColor,
                  ),
                ),
                const Gap(12),
                LinearProgressIndicator(
                  value: 0.92,
                  minHeight: 6,
                  backgroundColor:
                      AppColors.greyColorTheme(isDark).withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
          _InsightTile(
            isDark: isDark,
            icon: LucideIcons.clock4,
            title: "Best focus window",
            subtitle: "6:00 – 8:00 AM • 94% completion",
          ),
          const Gap(12),
          _InsightTile(
            isDark: isDark,
            icon: LucideIcons.target,
            title: "Habit to reinforce",
            subtitle: "Evening reflection streak dipped last week.",
          ),
        ],
      ),
    );
  }

  static Widget _buildCommunityPreview(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColorTheme(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.trophy,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Global Consistency Board",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor(isDark),
                  ),
                ),
              ),
            ],
          ),
          const Gap(20),
          _LeaderboardTile(
            isDark: isDark,
            rank: 1,
            name: "Alex Momentum",
            streak: "145 day streak",
            badgeLabel: "Mythic",
          ),
          const Gap(12),
          _LeaderboardTile(
            isDark: isDark,
            rank: 2,
            name: "Nia Rhythm",
            streak: "109 day streak",
            badgeLabel: "Elite",
          ),
          const Gap(12),
          _LeaderboardTile(
            isDark: isDark,
            rank: 3,
            name: "You",
            streak: "Ready to climb",
            badgeLabel: "New Challenger",
            highlighted: true,
          ),
          const Gap(20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.sparkle,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Premium unlocks elite badges, deeper analytics, and auto-sync.",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textColor(isDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String subtitle;

  const _InsightTile({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor(isDark),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.greyColorTheme(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final bool isDark;
  final int rank;
  final String name;
  final String streak;
  final String badgeLabel;
  final bool highlighted;

  const _LeaderboardTile({
    required this.isDark,
    required this.rank,
    required this.name,
    required this.streak,
    required this.badgeLabel,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.primaryColor.withValues(alpha: 0.15)
            : AppColors.backgroundColor(isDark),
        borderRadius: BorderRadius.circular(16),
        border: highlighted
            ? Border.all(color: AppColors.primaryColor.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: highlighted
                  ? AppColors.primaryColor
                  : AppColors.greyColorTheme(isDark).withValues(alpha: 0.6),
            ),
            alignment: Alignment.center,
            child: Text(
              rank.toString(),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: highlighted
                    ? AppColors.darkBackgroundColor
                    : AppColors.backgroundColor(isDark),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  streak,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.greyColorTheme(isDark),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badgeLabel,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
