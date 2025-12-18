import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:streaks/services/notification_service.dart';

part 'streaks_database.g.dart';

@Collection()
class Streak {
  Id id = Isar.autoIncrement;

  @Index()
  late String name;

  late int notificationHour;

  late int notificationMinute;

  late List<String> daysOfWeek;

  late int colorCode;

  late int selectedWeek;

  late List<DateTime> streakDates;

  late int iconCode;

  late List<int> selectedDays;

  late List<int>? unlockedBadges;

  Streak({
    required this.name,
    required this.notificationHour,
    required this.notificationMinute,
    required this.daysOfWeek,
    required this.colorCode,
    required this.streakDates,
    required this.selectedWeek,
    required this.selectedDays,
    required this.iconCode,
    this.unlockedBadges,
  });
}

class StreaksDatabase {
  static late Isar isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [StreakSchema],
      directory: dir.path,
      inspector: true, // Enable the Isar inspector if needed
    );
  }

  static Future<void> addStreak(Streak streak) async {
    await isar.writeTxn(() async {
      await isar.streaks.put(streak);
    });
  }

  static Future<List<Streak>> getAllStreaks() async {
    return await isar.streaks.where().findAll();
  }

  static Future<int> getAllStreaksLength() async {
    return await isar.streaks.where().count();
  }

  static Future<void> addStreakDate(Id id, DateTime date) async {
    await isar.writeTxn(() async {
      final streak = await isar.streaks.get(id);
      DateTime dateWithoutTime = DateTime(date.year, date.month, date.day);
      if (streak != null && !streak.streakDates.contains(dateWithoutTime)) {
        streak.streakDates.add(dateWithoutTime);
        await isar.streaks.put(streak);
      }
    });
  }

  static Future<void> unlockBadge(Id id, int badgeLevel) async {
    await isar.writeTxn(() async {
      final streak = await isar.streaks.get(id);
      if (streak != null) {
        // Ensure we have a mutable list
        final badges = List<int>.from(streak.unlockedBadges ?? []);
        if (!badges.contains(badgeLevel)) {
          badges.add(badgeLevel);
          streak.unlockedBadges = badges;
          await isar.streaks.put(streak);
        }
      }
    });
  }

  static Future<Streak?> getStreakById(Id id) async {
    return await isar.streaks.get(id);
  }

  static Future<void> deleteStreakById(Id id) async {
    // Get the streak first to cancel its notification
    final streak = await isar.streaks.get(id);

    // Cancel notification before deletion
    if (streak != null) {
      await NotificationService.cancelNotificationForStreak(streak.name);
    }

    await isar.writeTxn(() async {
      await isar.streaks.delete(id);
    });
  }

  static Future<void> removeStreakDate(Id id, DateTime date) async {
    await isar.writeTxn(() async {
      final streak = await isar.streaks.get(id);
      DateTime dateWithoutTime = DateTime(date.year, date.month, date.day);
      if (streak != null && streak.streakDates.contains(dateWithoutTime)) {
        streak.streakDates.remove(dateWithoutTime);
        await isar.streaks.put(streak);
      }
    });
  }

  static Future<void> deleteAllStreaks() async {
    final streaks = await getAllStreaks();
    await isar.writeTxn(() async {
      // Cancel all notifications first
      for (var streak in streaks) {
        await NotificationService.cancelNotificationForStreak(streak.name);
      }
      // Delete all streaks
      await isar.streaks.clear();
    });
  }

  static Future<void> importStreaks(List<Streak> streaks) async {
    await isar.writeTxn(() async {
      for (var streak in streaks) {
        // Reset ID to allow auto-increment
        streak.id = Isar.autoIncrement;
        await isar.streaks.put(streak);
      }
    });
  }
}
