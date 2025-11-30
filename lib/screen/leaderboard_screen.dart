import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/bloc/theme_bloc.dart';
import 'package:streaks/bloc/leaderboard_bloc.dart';
import 'package:streaks/bloc/leaderboard_event.dart';
import 'package:streaks/bloc/leaderboard_state.dart';
import 'package:streaks/services/leaderboard_service.dart';
import 'package:gap/gap.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

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
              "Leaderboard",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w900,
                fontSize: 18.0,
                color: AppColors.darkBackgroundColor,
              ),
            ),
            actions: [
              BlocBuilder<LeaderboardBloc, LeaderboardState>(
                builder: (context, state) {
                  if (state.isSignedIn) {
                    return IconButton(
                      icon: Icon(
                        LucideIcons.refreshCw,
                        color: AppColors.darkBackgroundColor,
                      ),
                      onPressed: () {
                        context
                            .read<LeaderboardBloc>()
                            .add(const RefreshLeaderboard());
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
            builder: (context, state) {
              if (!state.isSignedIn) {
                return _buildSignInScreen(context, isDark, state);
              }

              if (state.isLoading && state.leaderboard.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }

              if (state.error != null && state.leaderboard.isEmpty) {
                return _buildErrorScreen(context, isDark, state.error!);
              }

              return _buildLeaderboardContent(context, isDark, state);
            },
          ),
        );
      },
    );
  }

  Widget _buildSignInScreen(
      BuildContext context, bool isDark, LeaderboardState state) {
    final isLoading = state.isLoading;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SpinKitFadingCircle(
                color: AppColors.primaryColor,
                size: 60.0,
              )
            else
              Icon(
                LucideIcons.trophy,
                size: 80,
                color: AppColors.greyColorTheme(isDark),
              ),
            const Gap(24),
            Text(
              isLoading ? 'Signing in...' : 'Join the Leaderboard',
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
                  : 'Sign in to compete with other users\nand see your ranking',
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
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, bool isDark, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 64,
              color: Colors.red,
            ),
            const Gap(16),
            Text(
              'Error',
              style: GoogleFonts.poppins(
                color: AppColors.textColor(isDark),
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            const Gap(8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: AppColors.greyColorTheme(isDark),
                fontSize: 14.0,
              ),
            ),
            const Gap(24),
            ElevatedButton(
              onPressed: () {
                context.read<LeaderboardBloc>().add(const LoadLeaderboard());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardContent(
      BuildContext context, bool isDark, LeaderboardState state) {
    final userId = state.user?.uid;

    return Column(
      children: [
        // User Info Card
        if (userId != null) _buildUserInfoCard(context, isDark, state, userId),

        // Leaderboard List
        Expanded(
          child: state.leaderboard.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.trophy,
                        size: 64,
                        color: AppColors.greyColorTheme(isDark),
                      ),
                      const Gap(16),
                      Text(
                        'No users yet',
                        style: GoogleFonts.poppins(
                          color: AppColors.textColor(isDark),
                          fontSize: 16,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        'Be the first to join!',
                        style: GoogleFonts.poppins(
                          color: AppColors.greyColorTheme(isDark),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<LeaderboardBloc>()
                        .add(const RefreshLeaderboard());
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.leaderboard.length,
                    itemBuilder: (context, index) {
                      final entry = state.leaderboard[index];
                      final isCurrentUser = entry['userId'] == userId;
                      return _buildLeaderboardEntry(
                          context, isDark, entry, index + 1, isCurrentUser);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildUserInfoCard(BuildContext context, bool isDark,
      LeaderboardState state, String userId) {
    final userEntry = state.leaderboard.firstWhere(
      (entry) => entry['userId'] == userId,
      orElse: () => {},
    );

    final displayName = userEntry['displayName'] as String?;
    final nameInitial = displayName != null && displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : 'U';

    if (userEntry.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardColorTheme(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              child: Text(
                nameInitial,
                style: GoogleFonts.poppins(
                  color: AppColors.textColor(isDark),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName != null && displayName.isNotEmpty
                        ? displayName
                        : 'Anonymous',
                    style: GoogleFonts.poppins(
                      color: AppColors.textColor(isDark),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    'Uploading your data...',
                    style: GoogleFonts.poppins(
                      color: AppColors.greyColorTheme(isDark),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon:
                  Icon(LucideIcons.logOut, color: AppColors.textColor(isDark)),
              onPressed: () {
                context.read<LeaderboardBloc>().add(const SignOut());
              },
            ),
          ],
        ),
      );
    }

    final level = userEntry['level'] as int;
    final rank = userEntry['rank'] as int;
    final totalStreaks = userEntry['totalStreaks'] as int;
    final totalCompletedStreaks = userEntry['totalCompletedStreaks'] as int;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withValues(alpha: 0.3),
            AppColors.primaryColor.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Profile Picture
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                child: Text(
                  nameInitial,
                  style: GoogleFonts.poppins(
                    color: AppColors.textColor(isDark),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
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
                      width: 20,
                      height: 20,
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName != null && displayName.isNotEmpty
                            ? displayName
                            : 'Anonymous',
                        style: GoogleFonts.poppins(
                          color: AppColors.textColor(isDark),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#$rank',
                        style: GoogleFonts.poppins(
                          color: AppColors.darkBackgroundColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(LucideIcons.target,
                        size: 14, color: AppColors.greyColorTheme(isDark)),
                    const Gap(4),
                    Text(
                      '$totalStreaks habits',
                      style: GoogleFonts.poppins(
                        color: AppColors.greyColorTheme(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(LucideIcons.checkCircle2,
                        size: 14, color: AppColors.greyColorTheme(isDark)),
                    const Gap(4),
                    Text(
                      '$totalCompletedStreaks completed',
                      style: GoogleFonts.poppins(
                        color: AppColors.greyColorTheme(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(LucideIcons.logOut, color: AppColors.textColor(isDark)),
            onPressed: () {
              context.read<LeaderboardBloc>().add(const SignOut());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardEntry(
    BuildContext context,
    bool isDark,
    Map<String, dynamic> entry,
    int rank,
    bool isCurrentUser,
  ) {
    final level = entry['level'] as int;
    final totalStreaks = entry['totalStreaks'] as int;
    final totalCompletedStreaks = entry['totalCompletedStreaks'] as int;
    final String? displayName = entry['displayName'] as String?;
    final photoUrl = entry['photoUrl'] as String?;

    final nameInitial = displayName != null && displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : 'U';

    // Medal colors for top 3
    Color? rankColor;
    IconData? rankIcon;
    if (rank == 1) {
      rankColor = Colors.amber;
      rankIcon = LucideIcons.trophy;
    } else if (rank == 2) {
      rankColor = Colors.grey;
      rankIcon = LucideIcons.trophy;
    } else if (rank == 3) {
      rankColor = Colors.brown;
      rankIcon = LucideIcons.trophy;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primaryColor.withValues(alpha: 0.2)
            : AppColors.cardColorTheme(isDark),
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(
                color: AppColors.primaryColor,
                width: 2,
              )
            : null,
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            alignment: Alignment.center,
            child: rank <= 3
                ? Icon(
                    rankIcon,
                    color: rankColor,
                    size: 24,
                  )
                : Text(
                    '#$rank',
                    style: GoogleFonts.poppins(
                      color: AppColors.greyColorTheme(isDark),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
          const Gap(12),
          // Profile Picture
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                child: Text(
                  nameInitial,
                  style: GoogleFonts.poppins(
                    color: AppColors.textColor(isDark),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.backgroundColor(isDark),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      LeaderboardService.getBadgeAssetPath(level),
                      width: 16,
                      height: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Gap(12),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName != null && displayName.isNotEmpty
                      ? displayName
                      : 'Anonymous',
                  style: GoogleFonts.poppins(
                    color: AppColors.textColor(isDark),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const Gap(4),
                Row(
                  children: [
                    Icon(LucideIcons.target,
                        size: 12, color: AppColors.greyColorTheme(isDark)),
                    const Gap(4),
                    Text(
                      '$totalStreaks',
                      style: GoogleFonts.poppins(
                        color: AppColors.greyColorTheme(isDark),
                        fontSize: 11,
                      ),
                    ),
                    const Gap(12),
                    Icon(LucideIcons.checkCircle2,
                        size: 12, color: AppColors.greyColorTheme(isDark)),
                    const Gap(4),
                    Text(
                      '$totalCompletedStreaks',
                      style: GoogleFonts.poppins(
                        color: AppColors.greyColorTheme(isDark),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Level Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryColorTheme(isDark),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Lv.$level',
              style: GoogleFonts.poppins(
                color: AppColors.textColor(isDark),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
