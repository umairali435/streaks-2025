import 'package:streaks/res/assets.dart';

class BadgeService {
  // Define milestone thresholds for each badge level
  // Badge 1: 1 day
  // Badge 2: 7 days
  // Badge 3: 14 days
  // Badge 4: 30 days
  // Badge 5: 50 days
  // Badge 6: 100 days
  // Badge 7: 200 days
  // Badge 8: 365 days
  static const List<int> badgeMilestones = [1, 7, 14, 30, 50, 100, 200, 365];

  // Get badge asset path by badge level (1-8)
  static String getBadgeAssetPath(int badgeLevel) {
    switch (badgeLevel) {
      case 1:
        return AppAssets.strekLevelBadge1;
      case 2:
        return AppAssets.strekLevelBadge2;
      case 3:
        return AppAssets.strekLevelBadge3;
      case 4:
        return AppAssets.strekLevelBadge4;
      case 5:
        return AppAssets.strekLevelBadge5;
      case 6:
        return AppAssets.strekLevelBadge6;
      case 7:
        return AppAssets.strekLevelBadge7;
      case 8:
        return AppAssets.strekLevelBadge8;
      default:
        return AppAssets.strekLevelBadge1;
    }
  }

  // Get badge level for a given streak count
  // Returns the highest badge level unlocked, or 0 if no badge unlocked
  static int getBadgeLevelForStreak(int streakCount) {
    for (int i = badgeMilestones.length - 1; i >= 0; i--) {
      if (streakCount >= badgeMilestones[i]) {
        return i + 1; // Badge levels are 1-indexed
      }
    }
    return 0;
  }

  // Check if a new badge was just unlocked
  // Returns the badge level if unlocked, or null if no new badge
  static int? checkNewBadgeUnlocked(int currentStreak, List<int> unlockedBadges) {
    final newBadgeLevel = getBadgeLevelForStreak(currentStreak);
    
    if (newBadgeLevel > 0 && !unlockedBadges.contains(newBadgeLevel)) {
      return newBadgeLevel;
    }
    
    return null;
  }

  // Get all unlocked badges for a given streak count
  static List<int> getAllUnlockedBadges(int streakCount) {
    final List<int> unlocked = [];
    for (int i = 0; i < badgeMilestones.length; i++) {
      if (streakCount >= badgeMilestones[i]) {
        unlocked.add(i + 1);
      }
    }
    return unlocked;
  }

  // Get badge name/milestone description
  static String getBadgeDescription(int badgeLevel) {
    if (badgeLevel < 1 || badgeLevel > badgeMilestones.length) {
      return '';
    }
    final milestone = badgeMilestones[badgeLevel - 1];
    return '$milestone Day Streak';
  }
}

