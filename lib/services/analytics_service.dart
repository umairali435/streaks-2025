import 'package:streaks/database/streaks_database.dart';
import 'dart:math' as math;

class AnalyticsService {
  static Future<List<Streak>> getAllStreaks() async {
    return await StreaksDatabase.getAllStreaks();
  }

  // ========== 1. Overall Summary Metrics ==========

  static Future<Map<String, dynamic>> getOverallSummary() async {
    final streaks = await getAllStreaks();
    
    if (streaks.isEmpty) {
      return {
        'totalHabits': 0,
        'activeHabitsThisWeek': 0,
        'totalCompletions': 0,
        'averageStreakLength': 0.0,
        'longestStreak': 0,
        'overallCompletionRate': 0.0,
        'consistencyScore': 0.0,
      };
    }

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    int totalHabits = streaks.length;
    int activeHabitsThisWeek = 0;
    int totalCompletions = 0;
    List<int> streakLengths = [];
    int longestStreak = 0;
    int totalScheduledDays = 0;
    int totalCompletedDays = 0;

    for (var streak in streaks) {
      // Check if active this week
      final hasActivityThisWeek = streak.streakDates.any((date) {
        return date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            date.isBefore(weekEnd.add(const Duration(days: 1)));
      });
      if (hasActivityThisWeek) activeHabitsThisWeek++;

      // Total completions
      totalCompletions += streak.streakDates.length;

      // Calculate current streak
      final currentStreak = _calculateCurrentStreak(streak);
      streakLengths.add(currentStreak);
      longestStreak = math.max(longestStreak, currentStreak);

      // Calculate scheduled vs completed
      final scheduled = _getScheduledDaysCount(streak, now);
      totalScheduledDays += scheduled;
      totalCompletedDays += streak.streakDates.length;
    }

    final averageStreakLength = streakLengths.isEmpty
        ? 0.0
        : streakLengths.reduce((a, b) => a + b) / streakLengths.length;

    final overallCompletionRate = totalScheduledDays > 0
        ? (totalCompletedDays / totalScheduledDays) * 100
        : 0.0;

    // Consistency Score (0-100): blend of streak performance, regularity, and diversity
    final consistencyScore = _calculateConsistencyScore(
      streaks,
      averageStreakLength,
      overallCompletionRate,
      longestStreak,
    );

    return {
      'totalHabits': totalHabits,
      'activeHabitsThisWeek': activeHabitsThisWeek,
      'totalCompletions': totalCompletions,
      'averageStreakLength': averageStreakLength,
      'longestStreak': longestStreak,
      'overallCompletionRate': overallCompletionRate,
      'consistencyScore': consistencyScore,
    };
  }

  // ========== 2. Time-Based Progress & Trends ==========

  static Future<Map<String, dynamic>> getTimeBasedProgress() async {
    final streaks = await getAllStreaks();
    final now = DateTime.now();
    
    // Daily completions (last 30 days)
    Map<DateTime, int> dailyCompletions = {};
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateOnly = DateTime(date.year, date.month, date.day);
      dailyCompletions[dateOnly] = 0;
    }

    // Weekly completions (last 12 weeks)
    Map<DateTime, int> weeklyCompletions = {};
    for (int i = 11; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: i * 7));
      final weekStartOnly = DateTime(weekStart.year, weekStart.month, weekStart.day);
      weeklyCompletions[weekStartOnly] = 0;
    }

    for (var streak in streaks) {
      for (var date in streak.streakDates) {
        final dateOnly = DateTime(date.year, date.month, date.day);
        if (dailyCompletions.containsKey(dateOnly)) {
          dailyCompletions[dateOnly] = (dailyCompletions[dateOnly] ?? 0) + 1;
        }

        // Find which week this date belongs to
        final weekStart = date.subtract(Duration(days: date.weekday - 1));
        final weekStartOnly = DateTime(weekStart.year, weekStart.month, weekStart.day);
        if (weeklyCompletions.containsKey(weekStartOnly)) {
          weeklyCompletions[weekStartOnly] = (weeklyCompletions[weekStartOnly] ?? 0) + 1;
        }
      }
    }

    // Rolling 7-day success rate
    final rolling7DayRate = _calculateRolling7DaySuccessRate(streaks, now);

    // Most active day of week
    final mostActiveDay = _getMostActiveDayOfWeek(streaks);

    // Longest continuous active period
    final longestActivePeriod = _getLongestContinuousActivePeriod(streaks);

    return {
      'dailyCompletions': dailyCompletions,
      'weeklyCompletions': weeklyCompletions,
      'rolling7DaySuccessRate': rolling7DayRate,
      'mostActiveDay': mostActiveDay,
      'longestActivePeriod': longestActivePeriod,
    };
  }

  // ========== 3. Behavior & Timing Patterns ==========

  static Future<Map<String, dynamic>> getBehaviorPatterns() async {
    final streaks = await getAllStreaks();
    
    Map<int, int> weekdayCompletions = {};
    for (int i = 0; i < 7; i++) {
      weekdayCompletions[i] = 0;
    }

    int morningCompletions = 0;
    int eveningCompletions = 0;
    List<int> completionHours = [];

    for (var streak in streaks) {
      for (var date in streak.streakDates) {
        final weekday = date.weekday % 7; // 0 = Sunday, 6 = Saturday
        weekdayCompletions[weekday] = (weekdayCompletions[weekday] ?? 0) + 1;

        // Estimate completion time from reminder time (simplified)
        final reminderHour = streak.notificationHour;
        if (reminderHour < 12) {
          morningCompletions++;
        } else {
          eveningCompletions++;
        }
        completionHours.add(reminderHour);
      }
    }

    final sortedWeekdays = weekdayCompletions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final mostConsistentDay = sortedWeekdays.first.key;
    final leastConsistentDay = sortedWeekdays.last.key;

    final avgCompletionHour = completionHours.isEmpty
        ? 12
        : (completionHours.reduce((a, b) => a + b) / completionHours.length).round();

    return {
      'mostConsistentWeekday': mostConsistentDay,
      'leastConsistentWeekday': leastConsistentDay,
      'weekdayCompletions': weekdayCompletions,
      'morningVsEveningRatio': {
        'morning': morningCompletions,
        'evening': eveningCompletions,
        'ratio': morningCompletions > 0
            ? (eveningCompletions / morningCompletions)
            : 0.0,
      },
      'averageCompletionHour': avgCompletionHour,
    };
  }

  // ========== 4. Habit Comparison & Ranking ==========

  static Future<Map<String, dynamic>> getHabitRankings() async {
    final streaks = await getAllStreaks();
    
    if (streaks.isEmpty) {
      return {
        'byCompletions': [],
        'byStreak': [],
        'byConsistency': [],
        'top3': [],
        'bottom3': [],
      };
    }

    List<Map<String, dynamic>> rankedByCompletions = [];
    List<Map<String, dynamic>> rankedByStreak = [];
    List<Map<String, dynamic>> rankedByConsistency = [];
    List<Map<String, dynamic>> compositeRanking = [];

    // Calculate max values for normalization
    int maxCompletions = 0;
    int maxStreak = 0;
    double maxConsistency = 0.0;

    for (var streak in streaks) {
      final currentStreak = _calculateCurrentStreak(streak);
      final totalCompletions = streak.streakDates.length;
      final consistency = _calculateHabitConsistency(streak);

      maxCompletions = math.max(maxCompletions, totalCompletions);
      maxStreak = math.max(maxStreak, currentStreak);
      maxConsistency = math.max(maxConsistency, consistency);
    }

    // Normalize values to avoid division by zero
    final normalizedMaxCompletions = maxCompletions > 0 ? maxCompletions : 1;
    final normalizedMaxStreak = maxStreak > 0 ? maxStreak : 1;
    final normalizedMaxConsistency = maxConsistency > 0 ? maxConsistency : 1;

    for (var streak in streaks) {
      final currentStreak = _calculateCurrentStreak(streak);
      final totalCompletions = streak.streakDates.length;
      final consistency = _calculateHabitConsistency(streak);

      // Calculate composite score (weighted combination)
      // Weights: 40% completions, 30% streak, 30% consistency
      final normalizedCompletions = (totalCompletions / normalizedMaxCompletions) * 100;
      final normalizedStreak = (currentStreak / normalizedMaxStreak) * 100;
      final normalizedConsistency = (consistency / normalizedMaxConsistency) * 100;
      
      final compositeScore = (normalizedCompletions * 0.4) + 
                           (normalizedStreak * 0.3) + 
                           (normalizedConsistency * 0.3);

      rankedByCompletions.add({
        'streak': streak,
        'value': totalCompletions,
        'type': 'completions',
      });

      rankedByStreak.add({
        'streak': streak,
        'value': currentStreak,
        'type': 'streak',
      });

      rankedByConsistency.add({
        'streak': streak,
        'value': consistency,
        'type': 'consistency',
      });

      compositeRanking.add({
        'streak': streak,
        'score': compositeScore,
        'completions': totalCompletions,
        'currentStreak': currentStreak,
        'consistency': consistency,
      });
    }

    rankedByCompletions.sort((a, b) => b['value'].compareTo(a['value']));
    rankedByStreak.sort((a, b) => b['value'].compareTo(a['value']));
    rankedByConsistency.sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));
    compositeRanking.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    // Get top 3 and bottom 3 from composite ranking, ensuring no overlap
    final top3 = compositeRanking.take(3).toList();
    final top3StreakIds = top3.map((item) => (item['streak'] as Streak).id).toSet();
    
    // Get bottom 3, excluding top 3
    final bottom3 = compositeRanking
        .where((item) => !top3StreakIds.contains((item['streak'] as Streak).id))
        .take(3)
        .toList();

    // If we have fewer than 6 habits, only show bottom habits that are actually worse
    final finalBottom3 = bottom3.length >= 3 || streaks.length <= 3
        ? bottom3
        : compositeRanking.reversed.take(math.min(3, streaks.length - top3.length)).toList();

    return {
      'byCompletions': rankedByCompletions,
      'byStreak': rankedByStreak,
      'byConsistency': rankedByConsistency,
      'top3': top3,
      'bottom3': finalBottom3,
    };
  }

  // ========== 5. Consistency & Gaps ==========

  static Future<Map<String, dynamic>> getConsistencyGaps() async {
    final streaks = await getAllStreaks();
    
    List<int> allGaps = [];
    int totalMissedDays = 0;
    List<Streak> inactiveHabits = [];

    final now = DateTime.now();

    for (var streak in streaks) {
      if (streak.streakDates.isEmpty) continue;

      final sortedDates = List<DateTime>.from(streak.streakDates)..sort();
      
      // Calculate gaps between completions
      for (int i = 1; i < sortedDates.length; i++) {
        final gap = sortedDates[i].difference(sortedDates[i - 1]).inDays - 1;
        if (gap > 0) {
          allGaps.add(gap);
        }
      }

      // Calculate missed days
      final scheduled = _getScheduledDaysCount(streak, now);
      totalMissedDays += scheduled - streak.streakDates.length;

      // Check inactivity (no completion in last 7 days)
      if (streak.streakDates.isNotEmpty) {
        final lastCompletion = sortedDates.last;
        final daysSinceLastCompletion = now.difference(lastCompletion).inDays;
        if (daysSinceLastCompletion > 7) {
          inactiveHabits.add(streak);
        }
      }
    }

    final avgGap = allGaps.isEmpty
        ? 0.0
        : allGaps.reduce((a, b) => a + b) / allGaps.length;

    final mostCommonGap = allGaps.isEmpty
        ? 0
        : _getMostCommonValue(allGaps);

    return {
      'averageGap': avgGap,
      'mostCommonGap': mostCommonGap,
      'totalMissedDays': totalMissedDays,
      'inactiveHabits': inactiveHabits,
    };
  }

  // ========== 6. Time Scheduling Insights ==========

  static Future<Map<String, dynamic>> getSchedulingInsights() async {
    final streaks = await getAllStreaks();
    
    Map<String, int> timeWindowCompletions = {
      'earlyMorning': 0, // 5-9
      'morning': 0,       // 9-12
      'afternoon': 0,     // 12-17
      'evening': 0,       // 17-21
      'night': 0,         // 21-5
    };

    for (var streak in streaks) {
      final hour = streak.notificationHour;
      if (hour >= 5 && hour < 9) {
        timeWindowCompletions['earlyMorning'] = (timeWindowCompletions['earlyMorning'] ?? 0) + streak.streakDates.length;
      } else if (hour >= 9 && hour < 12) {
        timeWindowCompletions['morning'] = (timeWindowCompletions['morning'] ?? 0) + streak.streakDates.length;
      } else if (hour >= 12 && hour < 17) {
        timeWindowCompletions['afternoon'] = (timeWindowCompletions['afternoon'] ?? 0) + streak.streakDates.length;
      } else if (hour >= 17 && hour < 21) {
        timeWindowCompletions['evening'] = (timeWindowCompletions['evening'] ?? 0) + streak.streakDates.length;
      } else {
        timeWindowCompletions['night'] = (timeWindowCompletions['night'] ?? 0) + streak.streakDates.length;
      }
    }

    final sortedWindows = timeWindowCompletions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final bestWindow = sortedWindows.first.key;

    return {
      'timeWindowCompletions': timeWindowCompletions,
      'bestPerformingWindow': bestWindow,
    };
  }

  // ========== 7. Weekly & Monthly Summaries ==========

  static Future<Map<String, dynamic>> getWeeklyMonthlySummaries() async {
    final streaks = await getAllStreaks();
    final now = DateTime.now();
    
    Map<String, int> weeklyTotals = {};
    Map<String, int> monthlyTotals = {};

    for (int i = 11; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: i * 7));
      final weekKey = '${weekStart.year}-W${_getWeekNumber(weekStart)}';
      weeklyTotals[weekKey] = 0;
    }

    for (int i = 11; i >= 0; i--) {
      final monthStart = DateTime(now.year, now.month - i, 1);
      final monthKey = '${monthStart.year}-${monthStart.month.toString().padLeft(2, '0')}';
      monthlyTotals[monthKey] = 0;
    }

    for (var streak in streaks) {
      for (var date in streak.streakDates) {
        // Weekly
        final weekStart = date.subtract(Duration(days: date.weekday - 1));
        final weekKey = '${weekStart.year}-W${_getWeekNumber(weekStart)}';
        if (weeklyTotals.containsKey(weekKey)) {
          weeklyTotals[weekKey] = (weeklyTotals[weekKey] ?? 0) + 1;
        }

        // Monthly
        final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        if (monthlyTotals.containsKey(monthKey)) {
          monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + 1;
        }
      }
    }

    final bestWeek = weeklyTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
    final bestMonth = monthlyTotals.entries.reduce((a, b) => a.value > b.value ? a : b);

    return {
      'weeklyTotals': weeklyTotals,
      'monthlyTotals': monthlyTotals,
      'bestWeek': bestWeek.key,
      'bestMonth': bestMonth.key,
    };
  }

  // ========== 8. AI-Generated Insights ==========

  static Future<List<String>> generateInsights() async {
    final streaks = await getAllStreaks();
    if (streaks.isEmpty) {
      return ['Create your first habit to start tracking your progress!'];
    }

    final summary = await getOverallSummary();
    final behavior = await getBehaviorPatterns();
    final rankings = await getHabitRankings();
    await getConsistencyGaps(); // Used for insights generation
    final scheduling = await getSchedulingInsights();

    List<String> insights = [];

    // Consistency insights
    if (summary['consistencyScore'] > 80) {
      insights.add('🌟 Outstanding! Your consistency score is ${summary['consistencyScore'].toStringAsFixed(0)}% - you\'re doing amazing!');
    } else if (summary['consistencyScore'] > 60) {
      insights.add('💪 Good progress! Your consistency score is ${summary['consistencyScore'].toStringAsFixed(0)}% - keep it up!');
    }

    // Day of week insights
    final mostConsistentDay = behavior['mostConsistentWeekday'] as int;
    final dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    insights.add('📅 You\'re most consistent on ${dayNames[mostConsistentDay]}s.');

    // Time window insights
    final bestWindow = scheduling['bestPerformingWindow'] as String;
    final windowNames = {
      'earlyMorning': 'Early Morning',
      'morning': 'Morning',
      'afternoon': 'Afternoon',
      'evening': 'Evening',
      'night': 'Night',
    };
    insights.add('⏰ ${windowNames[bestWindow]} habits have the highest success rate for you.');

    // Streak insights
    if (summary['longestStreak'] > 30) {
      insights.add('🔥 Incredible! Your longest streak is ${summary['longestStreak']} days - that\'s commitment!');
    } else if (summary['longestStreak'] > 7) {
      insights.add('✨ Your longest streak is ${summary['longestStreak']} days - great job!');
    }

    // Top habit insight
    if (rankings['top3'].isNotEmpty) {
      final topHabit = rankings['top3'][0]['streak'] as Streak;
      insights.add('🏆 "${topHabit.name}" is your top performing habit with ${rankings['top3'][0]['value']} completions.');
    }

    // Active period insight
    final timeProgress = await getTimeBasedProgress();
    final activePeriod = timeProgress['longestActivePeriod'] as int;
    if (activePeriod > 7) {
      insights.add('📈 You\'ve maintained activity for $activePeriod days straight - keep it up!');
    }

    return insights;
  }

  // ========== Helper Methods ==========

  /// Calculate current streak counting only active days, ignoring inactive days
  /// If habit is active Mon-Fri and user completes Mon, Tue, Wed, then next Mon,
  /// the streak should be 4 (not broken by inactive Thu-Fri)
  static int _calculateCurrentStreak(Streak streak) {
    if (streak.streakDates.isEmpty || streak.selectedDays.isEmpty) return 0;

    final sortedDates = List<DateTime>.from(streak.streakDates)
      ..sort((a, b) => b.compareTo(a));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Start from today or yesterday if today isn't completed
    DateTime? startDate = today;
    if (!sortedDates.any((d) => 
        DateTime(d.year, d.month, d.day) == today)) {
      final yesterday = today.subtract(const Duration(days: 1));
      if (sortedDates.any((d) => 
          DateTime(d.year, d.month, d.day) == yesterday)) {
        startDate = yesterday;
      } else {
        return 0; // No recent completion
      }
    }

    int streakCount = 0;
    DateTime currentCheckDate = startDate;
    int dateIndex = 0;

    // Go backwards from start date, counting only active days
    while (dateIndex < sortedDates.length && currentCheckDate.isAfter(
        sortedDates.last.subtract(const Duration(days: 1)))) {
      final currentDateOnly = DateTime(
        currentCheckDate.year,
        currentCheckDate.month,
        currentCheckDate.day,
      );

      // Check if this date is an active day for the habit
      final dayIndex = currentCheckDate.weekday % 7;
      final isActiveDay = streak.selectedDays.contains(dayIndex);

      if (isActiveDay) {
        // Check if this date was completed
        if (dateIndex < sortedDates.length) {
          final completedDate = sortedDates[dateIndex];
          final completedDateOnly = DateTime(
            completedDate.year,
            completedDate.month,
            completedDate.day,
          );

          if (completedDateOnly == currentDateOnly) {
            // This active day was completed - count it and move to next completed date
            streakCount++;
            dateIndex++;
          } else if (completedDateOnly.isAfter(currentDateOnly)) {
            // We've passed this date without completion - streak broken
            break;
          } else {
            // This completed date is before current check date - skip it
            dateIndex++;
            continue;
          }
        } else {
          // No more completions but we're checking an active day - streak broken
          break;
        }
      }

      // Move to previous day (regardless of whether it's active)
      currentCheckDate = currentCheckDate.subtract(const Duration(days: 1));
    }

    return streakCount;
  }

  static int _getScheduledDaysCount(Streak streak, DateTime until) {
    if (streak.selectedDays.isEmpty) return 0;

    int count = 0;
    final startDate = streak.streakDates.isNotEmpty
        ? streak.streakDates.reduce((a, b) => a.isBefore(b) ? a : b)
        : DateTime.now();

    DateTime current = startDate;
    while (current.isBefore(until) || current.isAtSameMomentAs(until)) {
      if (streak.selectedDays.contains(current.weekday % 7)) {
        count++;
      }
      current = current.add(const Duration(days: 1));
    }

    return count;
  }

  static double _calculateConsistencyScore(
    List<Streak> streaks,
    double avgStreak,
    double completionRate,
    int longestStreak,
  ) {
    if (streaks.isEmpty) return 0.0;

    // Normalize components (0-100 scale)
    final streakScore = math.min(avgStreak / 30.0 * 100, 100); // 30 days = 100%
    final completionScore = completionRate; // Already 0-100
    final longestStreakScore = math.min(longestStreak / 100.0 * 100, 100); // 100 days = 100%

    // Weighted combination
    return (streakScore * 0.4 + completionScore * 0.4 + longestStreakScore * 0.2);
  }

  static double _calculateRolling7DaySuccessRate(List<Streak> streaks, DateTime now) {
    int totalScheduled = 0;
    int totalCompleted = 0;

    for (var streak in streaks) {
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        if (streak.selectedDays.contains(date.weekday % 7)) {
          totalScheduled++;
          final dateOnly = DateTime(date.year, date.month, date.day);
          if (streak.streakDates.contains(dateOnly)) {
            totalCompleted++;
          }
        }
      }
    }

    return totalScheduled > 0 ? (totalCompleted / totalScheduled) * 100 : 0.0;
  }

  static int _getMostActiveDayOfWeek(List<Streak> streaks) {
    Map<int, int> dayCounts = {};
    for (int i = 0; i < 7; i++) {
      dayCounts[i] = 0;
    }

    for (var streak in streaks) {
      for (var date in streak.streakDates) {
        final weekday = date.weekday % 7;
        dayCounts[weekday] = (dayCounts[weekday] ?? 0) + 1;
      }
    }

    return dayCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  static int _getLongestContinuousActivePeriod(List<Streak> streaks) {
    if (streaks.isEmpty) return 0;

    final allDates = <DateTime>{};
    for (var streak in streaks) {
      for (var date in streak.streakDates) {
        allDates.add(DateTime(date.year, date.month, date.day));
      }
    }

    if (allDates.isEmpty) return 0;

    final sortedDates = allDates.toList()..sort();
    int maxPeriod = 1;
    int currentPeriod = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final diff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (diff == 1) {
        currentPeriod++;
        maxPeriod = math.max(maxPeriod, currentPeriod);
      } else {
        currentPeriod = 1;
      }
    }

    return maxPeriod;
  }

  static double _calculateHabitConsistency(Streak streak) {
    if (streak.streakDates.isEmpty) return 0.0;

    final now = DateTime.now();
    final scheduled = _getScheduledDaysCount(streak, now);
    final completed = streak.streakDates.length;

    return scheduled > 0 ? (completed / scheduled) * 100 : 0.0;
  }

  static int _getMostCommonValue(List<int> values) {
    if (values.isEmpty) return 0;

    Map<int, int> counts = {};
    for (var value in values) {
      counts[value] = (counts[value] ?? 0) + 1;
    }

    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  static int _getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final firstMonday = startOfYear.add(Duration(days: (8 - startOfYear.weekday) % 7));
    if (date.isBefore(firstMonday)) {
      return 1;
    }
    final weekNumber = ((date.difference(firstMonday).inDays) / 7).floor() + 1;
    return weekNumber;
  }
}

