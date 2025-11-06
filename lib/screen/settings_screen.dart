import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:streaks/purchases_bloc/purchases_bloc.dart';
import 'package:streaks/purchases_bloc/purchases_state.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/res/constants.dart';
import 'package:streaks/services/url_launcher_service.dart';
import 'package:streaks/services/data_export_service.dart';
import 'package:streaks/screen/purchases_screen.dart';
import 'package:streaks/screen/support_screen.dart';
import 'package:streaks/screen/updates_screen.dart';
import 'package:streaks/bloc/streaks_bloc.dart';
import 'package:streaks/bloc/theme_bloc.dart';
import 'package:gap/gap.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _vibrationEnabled = true;
  bool _soundEnabled = true;
  String _appVersion = '1.0.0';
  String _buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppVersion();
  }

  Future<void> _loadSettings() async {
    // Load notification settings from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    });
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  Future<void> _saveNotificationSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String? subtitle,
    required VoidCallback? onTap,
    Widget? trailing,
    bool isDark = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardColorTheme(isDark),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDark
                    ? AppColors.primaryColor
                    : AppColors.darkBackgroundColor,
                size: 20,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: AppColors.textColor(isDark),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const Gap(4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: AppColors.greyColorTheme(isDark)
                            .withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (onTap != null) ...[
              const Gap(8),
              Icon(
                LucideIcons.chevronRight,
                color: AppColors.greyColorTheme(isDark).withValues(alpha: 0.5),
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool isDark = true}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          color: AppColors.greyColorTheme(isDark).withValues(alpha: 0.6),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    bool isDark = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardColorTheme(isDark),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isDark
                  ? AppColors.primaryColor
                  : AppColors.darkBackgroundColor,
              size: 20,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: AppColors.textColor(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const Gap(4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: AppColors.greyColorTheme(isDark)
                          .withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryColor,
          ),
        ],
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
            centerTitle: true,
            title: Text(
              'Settings',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w900,
                fontSize: 18.0,
                color: AppColors.darkBackgroundColor,
              ),
            ),
            leading: IconButton(
              icon: Icon(
                LucideIcons.chevronLeft,
                color: AppColors.darkBackgroundColor,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              final isDark =
                  themeState is ThemeLoaded ? themeState.isDark : true;
              return BlocBuilder<PurchasesBloc, PurchasesState>(
                builder: (context, state) {
                  final isPremium = state.isSubscriptionActive;

                  return ListView(
                    padding: const EdgeInsets.all(AppConstants.sidePadding),
                    children: [
                      // Premium Status Card
                      if (!isPremium)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryColor.withValues(alpha: 0.3),
                                AppColors.primaryColor.withValues(alpha: 0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius),
                            border: Border.all(
                              color:
                                  AppColors.primaryColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  LucideIcons.sparkles,
                                  color: isDark
                                      ? AppColors.primaryColor
                                      : AppColors.darkBackgroundColor,
                                  size: 24,
                                ),
                              ),
                              const Gap(16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Unlock Premium',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.textColor(isDark),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Gap(4),
                                    Text(
                                      'Get unlimited streaks and exclusive features',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.greyColorTheme(isDark)
                                            .withValues(alpha: 0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  LucideIcons.chevronRight,
                                  color: isDark
                                      ? AppColors.primaryColor
                                      : AppColors.darkBackgroundColor,
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PurchasesScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryColor.withValues(alpha: 0.3),
                                AppColors.primaryColor.withValues(alpha: 0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor
                                      .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  LucideIcons.crown,
                                  color: isDark
                                      ? AppColors.primaryColor
                                      : AppColors.darkBackgroundColor,
                                  size: 24,
                                ),
                              ),
                              const Gap(16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Premium Active',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.textColor(isDark),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Gap(4),
                                    Text(
                                      'Thank you for your support!',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.greyColorTheme(isDark)
                                            .withValues(alpha: 0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      const Gap(24),

                      // Notifications Section
                      _buildSectionHeader('Notifications', isDark: isDark),
                      const Gap(8),
                      _buildSwitchTile(
                        icon: LucideIcons.bell,
                        title: 'Enable Notifications',
                        subtitle: 'Receive daily reminders for your streaks',
                        value: _notificationsEnabled,
                        isDark: isDark,
                        onChanged: (value) async {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                          await _saveNotificationSetting(
                              'notifications_enabled', value);

                          if (value) {
                            await Permission.notification.request();
                          }
                        },
                      ),
                      const Gap(8),
                      _buildSwitchTile(
                        icon: LucideIcons.vibrate,
                        title: 'Vibration',
                        subtitle: 'Vibrate when notifications arrive',
                        value: _vibrationEnabled,
                        isDark: isDark,
                        onChanged: (value) async {
                          setState(() {
                            _vibrationEnabled = value;
                          });
                          await _saveNotificationSetting(
                              'vibration_enabled', value);
                        },
                      ),
                      const Gap(8),
                      _buildSwitchTile(
                        icon: LucideIcons.volume2,
                        title: 'Sound',
                        subtitle: 'Play sound for notifications',
                        value: _soundEnabled,
                        isDark: isDark,
                        onChanged: (value) async {
                          setState(() {
                            _soundEnabled = value;
                          });
                          await _saveNotificationSetting(
                              'sound_enabled', value);
                        },
                      ),

                      const Gap(24),

                      // Appearance Section
                      _buildSectionHeader('Appearance', isDark: isDark),
                      const Gap(8),
                      BlocBuilder<ThemeBloc, ThemeState>(
                        builder: (context, themeState) {
                          final themeIsDark = themeState is ThemeLoaded
                              ? themeState.isDark
                              : true;
                          return _buildSwitchTile(
                            icon: LucideIcons.palette,
                            title: 'Dark Theme',
                            subtitle: themeIsDark ? 'Enabled' : 'Disabled',
                            value: themeIsDark,
                            isDark: isDark,
                            onChanged: (value) {
                              context.read<ThemeBloc>().add(SetTheme(!value));
                            },
                          );
                        },
                      ),

                      const Gap(24),

                      // Data Section
                      _buildSectionHeader('Data', isDark: isDark),
                      const Gap(8),
                      _buildSettingsItem(
                        icon: LucideIcons.download,
                        title: 'Export Data',
                        subtitle: 'Export your streaks data',
                        isDark: isDark,
                        onTap: () async {
                          await DataExportService.exportData(context);
                        },
                      ),
                      const Gap(8),
                      _buildSettingsItem(
                        icon: LucideIcons.upload,
                        title: 'Import Data',
                        subtitle: 'Import streaks from backup',
                        isDark: isDark,
                        onTap: () async {
                          await DataExportService.importData(context);
                          // Reload streaks after import
                          if (context.mounted) {
                            context.read<StreaksBloc>().add(LoadStreaks());
                          }
                        },
                      ),
                      const Gap(8),
                      _buildSettingsItem(
                        icon: LucideIcons.trash2,
                        title: 'Clear All Data',
                        subtitle: 'Permanently delete all streaks',
                        isDark: isDark,
                        onTap: () => showDeleteAllDialog(),
                      ),

                      const Gap(24),

                      // Support Section
                      _buildSectionHeader('Support', isDark: isDark),
                      const Gap(8),
                      _buildSettingsItem(
                        icon: LucideIcons.helpCircle,
                        title: 'Help & Support',
                        subtitle: 'Get help and contact us',
                        isDark: isDark,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SupportPage(),
                            ),
                          );
                        },
                      ),
                      const Gap(8),
                      _buildSettingsItem(
                        icon: LucideIcons.star,
                        title: 'Rate App',
                        subtitle: 'Love the app? Leave a review!',
                        isDark: isDark,
                        onTap: () async {
                          final url = Platform.isAndroid
                              ? 'https://play.google.com/store/apps/details?id=com.extendztech.streaks'
                              : 'https://apps.apple.com/app/streaks-2025-healthy-habits/id6740426283';
                          await UrlLauncherService.launchURL(url);
                        },
                      ),
                      const Gap(8),
                      _buildSettingsItem(
                        icon: LucideIcons.share2,
                        title: 'Share App',
                        subtitle: 'Tell your friends about Streaks',
                        isDark: isDark,
                        onTap: () async {
                          final url = Platform.isAndroid
                              ? 'https://play.google.com/store/apps/details?id=com.extendztech.streaks'
                              : 'https://apps.apple.com/app/streaks-2025-healthy-habits/id6740426283';
                          await UrlLauncherService.launchURL(url);
                        },
                      ),

                      const Gap(24),

                      // About Section
                      _buildSectionHeader('About', isDark: isDark),
                      const Gap(8),
                      _buildSettingsItem(
                        icon: LucideIcons.info,
                        title: 'What\'s New',
                        subtitle: 'See latest updates and features',
                        isDark: isDark,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const WhatsNewScreen(),
                            ),
                          );
                        },
                      ),
                      const Gap(8),
                      _buildSettingsItem(
                        icon: LucideIcons.fileText,
                        title: 'Privacy Policy',
                        subtitle: 'Read our privacy policy',
                        isDark: isDark,
                        onTap: () async {
                          await UrlLauncherService.launchURL(
                            'https://streaks2025.blogspot.com/2025/01/privacy-policy.html',
                          );
                        },
                      ),
                      const Gap(8),
                      _buildSettingsItem(
                        icon: LucideIcons.fileCheck,
                        title: 'Terms of Service',
                        subtitle: 'Read our terms of service',
                        isDark: isDark,
                        onTap: () async {
                          await UrlLauncherService.launchURL(
                            "https://streaks2025.blogspot.com/2025/11/streaks-2025-terms-of-use.html",
                          );
                        },
                      ),

                      const Gap(24),

                      // App Version
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                'Streaks',
                                style: GoogleFonts.poppins(
                                  color: AppColors.greyColorTheme(isDark)
                                      .withValues(alpha: 0.6),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                'Version $_appVersion (Build $_buildNumber)',
                                style: GoogleFonts.poppins(
                                  color: AppColors.greyColorTheme(isDark)
                                      .withValues(alpha: 0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Gap(32),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void showDeleteAllDialog() {
    final isDark = context.read<ThemeBloc>().state is ThemeLoaded
        ? (context.read<ThemeBloc>().state as ThemeLoaded).isDark
        : true;

    final dialogWidget = Platform.isAndroid
        ? AlertDialog(
            backgroundColor: AppColors.cardColorTheme(isDark),
            title: Text(
              'Clear All Data',
              style: GoogleFonts.poppins(
                color: AppColors.textColor(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to delete all your streaks? This action cannot be undone.',
              style: GoogleFonts.poppins(
                color: AppColors.greyColorTheme(isDark),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    color: AppColors.greyColorTheme(isDark),
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await DataExportService.clearAllData(context);
                  // Reload streaks after clearing
                  if (context.mounted) {
                    context.read<StreaksBloc>().add(LoadStreaks());
                  }
                },
                child: Text(
                  'Delete',
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          )
        : CupertinoAlertDialog(
            title: const Text('Clear All Data'),
            content: const Text(
              'Are you sure you want to delete all your streaks? This action cannot be undone.',
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () async {
                  Navigator.of(context).pop();
                  await DataExportService.clearAllData(context);
                  // Reload streaks after clearing
                  if (context.mounted) {
                    context.read<StreaksBloc>().add(LoadStreaks());
                  }
                },
                child: const Text('Delete'),
              ),
            ],
          );

    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (context) => dialogWidget,
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder: (context) => dialogWidget,
      );
    }
  }
}
