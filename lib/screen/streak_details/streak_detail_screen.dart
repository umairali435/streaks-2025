import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:screenshot/screenshot.dart';
import 'package:streaks/bloc/streaks_bloc.dart';
import 'package:streaks/bloc/theme_bloc.dart';
import 'package:streaks/components/streak_stat_card.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/res/constants.dart';
import 'package:streaks/database/streaks_database.dart';
import 'package:streaks/screen/add_screen.dart';
import 'package:streaks/screen/streak_details/widgets/premium_overlay_widget.dart';
import 'package:streaks/services/screenshot_service.dart';
import 'package:streaks/services/badge_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:streaks/res/strings.dart';

class StreakDetailScreen extends StatefulWidget {
  final Streak streak;

  const StreakDetailScreen({super.key, required this.streak});

  @override
  State<StreakDetailScreen> createState() => _StreakDetailScreenState();
}

enum ChartFilter { weekly, monthly, yearly }

class _StreakDetailScreenState extends State<StreakDetailScreen> {
  int longestStreak = 0;
  int currentStreak = 0;
  double completionRate = 0.0;
  int totalCompleted = 0;
  ChartFilter selectedFilter = ChartFilter.weekly;

  int calculateLongestStreak(List<DateTime> streakDates) {
    if (streakDates.isEmpty) return 0;

    streakDates.sort();
    int longestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < streakDates.length; i++) {
      if (streakDates[i].difference(streakDates[i - 1]).inDays == 1) {
        currentStreak++;
      } else {
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
        currentStreak = 1;
      }
    }

    return currentStreak > longestStreak ? currentStreak : longestStreak;
  }

  /// Calculate current streak counting only active days, ignoring inactive days
  int calculateCurrentStreak(List<DateTime> streakDates) {
    if (streakDates.isEmpty || widget.streak.selectedDays.isEmpty) return 0;

    final sortedDates = List<DateTime>.from(streakDates)
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // Start from today or yesterday if today isn't completed
    DateTime? startDate = todayOnly;
    if (!sortedDates
        .any((d) => DateTime(d.year, d.month, d.day) == todayOnly)) {
      final yesterday = todayOnly.subtract(const Duration(days: 1));
      if (sortedDates
          .any((d) => DateTime(d.year, d.month, d.day) == yesterday)) {
        startDate = yesterday;
      } else {
        return 0; // No recent completion
      }
    }

    int streakCount = 0;
    DateTime currentCheckDate = startDate;
    int dateIndex = 0;

    // Go backwards from start date, counting only active days
    while (dateIndex < sortedDates.length &&
        currentCheckDate
            .isAfter(sortedDates.last.subtract(const Duration(days: 1)))) {
      final currentDateOnly = DateTime(
        currentCheckDate.year,
        currentCheckDate.month,
        currentCheckDate.day,
      );

      // Check if this date is an active day for the habit
      final dayIndex = currentCheckDate.weekday % 7;
      final isActiveDay = widget.streak.selectedDays.contains(dayIndex);

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

  double calculateCompletionRate(
      List<DateTime> streakDates, List<int> selectedDays) {
    if (streakDates.isEmpty) return 0.0;

    final sortedDates = List<DateTime>.from(streakDates)..sort();
    final startDate = sortedDates.first;
    final today = DateTime.now();
    final endDate = DateTime(today.year, today.month, today.day);

    final startDateOnly =
        DateTime(startDate.year, startDate.month, startDate.day);
    final totalDaysPassed = endDate.difference(startDateOnly).inDays + 1;

    final totalCompleted = streakDates.length;

    if (totalDaysPassed == 0) return 0.0;
    return (totalCompleted / totalDaysPassed) * 100;
  }

  Map<int, int> calculateCompletedDaysByWeekday(List<DateTime> streakDates) {
    final Map<int, int> dayCounts = {
      0: 0,
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 0,
      6: 0,
    };

    for (var date in streakDates) {
      int weekday = date.weekday;
      int dayIndex = weekday == 7 ? 0 : weekday;
      dayCounts[dayIndex] = (dayCounts[dayIndex] ?? 0) + 1;
    }

    return dayCounts;
  }

  Map<int, int> calculateMissedDaysByWeekday(
      List<DateTime> streakDates, List<int> selectedDays, ChartFilter filter) {
    if (selectedDays.isEmpty || streakDates.isEmpty) {
      return {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
    }

    final Map<int, int> missedCounts = {
      0: 0,
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 0,
      6: 0,
    };

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // Calculate filter start date
    DateTime filterStartDate;
    switch (filter) {
      case ChartFilter.weekly:
        filterStartDate = todayOnly.subtract(const Duration(days: 6));
        break;
      case ChartFilter.monthly:
        filterStartDate = todayOnly.subtract(const Duration(days: 30));
        break;
      case ChartFilter.yearly:
        filterStartDate = todayOnly.subtract(const Duration(days: 364));
        break;
    }

    // Find the actual first streak date
    final sortedStreakDates = List<DateTime>.from(streakDates)..sort();
    final firstStreakDate = sortedStreakDates.first;
    final firstStreakDateOnly = DateTime(
      firstStreakDate.year,
      firstStreakDate.month,
      firstStreakDate.day,
    );

    // Use the later of filter start date or first streak date
    // We should only count missed days from when the streak actually started
    final actualStartDate = filterStartDate.isBefore(firstStreakDateOnly)
        ? firstStreakDateOnly
        : filterStartDate;

    final startDateOnly = DateTime(
        actualStartDate.year, actualStartDate.month, actualStartDate.day);
    final completedDatesSet =
        streakDates.map((d) => DateTime(d.year, d.month, d.day)).toSet();

    // Only process dates from actual start date up to and including today
    DateTime currentDate = startDateOnly;

    while (true) {
      // Create date without time component for comparison
      final currentDateOnly =
          DateTime(currentDate.year, currentDate.month, currentDate.day);

      // Stop immediately if we've passed today (future dates)
      if (currentDateOnly.isAfter(todayOnly)) {
        break;
      }

      // Process this date (it's today or in the past)
      int weekday = currentDate.weekday;
      int dayIndex = weekday == 7 ? 0 : weekday;

      if (selectedDays.contains(dayIndex)) {
        // Only count as missed if it's not completed
        if (!completedDatesSet.contains(currentDateOnly)) {
          missedCounts[dayIndex] = (missedCounts[dayIndex] ?? 0) + 1;
        }
      }

      // Move to next day
      currentDate = currentDate.add(const Duration(days: 1));

      // Double-check: stop if next date would be in the future
      final nextDateOnly =
          DateTime(currentDate.year, currentDate.month, currentDate.day);
      if (nextDateOnly.isAfter(todayOnly)) {
        break;
      }
    }

    return missedCounts;
  }

  List<DateTime> getFilteredDates(
      List<DateTime> streakDates, ChartFilter filter) {
    if (streakDates.isEmpty) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime startDate;

    switch (filter) {
      case ChartFilter.weekly:
        // Last 7 days
        startDate = today.subtract(const Duration(days: 6));
        break;
      case ChartFilter.monthly:
        // Last 30 days
        startDate = today.subtract(const Duration(days: 30));
        break;
      case ChartFilter.yearly:
        // Last 365 days
        startDate = today.subtract(const Duration(days: 364));
        break;
    }

    return streakDates.where((date) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      return dateOnly.isAfter(startDate.subtract(const Duration(days: 1))) &&
          (dateOnly.isBefore(today) || dateOnly.isAtSameMomentAs(today));
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    // Calculate stats immediately for faster initial render
    _calculateStats();
  }

  void _calculateStats() {
    final longest = calculateLongestStreak(widget.streak.streakDates);
    final current = calculateCurrentStreak(widget.streak.streakDates);
    final completion = calculateCompletionRate(
      widget.streak.streakDates,
      widget.streak.selectedDays,
    );
    final total = widget.streak.streakDates.length;

    setState(() {
      longestStreak = longest;
      currentStreak = current;
      completionRate = completion;
      totalCompleted = total;
    });
  }

  @override
  void didUpdateWidget(StreakDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only recalculate if streak data actually changed
    if (oldWidget.streak.streakDates.length !=
            widget.streak.streakDates.length ||
        oldWidget.streak.id != widget.streak.id) {
      _calculateStats();
    }
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
            leading: IconButton(
              icon: Icon(
                LucideIcons.chevronLeft,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              widget.streak.name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w900,
                fontSize: 18.0,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  LucideIcons.edit,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddStrekScreen(
                        streak: widget.streak,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  LucideIcons.trash,
                ),
                onPressed: () async {
                  final dialogWidget = Platform.isAndroid
                      ? AlertDialog(
                          backgroundColor: AppColors.cardColorTheme(isDark),
                          title: Text(
                            "Delete Streak",
                            style: GoogleFonts.poppins(
                              color: AppColors.textColor(isDark),
                            ),
                          ),
                          content: Text(
                            "Are you sure you want to delete this streak?",
                            style: GoogleFonts.poppins(
                              color: AppColors.textColor(isDark),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "Cancel",
                                style: GoogleFonts.poppins(
                                  color: AppColors.greyColorTheme(isDark),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                await StreaksDatabase.deleteStreakById(
                                        widget.streak.id)
                                    .then((_) {
                                  context
                                      .read<StreaksBloc>()
                                      .add(LoadStreaks());
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                });
                              },
                              child: const Text(
                                "Delete",
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        )
                      : CupertinoAlertDialog(
                          title: const Text("Delete Streak"),
                          content: const Text(
                              "Are you sure you want to delete this streak?"),
                          actions: [
                            CupertinoDialogAction(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Cancel"),
                            ),
                            CupertinoDialogAction(
                              isDestructiveAction: true,
                              onPressed: () async {
                                await StreaksDatabase.deleteStreakById(
                                        widget.streak.id)
                                    .then((_) {
                                  context
                                      .read<StreaksBloc>()
                                      .add(LoadStreaks());
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                });
                              },
                              child: const Text("Delete"),
                            ),
                          ],
                        );
                  if (Platform.isAndroid) {
                    return showDialog(
                      context: context,
                      builder: (context) {
                        return dialogWidget;
                      },
                    );
                  } else {
                    return showCupertinoDialog(
                      context: context,
                      builder: (context) {
                        return dialogWidget;
                      },
                    );
                  }
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(AppConstants.sidePadding),
            child: ListView(
              cacheExtent: 500, // Cache more items for smoother scrolling
              children: [
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, themeState) {
                    final badgeIsDark =
                        themeState is ThemeLoaded ? themeState.isDark : true;
                    return _BadgeDisplayWidget(
                      streak: widget.streak,
                      currentStreak: currentStreak,
                      isDark: badgeIsDark,
                    );
                  },
                ),
                const Gap(20.0),
                Row(
                  children: [
                    StreakStatCard(
                      title: "Current Streak",
                      value: currentStreak.toString(),
                      isDark: isDark,
                    ),
                    const Gap(20.0),
                    StreakStatCard(
                      title: "Longest Streak",
                      value: longestStreak.toString(),
                      isDark: isDark,
                    ),
                  ],
                ),
                const Gap(20.0),
                Row(
                  children: [
                    StreakStatCard(
                      title: "Completion Rate",
                      value: completionRate.toStringAsFixed(1),
                      suffix: "%",
                      isDark: isDark,
                    ),
                    const Gap(20.0),
                    StreakStatCard(
                      title: "Total Completed",
                      value: totalCompleted.toString(),
                      isDark: isDark,
                    ),
                  ],
                ),
                const Gap(20.0),
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, themeState) {
                    final dotsIsDark =
                        themeState is ThemeLoaded ? themeState.isDark : true;
                    return PremiumLockedWidget(
                      child: _Last14DaysDotsWidget(
                          streak: widget.streak, isDark: dotsIsDark),
                    );
                  },
                ),
                const Gap(20.0),
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, themeState) {
                    final dotsIsDark =
                        themeState is ThemeLoaded ? themeState.isDark : true;
                    return StreaksDotsWidget(
                        streak: widget.streak, isDark: dotsIsDark);
                  },
                ),
                const Gap(20.0),
                PremiumLockedWidget(
                  child: Card(
                    color: AppColors.cardColorTheme(isDark),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadius),
                      side: BorderSide(color: AppColors.darkBorderColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: HeatMapCalendar(
                        flexible: true,
                        margin: const EdgeInsets.all(5.0),
                        colorMode: ColorMode.color,
                        showColorTip: false,
                        textColor: AppColors.textColor(isDark),
                        defaultColor:
                            AppColors.greyColorTheme(isDark).withAlpha(100),
                        weekFontSize: 12.0,
                        weekTextColor: AppColors.textColor(isDark),
                        datasets: widget.streak.streakDates.asMap().map(
                          (key, DateTime value) {
                            return MapEntry(
                              DateTime(value.year, value.month, value.day),
                              key + 1,
                            );
                          },
                        ),
                        colorsets: {
                          1: Color(widget.streak.colorCode),
                        },
                      ),
                    ),
                  ),
                ),
                const Gap(20.0),
                _CombinedChartsWidget(
                  isDark: isDark,
                  streak: widget.streak,
                  selectedFilter: selectedFilter,
                  onFilterChanged: (filter) {
                    setState(() {
                      selectedFilter = filter;
                    });
                  },
                  completedDays: calculateCompletedDaysByWeekday(
                    getFilteredDates(widget.streak.streakDates, selectedFilter),
                  ),
                  missedDays: calculateMissedDaysByWeekday(
                    getFilteredDates(widget.streak.streakDates, selectedFilter),
                    widget.streak.selectedDays,
                    selectedFilter,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CombinedChartsWidget extends StatelessWidget {
  final Streak streak;
  final ChartFilter selectedFilter;
  final Function(ChartFilter) onFilterChanged;
  final Map<int, int> completedDays;
  final Map<int, int> missedDays;
  final bool isDark;

  const _CombinedChartsWidget({
    required this.streak,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.completedDays,
    required this.missedDays,
    required this.isDark,
  });

  String _getFilterLabel(ChartFilter filter) {
    switch (filter) {
      case ChartFilter.weekly:
        return 'Weekly';
      case ChartFilter.monthly:
        return 'Monthly';
      case ChartFilter.yearly:
        return 'Yearly';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumLockedWidget(
      child: Card(
        color: AppColors.cardColorTheme(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          side: BorderSide(color: AppColors.darkBorderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Analytics',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textColor(isDark),
                    ),
                  ),
                  PopupMenuButton<ChartFilter>(
                    color: AppColors.cardColorTheme(isDark),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    onSelected: onFilterChanged,
                    itemBuilder: (context) => [
                      PopupMenuItem<ChartFilter>(
                        value: ChartFilter.weekly,
                        child: Text(
                          'Weekly',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: selectedFilter == ChartFilter.weekly
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selectedFilter == ChartFilter.weekly
                                ? Color(streak.colorCode)
                                : AppColors.textColor(isDark),
                          ),
                        ),
                      ),
                      PopupMenuItem<ChartFilter>(
                        value: ChartFilter.monthly,
                        child: Text(
                          'Monthly',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: selectedFilter == ChartFilter.monthly
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selectedFilter == ChartFilter.monthly
                                ? Color(streak.colorCode)
                                : AppColors.textColor(isDark),
                          ),
                        ),
                      ),
                      PopupMenuItem<ChartFilter>(
                        value: ChartFilter.yearly,
                        child: Text(
                          'Yearly',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: selectedFilter == ChartFilter.yearly
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selectedFilter == ChartFilter.yearly
                                ? Color(streak.colorCode)
                                : AppColors.textColor(isDark),
                          ),
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColorTheme(isDark),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Color(streak.colorCode),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getFilterLabel(selectedFilter),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(streak.colorCode),
                            ),
                          ),
                          const Gap(6),
                          Icon(
                            LucideIcons.chevronDown,
                            size: 16,
                            color: Color(streak.colorCode),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(24),
              // Most Completed Chart
              Text(
                'Most Completed',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor(isDark),
                ),
              ),
              const Gap(16),
              SizedBox(
                height: 150,
                child: _buildCompletedChart(),
              ),
              const Gap(32),
              // Most Missed Chart
              Text(
                'Most Missed',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor(isDark),
                ),
              ),
              const Gap(16),
              SizedBox(
                height: 150,
                child: _buildMissedChart(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedChart() {
    final maxValue = completedDays.values.isEmpty
        ? 1
        : completedDays.values.reduce((a, b) => a > b ? a : b);

    final barGroups = List.generate(7, (index) {
      final value = completedDays[index] ?? 0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: maxValue == 0 ? 0.0 : value.toDouble(),
            color: Color(streak.colorCode),
            width: 12,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
          ),
        ],
      );
    });

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue == 0 ? 1.0 : maxValue.toDouble() * 1.2,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.cardColorTheme(isDark),
            tooltipBorderRadius: BorderRadius.circular(8),
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final dayName = AppText.getDayOfWeek(group.x.toInt());
              return BarTooltipItem(
                '$dayName\n${rod.toY.toInt()}',
                GoogleFonts.poppins(
                  color: AppColors.textColor(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    AppText.weekDays[value.toInt()],
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textColor(isDark).withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              reservedSize: 0,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              reservedSize: 0,
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              reservedSize: 0,
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval:
              maxValue == 0 ? 1.0 : (maxValue / 4).ceilToDouble(),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.greyColorTheme(isDark).withValues(alpha: 0.1),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: barGroups,
      ),
    );
  }

  Widget _buildMissedChart() {
    final maxValue = missedDays.values.isEmpty
        ? 1
        : missedDays.values.reduce((a, b) => a > b ? a : b);

    final barGroups = List.generate(7, (index) {
      final value = missedDays[index] ?? 0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: maxValue == 0 ? 0.0 : value.toDouble(),
            color: Colors.red.withValues(alpha: 0.7),
            width: 12,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
          ),
        ],
      );
    });

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue == 0 ? 1.0 : maxValue.toDouble() * 1.2,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.cardColorTheme(isDark),
            tooltipBorderRadius: BorderRadius.circular(8),
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final dayName = AppText.getDayOfWeek(group.x.toInt());
              return BarTooltipItem(
                '$dayName\n${rod.toY.toInt()}',
                GoogleFonts.poppins(
                  color: AppColors.textColor(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    AppText.weekDays[value.toInt()],
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textColor(isDark).withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              reservedSize: 0,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              reservedSize: 0,
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              reservedSize: 0,
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval:
              maxValue == 0 ? 1.0 : (maxValue / 4).ceilToDouble(),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.greyColorTheme(isDark).withValues(alpha: 0.1),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: barGroups,
      ),
    );
  }
}

class StreaksDotsWidget extends StatefulWidget {
  final Streak streak;
  final bool isDark;
  const StreaksDotsWidget(
      {super.key, required this.streak, required this.isDark});

  @override
  State<StreaksDotsWidget> createState() => _StreaksDotsWidgetState();
}

class _StreaksDotsWidgetState extends State<StreaksDotsWidget> {
  final screenshotService = ScreenshotService();
  final ScrollController _scrollController = ScrollController();
  List<DateTime> allDates = [];
  Set<DateTime>? _streakDatesSet; // Cache the set for O(1) lookups

  List<DateTime> getRolling365Days() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final startDate = today.subtract(const Duration(days: 370));

    return List.generate(
      371,
      (index) => startDate.add(Duration(days: index)),
    );
  }

  @override
  void initState() {
    super.initState();
    // Calculate dates lazily - don't setState immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateDates();
      }
    });
  }

  void _updateDates() {
    allDates = getRolling365Days().reversed.toList();
    // Pre-compute the set once for efficient lookups
    _streakDatesSet = widget.streak.streakDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(StreaksDotsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if streak actually changed
    if (oldWidget.streak.id != widget.streak.id ||
        oldWidget.streak.streakDates.length !=
            widget.streak.streakDates.length) {
      _updateDates();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streaksDots = Screenshot(
      controller: screenshotService.controller,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardColorTheme(widget.isDark),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: AppColors.darkBorderColor),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(10.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.streak.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor(widget.isDark),
                          fontSize: 18.0,
                        ),
                      ),
                      Text(
                        widget.streak.selectedDays.length == 7
                            ? "Everyday"
                            : "${widget.streak.selectedDays.length} days per week",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor(widget.isDark),
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(5.0),
            Divider(
              color: Color(0xFFEFEFEF).withAlpha(100),
              thickness: 1.0,
            ),
            const Gap(10.0),
            SizedBox(
              height: 120.0,
              width: double.infinity,
              child: allDates.isEmpty
                  ? const SizedBox.shrink()
                  : GridView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      reverse: false,
                      cacheExtent:
                          200, // Cache more items for smoother scrolling
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1.0,
                        mainAxisSpacing: 4.0,
                        crossAxisSpacing: 4.0,
                      ),
                      itemCount: allDates.length,
                      itemBuilder: (context, index) {
                        // Pre-compute date comparison for better performance
                        final date = allDates[index];
                        final dateOnly =
                            DateTime(date.year, date.month, date.day);

                        // Use cached Set for O(1) lookup
                        final isStreakDay =
                            _streakDatesSet?.contains(dateOnly) ?? false;

                        return Container(
                          margin: const EdgeInsets.all(1.0),
                          decoration: BoxDecoration(
                            color: isStreakDay
                                ? Color(widget.streak.colorCode)
                                : AppColors.greyColorTheme(widget.isDark)
                                    .withAlpha(100),
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
    final streaksDotsActions = Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: screenshotService.captureAndSaveToGallery,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: AppColors.cardColorTheme(widget.isDark),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.download,
                    color: AppColors.textColor(widget.isDark),
                    size: 18.0,
                  ),
                  Gap(10.0),
                  Text(
                    "Download",
                    style: GoogleFonts.poppins(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor(widget.isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Gap(20.0),
        Expanded(
          child: InkWell(
            onTap: screenshotService.captureAndShare,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: AppColors.cardColorTheme(widget.isDark),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.share2,
                    color: AppColors.textColor(widget.isDark),
                    size: 18.0,
                  ),
                  Gap(10.0),
                  Text(
                    "Share",
                    style: GoogleFonts.poppins(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor(widget.isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
    return PremiumLockedWidget(
      child: Column(
        children: [
          streaksDots,
          Gap(10.0),
          streaksDotsActions,
        ],
      ),
    );
  }
}

class _Last14DaysDotsWidget extends StatelessWidget {
  final Streak streak;
  final bool isDark;

  const _Last14DaysDotsWidget({
    required this.streak,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Get the last 14 days (from today going back 13 days)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last14Days = List.generate(14, (index) {
      return today.subtract(Duration(days: 13 - index));
    });

    // Create a Set of completed dates for efficient lookup
    final completedDatesSet =
        streak.streakDates.map((d) => DateTime(d.year, d.month, d.day)).toSet();

    // Check which days were completed
    final completionData = last14Days.map((date) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      return completedDatesSet.contains(dateOnly);
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColorTheme(isDark),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.darkBorderColor),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last 14 Days',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: AppColors.textColor(isDark),
              fontSize: 18.0,
            ),
          ),
          const Gap(16.0),
          LayoutBuilder(
            builder: (context, constraints) {
              const int totalDots = 14;
              const double spacing = 4; // space between dots
              final double availableWidth = constraints.maxWidth;
              final double dotSize =
                  (availableWidth - (spacing * (totalDots - 1))) / totalDots;

              return Row(
                children: List.generate(totalDots, (index) {
                  final isCompleted = completionData[index];
                  return Container(
                    width: dotSize,
                    height: dotSize,
                    margin: EdgeInsets.only(
                        right: index == totalDots - 1 ? 0 : spacing),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Color(streak.colorCode)
                          : AppColors.greyColorTheme(isDark).withAlpha(100),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BadgeDisplayWidget extends StatelessWidget {
  final Streak streak;
  final int currentStreak;
  final bool isDark;

  const _BadgeDisplayWidget({
    required this.streak,
    required this.currentStreak,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Get the current badge level based on consecutive streak days
    final currentBadgeLevel =
        BadgeService.getBadgeLevelForStreak(currentStreak);

    // If no badge unlocked yet (streak is 0)
    if (currentBadgeLevel == 0 || currentStreak == 0) {
      return Card(
        color: AppColors.cardColorTheme(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          side: BorderSide(color: AppColors.darkBorderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Badge',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor(isDark),
                ),
              ),
              const Gap(16.0),
              Center(
                child: Column(
                  children: [
                    Text(
                      'No badge yet',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            AppColors.textColor(isDark).withValues(alpha: 0.9),
                      ),
                    ),
                    const Gap(8.0),
                    Text(
                      'Complete your first day to unlock a badge!',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color:
                            AppColors.textColor(isDark).withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final badgeDescription =
        BadgeService.getBadgeDescription(currentBadgeLevel);
    final nextMilestone = _getNextBadgeMilestone(currentStreak);
    final daysUntilNext =
        nextMilestone != null ? nextMilestone - currentStreak : null;

    return Card(
      color: AppColors.cardColorTheme(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        side: BorderSide(color: AppColors.darkBorderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Badge',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textColor(isDark),
              ),
            ),
            const Gap(16.0),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(streak.colorCode),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(streak.colorCode).withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        BadgeService.getBadgeAssetPath(currentBadgeLevel),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const Gap(16.0),
                  Text(
                    badgeDescription,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(streak.colorCode),
                    ),
                  ),
                  const Gap(8.0),
                  Text(
                    'Level $currentBadgeLevel',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor(isDark).withValues(alpha: 0.8),
                    ),
                  ),
                  const Gap(8.0),
                  Text(
                    '$currentStreak consecutive day${currentStreak != 1 ? 's' : ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textColor(isDark).withValues(alpha: 0.7),
                    ),
                  ),
                  if (daysUntilNext != null && daysUntilNext > 0) ...[
                    const Gap(12.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColorTheme(isDark),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color(streak.colorCode).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '$daysUntilNext day${daysUntilNext != 1 ? 's' : ''} until next badge',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textColor(isDark)
                              .withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int? _getNextBadgeMilestone(int currentStreak) {
    final milestones = BadgeService.badgeMilestones;
    for (final milestone in milestones) {
      if (currentStreak < milestone) {
        return milestone;
      }
    }
    return null; // Reached all milestones
  }
}
