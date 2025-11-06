import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:streaks/database/streaks_database.dart';
import 'package:streaks/services/auth_service.dart';
import 'package:streaks/res/assets.dart';

class LeaderboardService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'leaderboard';
  static const String _lastSyncKey = 'leaderboard_last_sync';
  static const String _lastUploadKey = 'leaderboard_last_upload';
  static const String _localDataKey = 'leaderboard_local_data';

  /// Calculate overall level based on completed streak days
  /// Level thresholds:
  /// - Level 1: 1-50 completed streak days
  /// - Level 2: 51-100 completed streak days
  /// - Level 3: 101-200 completed streak days
  /// - Level 4: 201-500 completed streak days
  /// - Level 5: 501+ completed streak days
  static int calculateLevel(int totalCompletedStreakDays) {
    if (totalCompletedStreakDays == 0) return 0; // No level if no completions
    if (totalCompletedStreakDays >= 501) return 5;
    if (totalCompletedStreakDays >= 201) return 4;
    if (totalCompletedStreakDays >= 101) return 3;
    if (totalCompletedStreakDays >= 51) return 2;
    return 1; // 1-50 completed streak days = Level 1
  }

  static String getBadgeAssetPath(int level) {
    switch (level) {
      case 1:
        return AppAssets.overallLevelBadge1;
      case 2:
        return AppAssets.overallLevelBadge2;
      case 3:
        return AppAssets.overallLevelBadge3;
      case 4:
        return AppAssets.overallLevelBadge4;
      case 5:
        return AppAssets.overallLevelBadge5;
      default:
        return AppAssets.overallLevelBadge1;
    }
  }

  /// Check if a date is an active day for a habit
  static bool _isActiveDayForHabit(Streak streak, DateTime date) {
    if (streak.selectedDays.isEmpty) return false;
    final dayIndex = date.weekday % 7; // 0 = Sunday, 1 = Monday, etc.
    return streak.selectedDays.contains(dayIndex);
  }

  /// Calculate completed streak days - days where ALL habits that are active on that day were completed
  /// This ignores inactive days (days that aren't scheduled for any habit)
  /// 
  /// Rules:
  /// - 1 habit: Day 1 completion = 1 completed streak day = Overall Level 1
  /// - 2+ habits: First day when ALL active habits complete together = 1 completed streak day = Overall Level 1
  /// - Inactive days don't count - if a habit isn't scheduled on a day, it doesn't need to complete
  /// 
  /// Example: Habit A (Mon-Fri), Habit B (Mon-Wed):
  ///   - Mon-Wed: Count if both completed (both are active)
  ///   - Thu-Fri: Don't count (B is inactive, so only A needs to complete, but we require ALL active habits)
  static int _calculateCompletedStreakDays(List<Streak> streaks) {
    if (streaks.isEmpty) return 0;

    // Find the earliest completion date across all habits
    DateTime? earliestDate;
    for (var streak in streaks) {
      if (streak.streakDates.isNotEmpty) {
        final sortedDates = List<DateTime>.from(streak.streakDates)..sort();
        final firstDate = sortedDates.first;
        if (earliestDate == null || firstDate.isBefore(earliestDate)) {
          earliestDate = firstDate;
        }
      }
    }

    if (earliestDate == null) return 0;

    // Get today's date (without time)
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final startDateOnly = DateTime(
      earliestDate.year,
      earliestDate.month,
      earliestDate.day,
    );

    // Create sets of completed dates for each habit for quick lookup
    final completedDatesByHabit = streaks.map((streak) {
      return streak.streakDates
          .map((d) => DateTime(d.year, d.month, d.day))
          .toSet();
    }).toList();

    // Count days where ALL habits that are active on that day were completed
    int completedStreakDays = 0;
    DateTime currentDate = startDateOnly;

    // Check every day from first completion to today
    while (!currentDate.isAfter(todayOnly)) {
      final dateOnly = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );

      // Check if at least one habit is active on this day
      bool hasActiveHabits = false;
      bool allActiveHabitsCompleted = true;

      for (int i = 0; i < streaks.length; i++) {
        final isActive = _isActiveDayForHabit(streaks[i], dateOnly);
        
        if (isActive) {
          hasActiveHabits = true;
          // If this habit is active on this day, it must be completed
          if (!completedDatesByHabit[i].contains(dateOnly)) {
            allActiveHabitsCompleted = false;
            break;
          }
        }
      }

      // Count if there are active habits on this day AND all active habits were completed
      if (hasActiveHabits && allActiveHabitsCompleted) {
        completedStreakDays++;
      }

      // Move to next day
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return completedStreakDays;
  }

  static Future<Map<String, dynamic>> calculateUserStats() async {
    final streaks = await StreaksDatabase.getAllStreaks();

    int totalStreaks = streaks.length;
    
    // Calculate completed streak days (days where ALL habits were completed)
    // This is the new metric for overall level
    int totalCompletedStreakDays = _calculateCompletedStreakDays(streaks);

    final level = calculateLevel(totalCompletedStreakDays);

    return {
      'totalStreaks': totalStreaks,
      'totalCompletedStreaks': totalCompletedStreakDays, // Now represents completed streak days
      'level': level,
    };
  }

  static Future<bool> shouldSyncFromFirebase() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncStr = prefs.getString(_lastSyncKey);

    if (lastSyncStr == null) return true;

    final lastSync = DateTime.parse(lastSyncStr);
    final now = DateTime.now();
    final difference = now.difference(lastSync);

    return difference.inHours >= 24;
  }

  static Future<bool> shouldUploadToFirebase() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUploadStr = prefs.getString(_lastUploadKey);

    if (lastUploadStr == null) return true;

    final lastUpload = DateTime.parse(lastUploadStr);
    final now = DateTime.now();
    final difference = now.difference(lastUpload);

    return difference.inHours >= 24;
  }

  static Future<void> updateLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  static Future<void> updateLastUploadTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUploadKey, DateTime.now().toIso8601String());
  }

  static Future<void> uploadUserData() async {
    if (!AuthService.isSignedIn) return;

    final shouldUpload = await shouldUploadToFirebase();
    if (!shouldUpload) return;

    try {
      final userId = AuthService.userId!;
      final stats = await calculateUserStats();

      // Check premium subscription status
      bool isPremium = false;
      try {
        final customerInfo = await Purchases.getCustomerInfo();
        isPremium = customerInfo.activeSubscriptions.isNotEmpty;
      } catch (e) {
        debugPrint('Error checking premium status: $e');
        // Default to false if check fails
      }

      final userData = {
        'userId': userId,
        'displayName': AuthService.displayName ?? 'Anonymous',
        'email': AuthService.email ?? '',
        'photoUrl': AuthService.photoUrl ?? '',
        'totalStreaks': stats['totalStreaks'],
        'totalCompletedStreaks': stats['totalCompletedStreaks'],
        'level': stats['level'],
        'isPremium': isPremium,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      await _firestore.collection(_collectionName).doc(userId).set(
            userData,
            SetOptions(merge: true),
          );

      await updateLastUploadTime();
    } catch (e) {
      debugPrint('Error uploading user data: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchLeaderboard() async {
    if (!AuthService.isSignedIn) return [];

    final shouldSync = await shouldSyncFromFirebase();

    if (!shouldSync) {
      final prefs = await SharedPreferences.getInstance();
      final cachedDataStr = prefs.getString(_localDataKey);
      if (cachedDataStr != null) {
        try {
          final List<dynamic> cachedList = jsonDecode(cachedDataStr);
          return cachedList.map((e) => e as Map<String, dynamic>).toList();
        } catch (e) {
          debugPrint('Error parsing cached data: $e');
        }
      }
    }

    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('totalCompletedStreaks', descending: true)
          .orderBy('totalStreaks', descending: true)
          .limit(100)
          .get();

      final List<Map<String, dynamic>> leaderboard = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        leaderboard.add({
          'userId': doc.id,
          'displayName': data['displayName'] ?? 'Anonymous',
          'email': data['email'] ?? '',
          'photoUrl': data['photoUrl'] ?? '',
          'totalStreaks': data['totalStreaks'] ?? 0,
          'totalCompletedStreaks': data['totalCompletedStreaks'] ?? 0,
          'level': data['level'] ?? 1,
          'rank': leaderboard.length + 1,
        });
      }

      leaderboard.sort((a, b) {
        final completedA = a['totalCompletedStreaks'] as int;
        final completedB = b['totalCompletedStreaks'] as int;

        if (completedA != completedB) {
          return completedB.compareTo(completedA);
        }

        final totalA = a['totalStreaks'] as int;
        final totalB = b['totalStreaks'] as int;
        return totalB.compareTo(totalA);
      });

      for (int i = 0; i < leaderboard.length; i++) {
        leaderboard[i]['rank'] = i + 1;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localDataKey, jsonEncode(leaderboard));
      await updateLastSyncTime();

      return leaderboard;
    } catch (e) {
      debugPrint('Error fetching leaderboard: $e');

      final prefs = await SharedPreferences.getInstance();
      final cachedDataStr = prefs.getString(_localDataKey);
      if (cachedDataStr != null) {
        try {
          final List<dynamic> cachedList = jsonDecode(cachedDataStr);
          return cachedList.map((e) => e as Map<String, dynamic>).toList();
        } catch (e) {
          debugPrint('Error parsing cached data: $e');
        }
      }

      return [];
    }
  }

  static Future<int?> getCurrentUserRank() async {
    if (!AuthService.isSignedIn) return null;

    final leaderboard = await fetchLeaderboard();
    final userId = AuthService.userId;

    if (userId == null) return null;

    final userEntry = leaderboard.firstWhere(
      (entry) => entry['userId'] == userId,
      orElse: () => {},
    );

    if (userEntry.isEmpty) return null;
    return userEntry['rank'] as int;
  }

  static Future<void> forceSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSyncKey);
    await prefs.remove(_lastUploadKey);
    await uploadUserData();
  }
}
