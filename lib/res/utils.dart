import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:streaks/components/share_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppUtils {
  AppUtils._();
  static const String _androidPackageName = 'com.extendztech.streaks';
  static const String _iosAppId = '6740426283';
  static const String _appName = 'Streaks 2025-26 - Habit Tracker';
  static const String _appDescription =
      'Build better habits and track your progress!';

  static Future<void> showRatingDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const RatingDialog();
      },
    );
  }

  static Future<void> rateApp() async {
    try {
      final uri = await _getRatingUri();
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw Exception('Could not launch store');
      }
    } catch (e) {
      debugPrint('Error launching app store: $e');
      // Fallback to web store
      await _launchWebStore();
    }
  }

  static Future<void> shareApp({
    String? customMessage,
    String? customSubject,
  }) async {
    try {
      final String shareText = customMessage ??
          '🌟 Check out $_appName! $_appDescription\n\n'
              '📱 Download now:\n'
              '${await _getStoreUrl()}\n\n'
              '#HabitTracker #Productivity #SelfImprovement';

      final String subject = customSubject ?? 'Check out $_appName!';

      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          subject: subject,
        ),
      );
    } catch (e) {
      debugPrint('Error sharing app: $e');
    }
  }

  static Future<void> shareAppWithFiles({
    required List<String> imagePaths,
    String? customMessage,
  }) async {
    try {
      final String shareText = customMessage ??
          '🌟 Look at my progress with $_appName! $_appDescription\n\n'
              'Download and start your journey:\n'
              '${await _getStoreUrl()}';

      await SharePlus.instance.share(
        ShareParams(
          files: imagePaths.map((path) => XFile(path)).toList(),
          text: shareText,
          subject: 'My $_appName Progress!',
        ),
      );
    } catch (e) {
      debugPrint('Error sharing app with files: $e');
    }
  }

  /// Show share options dialog
  static Future<void> showShareDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return ShareDialog();
      },
    );
  }

  /// Get platform-specific rating URI
  static Future<Uri> _getRatingUri() async {
    if (Platform.isAndroid) {
      return Uri.parse('market://details?id=$_androidPackageName');
    } else if (Platform.isIOS) {
      return Uri.parse(
          'itms-apps://apps.apple.com/app/id$_iosAppId?action=write-review');
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }

  /// Get platform-specific store URL
  static Future<String> _getStoreUrl() async {
    if (Platform.isAndroid) {
      return 'https://play.google.com/store/apps/details?id=$_androidPackageName';
    } else if (Platform.isIOS) {
      return 'https://apps.apple.com/app/id$_iosAppId';
    } else {
      return "https://type.link/umairali";
    }
  }

  /// Fallback web store launch
  static Future<void> _launchWebStore() async {
    try {
      final url = await _getStoreUrl();
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching web store: $e');
    }
  }

  /// Copy app link to clipboard
  static Future<void> copyAppLink(BuildContext context) async {
    try {
      final url = await _getStoreUrl();
      await Clipboard.setData(ClipboardData(text: url));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('App link copied to clipboard!'),
            backgroundColor: const Color(0xFFb8ea6c),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error copying app link: $e');
    }
  }

  /// Send feedback via email
  static Future<void> sendFeedback() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = packageInfo.version;
      final buildNumber = packageInfo.buildNumber;

      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'umairali2k181@gmail.com', // Replace with your email
        query: _encodeQueryParameters(<String, String>{
          'subject': '$_appName Feedback (v$appVersion)',
          'body': 'Hi $_appName Team,\n\n'
              'App Version: $appVersion ($buildNumber)\n'
              'Platform: ${Platform.operatingSystem}\n'
              'Device: ${Platform.operatingSystemVersion}\n\n'
              'My feedback:\n\n',
        }),
      );

      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        throw Exception('Could not launch email');
      }
    } catch (e) {
      debugPrint('Error sending feedback: $e');
    }
  }

  /// Helper method to encode query parameters
  static String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}

// Beautiful Rating Dialog Widget
class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog>
    with TickerProviderStateMixin {
  int selectedRating = 0;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFb8ea6c).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Color(0xFFb8ea6c),
                size: 30,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Rate Your Experience',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'How would you rate your experience with our app?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Rating Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedRating = index + 1;
                    });
                    _controller.forward().then((_) {
                      _controller.reverse();
                    });
                    HapticFeedback.lightImpact();
                  },
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: selectedRating == index + 1
                            ? _scaleAnimation.value
                            : 1.0,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            selectedRating > index
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: selectedRating > index
                                ? const Color(0xFFb8ea6c)
                                : Colors.grey.shade600,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),

            if (selectedRating > 0) ...[
              const SizedBox(height: 20),
              Text(
                _getRatingText(selectedRating),
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFFb8ea6c),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 30),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Maybe Later',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedRating > 0 ? _handleRatingSubmit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFb8ea6c),
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.grey.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      selectedRating >= 4 ? 'Rate in Store' : 'Send Feedback',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'We can do better! 😔';
      case 2:
        return 'Room for improvement 🤔';
      case 3:
        return 'It\'s okay 😐';
      case 4:
        return 'Good experience! 😊';
      case 5:
        return 'Excellent! We love it! 🎉';
      default:
        return '';
    }
  }

  void _handleRatingSubmit() {
    Navigator.of(context).pop();

    if (selectedRating >= 4) {
      // High rating - direct to app store
      AppUtils.rateApp();
    } else {
      // Low rating - send feedback
      AppUtils.sendFeedback();
    }
  }
}
