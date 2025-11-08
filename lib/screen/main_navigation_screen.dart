import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:streaks/bloc/streaks_bloc.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/bloc/theme_bloc.dart';
import 'package:streaks/screen/home_screen.dart';
import 'package:streaks/screen/report_screen.dart';
import 'package:streaks/screen/leaderboard_screen.dart';
import 'package:streaks/screen/profile_screen.dart';
import 'package:streaks/screen/purchases_screen.dart';
import 'package:streaks/services/share_prefs_services.dart';

class MainNavigationScreen extends StatefulWidget {
  final bool showSubscriptionOnLaunch;

  const MainNavigationScreen({
    super.key,
    this.showSubscriptionOnLaunch = false,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // GlobalKeys to access screen states for reloading
  final GlobalKey<ReportScreenState> _reportScreenKey = GlobalKey<ReportScreenState>();
  final GlobalKey<ProfileScreenState> _profileScreenKey = GlobalKey<ProfileScreenState>();

  late final List<Widget> _screens = [
    const HomeScreen(),
    ReportScreen(key: _reportScreenKey),
    const LeaderboardScreen(),
    ProfileScreen(key: _profileScreenKey),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.showSubscriptionOnLaunch) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const PurchasesScreen(),
          ),
        );
        if (!mounted) return;
        SharePrefsService.setFirstHabitDialogPending();
        context.read<StreaksBloc>().add(LoadStreaks());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState is ThemeLoaded ? themeState.isDark : true;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor(isDark),
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.cardColorTheme(isDark),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: LucideIcons.home,
                      label: 'Home',
                      index: 0,
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      icon: LucideIcons.barChart3,
                      label: 'Report',
                      index: 1,
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      icon: LucideIcons.trophy,
                      label: 'Leaderboard',
                      index: 2,
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      icon: LucideIcons.user,
                      label: 'Profile',
                      index: 3,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onTabChanged(int newIndex) {
    // Only reload if switching to a different tab
    if (newIndex != _currentIndex) {
      // Reload data when navigating to ReportScreen (index 1) or ProfileScreen (index 3)
      if (newIndex == 1 && _reportScreenKey.currentState != null) {
        _reportScreenKey.currentState!.reloadData();
      }
      if (newIndex == 3 && _profileScreenKey.currentState != null) {
        _profileScreenKey.currentState!.reloadData();
      }
    }

    setState(() {
      _currentIndex = newIndex;
    });
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          _onTabChanged(index);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected
                    ? AppColors.primaryColor
                    : AppColors.greyColorTheme(isDark),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.greyColorTheme(isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
