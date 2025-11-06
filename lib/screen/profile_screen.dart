import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gap/gap.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/bloc/theme_bloc.dart';
import 'package:streaks/bloc/leaderboard_bloc.dart';
import 'package:streaks/bloc/leaderboard_event.dart';
import 'package:streaks/bloc/leaderboard_state.dart';
import 'package:streaks/services/auth_service.dart';
import 'package:streaks/services/leaderboard_service.dart';
import 'package:streaks/services/analytics_service.dart';
import 'package:streaks/components/streak_stat_card.dart';
import 'package:streaks/res/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userStats;
  Map<String, dynamic>? _overallSummary;
  int? _rank;
  bool _isLoading = true;
  bool _lastSignedInState = false;

  @override
  void initState() {
    super.initState();
    _lastSignedInState = AuthService.isSignedIn;
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    final userStats = await LeaderboardService.calculateUserStats();
    final overallSummary = await AnalyticsService.getOverallSummary();
    int? rank;

    if (AuthService.isSignedIn) {
      rank = await LeaderboardService.getCurrentUserRank();
    }

    setState(() {
      _userStats = userStats;
      _overallSummary = overallSummary;
      _rank = rank;
      _isLoading = false;
    });
  }

  // Public method to reload profile data (called when screen becomes visible)
  void reloadData() {
    _loadProfileData();
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
              "Profile",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w900,
                fontSize: 18.0,
                color: AppColors.darkBackgroundColor,
              ),
            ),
            actions: [
              if (AuthService.isSignedIn)
                IconButton(
                  icon: Icon(
                    LucideIcons.refreshCw,
                    color: AppColors.darkBackgroundColor,
                  ),
                  onPressed: _loadProfileData,
                ),
            ],
          ),
          body: BlocListener<LeaderboardBloc, LeaderboardState>(
            listener: (context, state) {
              // Reload profile data when auth state changes
              if (mounted && state.isSignedIn != _lastSignedInState) {
                _lastSignedInState = state.isSignedIn;
                _loadProfileData();
              }
            },
            child: BlocBuilder<LeaderboardBloc, LeaderboardState>(
              builder: (context, leaderboardState) {
                if (_isLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                }

                if (!AuthService.isSignedIn) {
                  return _buildSignInScreen(context, isDark, leaderboardState);
                }

                return _buildProfileContent(context, isDark, leaderboardState);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignInScreen(
      BuildContext context, bool isDark, LeaderboardState leaderboardState) {
    final isLoading = leaderboardState.isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Gap(40),
          if (isLoading)
            SpinKitFadingCircle(
              color: AppColors.primaryColor,
              size: 60.0,
            )
          else
            Icon(
              LucideIcons.user,
              size: 80,
              color: AppColors.greyColorTheme(isDark),
            ),
          const Gap(24),
          Text(
            isLoading ? 'Signing in...' : 'Sign In to View Profile',
            style: GoogleFonts.poppins(
              color: AppColors.textColor(isDark),
              fontWeight: FontWeight.bold,
              fontSize: 24.0,
            ),
          ),
          const Gap(12),
          Text(
            isLoading
                ? 'Please wait while we sign you in'
                : 'Sign in to see your profile stats,\nlevel, rank, and achievements',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.greyColorTheme(isDark),
              fontSize: 14.0,
            ),
          ),
          const Gap(40),
          // Google Sign In Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading
                  ? null
                  : () {
                      context
                          .read<LeaderboardBloc>()
                          .add(const SignInWithGoogle());
                    },
              icon: const Icon(LucideIcons.mail),
              label: const Text('Sign in with Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                disabledBackgroundColor: Colors.grey,
                disabledForegroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const Gap(16),
          // Apple Sign In Button (iOS only)
          if (Platform.isIOS)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading
                    ? null
                    : () {
                        context
                            .read<LeaderboardBloc>()
                            .add(const SignInWithApple());
                      },
                icon: const Icon(LucideIcons.apple),
                label: const Text('Sign in with Apple'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                  disabledForegroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          const Gap(40),
          // Show stats even when not signed in
          if (!isLoading && _userStats != null && _overallSummary != null)
            _buildStatsSection(isDark),
        ],
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    bool isDark,
    LeaderboardState leaderboardState,
  ) {
    return RefreshIndicator(
      onRefresh: _loadProfileData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.sidePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            _buildProfileHeader(context, isDark, leaderboardState),
            const Gap(24),
            // Stats Cards
            if (_userStats != null && _overallSummary != null)
              _buildStatsSection(isDark),
            const Gap(24),
            // Level Badge Section
            if (_userStats != null) _buildLevelBadgeSection(isDark),
            const Gap(24),
            // Sign Out Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<LeaderboardBloc>().add(const SignOut());
                  _loadProfileData();
                },
                icon: Icon(LucideIcons.logOut,
                    color: AppColors.textColor(isDark)),
                label: Text(
                  'Sign Out',
                  style: GoogleFonts.poppins(
                    color: AppColors.textColor(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                      color: AppColors.greyColorTheme(isDark)
                          .withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const Gap(24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    bool isDark,
    LeaderboardState leaderboardState,
  ) {
    final photoUrl = AuthService.photoUrl;
    final displayName = AuthService.displayName ?? 'User';
    final email = AuthService.email ?? '';
    final level = _userStats?['level'] as int? ?? 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColorTheme(isDark),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        children: [
          // Profile Picture with Badge
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl == null || photoUrl.isEmpty
                    ? Icon(
                        LucideIcons.user,
                        size: 40,
                        color: AppColors.textColor(isDark),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.backgroundColor(isDark),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      LeaderboardService.getBadgeAssetPath(level),
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: GoogleFonts.poppins(
                    color: AppColors.textColor(isDark),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const Gap(4),
                  Text(
                    email,
                    style: GoogleFonts.poppins(
                      color: AppColors.greyColorTheme(isDark),
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (_rank != null) ...[
                  const Gap(8),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.trophy,
                        size: 16,
                        color: AppColors.primaryColor,
                      ),
                      const Gap(4),
                      Text(
                        'Rank #$_rank',
                        style: GoogleFonts.poppins(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isDark) {
    final totalHabits = _overallSummary?['totalHabits'] as int? ?? 0;
    final totalCompletions = _overallSummary?['totalCompletions'] as int? ?? 0;
    final longestStreak = _overallSummary?['longestStreak'] as int? ?? 0;
    final consistencyScore =
        _overallSummary?['consistencyScore'] as double? ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: GoogleFonts.poppins(
            color: AppColors.textColor(isDark),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const Gap(12),
        Row(
          children: [
            StreakStatCard(
              title: 'Total Habits',
              value: totalHabits.toString(),
              isDark: isDark,
            ),
            const Gap(12),
            StreakStatCard(
              title: 'Completions',
              value: totalCompletions.toString(),
              isDark: isDark,
            ),
          ],
        ),
        const Gap(12),
        Row(
          children: [
            StreakStatCard(
              title: 'Longest Streak',
              value: longestStreak.toString(),
              suffix: ' days',
              isDark: isDark,
            ),
            const Gap(12),
            StreakStatCard(
              title: 'Consistency',
              value: consistencyScore.toStringAsFixed(0),
              suffix: '%',
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLevelBadgeSection(bool isDark) {
    final level = _userStats?['level'] as int? ?? 1;
    final totalCompletedStreaks =
        _userStats?['totalCompletedStreaks'] as int? ?? 0;

    // Calculate progress to next level
    int nextLevelThreshold;
    int currentLevelThreshold;
    if (level >= 5) {
      nextLevelThreshold = 501;
      currentLevelThreshold = 501;
    } else if (level == 4) {
      nextLevelThreshold = 501;
      currentLevelThreshold = 201;
    } else if (level == 3) {
      nextLevelThreshold = 201;
      currentLevelThreshold = 101;
    } else if (level == 2) {
      nextLevelThreshold = 101;
      currentLevelThreshold = 51;
    } else {
      nextLevelThreshold = 51;
      currentLevelThreshold = 0;
    }

    final progress = nextLevelThreshold > currentLevelThreshold
        ? ((totalCompletedStreaks - currentLevelThreshold) /
                (nextLevelThreshold - currentLevelThreshold))
            .clamp(0.0, 1.0)
        : 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColorTheme(isDark),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        children: [
          Text(
            'Current Level',
            style: GoogleFonts.poppins(
              color: AppColors.textColor(isDark),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const Gap(16),
          Image.asset(
            LeaderboardService.getBadgeAssetPath(level),
            width: 80,
            height: 80,
          ),
          const Gap(16),
          Text(
            'Level $level',
            style: GoogleFonts.poppins(
              color: AppColors.textColor(isDark),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const Gap(8),
          if (level < 5) ...[
            Text(
              '$totalCompletedStreaks / $nextLevelThreshold completions',
              style: GoogleFonts.poppins(
                color: AppColors.greyColorTheme(isDark),
                fontSize: 14,
              ),
            ),
            const Gap(12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.secondaryColorTheme(isDark),
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                minHeight: 8,
              ),
            ),
            const Gap(8),
            Text(
              '${(progress * 100).toStringAsFixed(0)}% to Level ${level + 1}',
              style: GoogleFonts.poppins(
                color: AppColors.greyColorTheme(isDark),
                fontSize: 12,
              ),
            ),
          ] else ...[
            Text(
              'Maximum Level Reached!',
              style: GoogleFonts.poppins(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
