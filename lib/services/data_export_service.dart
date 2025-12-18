import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:streaks/database/streaks_database.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/services/notification_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DataExportService {
  /// Export all streaks to JSON file and share it
  static Future<void> exportData(BuildContext context) async {
    try {
      // Show loading indicator
      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
        ),
      );

      // Get all streaks
      final streaks = await StreaksDatabase.getAllStreaks();

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      if (streaks.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No streaks to export'),
            backgroundColor: AppColors.cardColor,
          ),
        );
        return;
      }

      // Convert streaks to JSON
      final packageInfo = await PackageInfo.fromPlatform();
      final exportData = {
        'app': 'Streaks 2026',
        'version': packageInfo.version,
        'exportDate': DateTime.now().toIso8601String(),
        'streaks': streaks
            .map((streak) => {
                  'name': streak.name,
                  'notificationHour': streak.notificationHour,
                  'notificationMinute': streak.notificationMinute,
                  'daysOfWeek': streak.daysOfWeek,
                  'colorCode': streak.colorCode,
                  'selectedWeek': streak.selectedWeek,
                  'streakDates': streak.streakDates
                      .map((d) => d.toIso8601String())
                      .toList(),
                  'iconCode': streak.iconCode,
                  'selectedDays': streak.selectedDays,
                  'unlockedBadges': streak.unlockedBadges,
                })
            .toList(),
      };

      final jsonString = jsonEncode(exportData);

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'streaks_backup_$timestamp.json';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonString);

      // Share the file
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text:
              'My Streaks 2026 Backup\n\nExported on ${DateTime.now().toString().split('.')[0]}\nTotal streaks: ${streaks.length}',
          subject: 'Streaks 2026 Backup',
        ),
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Successfully exported ${streaks.length} streak(s)',
            style: TextStyle(
              color: AppColors.blackColor,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Error exporting data: $e');
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog if still open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error exporting data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Import streaks from JSON file
  static Future<void> importData(BuildContext context) async {
    try {
      // Pick JSON file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: false,
      );

      if (result == null || result.files.single.path == null) {
        return; // User canceled
      }

      final filePath = result.files.single.path!;
      final file = File(filePath);

      if (!file.existsSync()) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('File not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show loading indicator
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
        ),
      );

      // Read and parse JSON
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate JSON structure
      if (!jsonData.containsKey('streaks') || jsonData['streaks'] is! List) {
        if (!context.mounted) return;
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Invalid backup file format'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final streaksList = jsonData['streaks'] as List;
      final importedStreaks = <Streak>[];

      for (var streakData in streaksList) {
        try {
          final streakMap = streakData as Map<String, dynamic>;

          // Parse streak dates
          final dates = (streakMap['streakDates'] as List)
              .map((d) => DateTime.parse(d as String))
              .toList();

          final streak = Streak(
            name: streakMap['name'] as String,
            notificationHour: streakMap['notificationHour'] as int,
            notificationMinute: streakMap['notificationMinute'] as int,
            daysOfWeek: List<String>.from(streakMap['daysOfWeek'] as List),
            colorCode: streakMap['colorCode'] as int,
            selectedWeek: streakMap['selectedWeek'] as int,
            streakDates: dates,
            selectedDays: List<int>.from(streakMap['selectedDays'] as List),
            iconCode: streakMap['iconCode'] as int,
            unlockedBadges: streakMap['unlockedBadges'] != null
                ? List<int>.from(streakMap['unlockedBadges'] as List)
                : null,
          );

          importedStreaks.add(streak);
        } catch (e) {
          debugPrint('Error parsing streak: $e');
          // Continue with other streaks
        }
      }

      if (importedStreaks.isEmpty) {
        if (!context.mounted) return;
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No valid streaks found in backup file'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Import streaks
      await StreaksDatabase.importStreaks(importedStreaks);

      // Reschedule notifications for imported streaks
      for (var streak in importedStreaks) {
        if (streak.notificationHour >= 0 && streak.notificationMinute >= 0) {
          try {
            await NotificationService.scheduleDailyNotification(
              TimeOfDay(
                hour: streak.notificationHour,
                minute: streak.notificationMinute,
              ),
              streakName: streak.name,
            );
          } catch (e) {
            debugPrint('Error scheduling notification for ${streak.name}: $e');
          }
        }
      }

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '✅ Successfully imported ${importedStreaks.length} streak(s)'),
          backgroundColor: AppColors.primaryColor,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Error importing data: $e');
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog if still open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error importing data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Clear all streaks data
  static Future<void> clearAllData(BuildContext context) async {
    try {
      // Show loading indicator
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
        ),
      );

      // Delete all streaks
      await StreaksDatabase.deleteAllStreaks();

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ All data cleared successfully'),
          backgroundColor: AppColors.primaryColor,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Error clearing data: $e');
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog if still open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error clearing data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
