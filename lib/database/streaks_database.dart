import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

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

  late int containerColor;

  late int iconCode;

  late List<int> selectedDays;
  Streak({
    required this.name,
    required this.notificationHour,
    required this.notificationMinute,
    required this.daysOfWeek,
    required this.colorCode,
    required this.streakDates,
    required this.selectedWeek,
    required this.containerColor,
    required this.selectedDays,
    required this.iconCode,
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

  static Future<Streak?> getStreakById(Id id) async {
    return await isar.streaks.get(id);
  }

  static Future<void> deleteStreakById(Id id) async {
    await isar.writeTxn(() async {
      await isar.streaks.delete(id);
    });
  }
}
