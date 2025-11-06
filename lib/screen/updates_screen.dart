import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:streaks/bloc/theme_bloc.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/services/share_prefs_services.dart';

/// Centralized list of all app updates
List<UpdateItem> getAppUpdates() {
  return const [
    UpdateItem(
      title: 'Rate App Feature',
      description:
          'Added a new feature to rate the app when you complete one streak',
      type: UpdateType.feature,
    ),
    UpdateItem(
      title: 'Enhanced Badge System',
      description:
          'Improved badge unlocking system with better visual feedback and celebrations',
      type: UpdateType.feature,
    ),
    UpdateItem(
      title: 'Improved Notifications',
      description:
          'Better notification scheduling and reminder system for your habits',
      type: UpdateType.feature,
    ),
    UpdateItem(
      title: 'Performance Improvements',
      description:
          'Optimized app performance and fixed minor bugs for smoother experience',
      type: UpdateType.bugfix,
    ),
  ];
}

/// Full page "What's New" screen
class WhatsNewScreen extends StatefulWidget {
  final bool showMarkAsSeenButton;

  const WhatsNewScreen({
    super.key,
    this.showMarkAsSeenButton = false,
  });

  @override
  State<WhatsNewScreen> createState() => _WhatsNewScreenState();
}

class _WhatsNewScreenState extends State<WhatsNewScreen> {
  String _appVersion = '1.0.0';
  String _buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    final updates = getAppUpdates();

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState is ThemeLoaded ? themeState.isDark : true;
        return Scaffold(
          backgroundColor: AppColors.backgroundColor(isDark),
          appBar: AppBar(
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                LucideIcons.chevronLeft,
                color: AppColors.darkBackgroundColor,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              "What's New",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w900,
                fontSize: 18.0,
                color: AppColors.darkBackgroundColor,
              ),
            ),
          ),
          body: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor.withValues(alpha: 0.3),
                      AppColors.primaryColor.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.rocket_launch,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to Version $_appVersion',
                            style: GoogleFonts.poppins(
                              color: AppColors.textColor(isDark),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Build $_buildNumber',
                            style: GoogleFonts.poppins(
                              color: AppColors.greyColorTheme(isDark),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Updates List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      'Latest Updates',
                      style: GoogleFonts.poppins(
                        color: AppColors.textColor(isDark),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...updates
                        .map((update) => _buildUpdateCard(update, isDark)),
                  ],
                ),
              ),

              // Bottom Button (only show if marked to show)
              if (widget.showMarkAsSeenButton)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardColorTheme(isDark),
                    border: Border(
                      top: BorderSide(
                        color: AppColors.greyColorTheme(isDark)
                            .withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await SharePrefsService.markVersionAsSeen();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Got it!',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpdateCard(UpdateItem update, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardColorTheme(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: update.type == UpdateType.feature
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: update.type == UpdateType.feature
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              update.type == UpdateType.feature
                  ? LucideIcons.sparkles
                  : LucideIcons.wrench,
              size: 24,
              color: update.type == UpdateType.feature
                  ? Colors.green.shade400
                  : Colors.orange.shade400,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: update.type == UpdateType.feature
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        update.type == UpdateType.feature
                            ? 'NEW FEATURE'
                            : 'IMPROVEMENT',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: update.type == UpdateType.feature
                              ? Colors.green.shade400
                              : Colors.orange.shade400,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  update.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor(isDark),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  update.description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.greyColorTheme(isDark),
                    height: 1.5,
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

class WhatsNewDialog extends StatelessWidget {
  final String version;
  final List<UpdateItem> updates;

  const WhatsNewDialog({
    super.key,
    required this.version,
    required this.updates,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState is ThemeLoaded ? themeState.isDark : true;
        return Dialog(
          backgroundColor: AppColors.cardColorTheme(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryColor, AppColors.primaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.rocket_launch,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "What's New",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Version $version',
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: updates
                          .map((update) => _buildUpdateItem(update, isDark))
                          .toList(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Maybe Later',
                          style: TextStyle(
                            color: AppColors.greyColorTheme(isDark),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          await SharePrefsService.markVersionAsSeen();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Got it!'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpdateItem(UpdateItem update, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: update.type == UpdateType.feature
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              update.type == UpdateType.feature
                  ? Icons.new_releases
                  : Icons.bug_report,
              size: 16,
              color: update.type == UpdateType.feature
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  update.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  update.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.greyColorTheme(isDark),
                    height: 1.3,
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

/// Helper function to show what's new dialog (kept for backward compatibility)
Future<void> showWhatsNewDialog(BuildContext context) async {
  final packageInfo = await PackageInfo.fromPlatform();
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WhatsNewDialog(
        version: packageInfo.version,
        updates: getAppUpdates(),
      );
    },
  );
}

enum UpdateType { feature, bugfix }

class UpdateItem {
  final String title;
  final String description;
  final UpdateType type;

  const UpdateItem({
    required this.title,
    required this.description,
    required this.type,
  });
}
