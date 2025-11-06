import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:streaks/bloc/theme_bloc.dart';
import 'package:streaks/database/streaks_database.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/res/constants.dart';
import 'package:streaks/services/analytics_service.dart';
import 'package:streaks/screen/streak_details/widgets/premium_overlay_widget.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => ReportScreenState();
}

class ReportScreenState extends State<ReportScreen> {
  Map<String, dynamic>? _overallSummary;
  Map<String, dynamic>? _timeProgress;
  Map<String, dynamic>? _behaviorPatterns;
  Map<String, dynamic>? _habitRankings;
  Map<String, dynamic>? _consistencyGaps;
  Map<String, dynamic>? _schedulingInsights;
  Map<String, dynamic>? _weeklyMonthlySummaries;
  List<String>? _insights;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    final summary = await AnalyticsService.getOverallSummary();
    final timeProgress = await AnalyticsService.getTimeBasedProgress();
    final behavior = await AnalyticsService.getBehaviorPatterns();
    final rankings = await AnalyticsService.getHabitRankings();
    final gaps = await AnalyticsService.getConsistencyGaps();
    final scheduling = await AnalyticsService.getSchedulingInsights();
    final weeklyMonthly = await AnalyticsService.getWeeklyMonthlySummaries();
    final insights = await AnalyticsService.generateInsights();

    setState(() {
      _overallSummary = summary;
      _timeProgress = timeProgress;
      _behaviorPatterns = behavior;
      _habitRankings = rankings;
      _consistencyGaps = gaps;
      _schedulingInsights = scheduling;
      _weeklyMonthlySummaries = weeklyMonthly;
      _insights = insights;
      _isLoading = false;
    });
  }

  // Public method to reload analytics data (called when screen becomes visible)
  void reloadData() {
    _loadAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState is ThemeLoaded ? themeState.isDark : true;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor(isDark),
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            title: Text(
              "Analytics & Insights",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w900,
                fontSize: 18.0,
                color: AppColors.darkBackgroundColor,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  LucideIcons.refreshCw,
                  color: AppColors.darkBackgroundColor,
                ),
                onPressed: _loadAnalytics,
              ),
            ],
          ),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAnalytics,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Overall Summary Metrics
                        _buildOverallSummarySection(isDark),
                        const Gap(24),

                        // 2. Time-Based Progress & Trends
                        PremiumLockedWidget(
                          child: _buildTimeProgressSection(isDark),
                        ),
                        const Gap(24),

                        // 3. Behavior & Timing Patterns
                        PremiumLockedWidget(
                          child: _buildBehaviorPatternsSection(isDark),
                        ),
                        const Gap(24),

                        // 4. Habit Comparison & Ranking
                        PremiumLockedWidget(
                          child: _buildHabitRankingSection(isDark),
                        ),
                        const Gap(24),

                        // 5. Consistency & Gaps
                        PremiumLockedWidget(
                          child: _buildConsistencyGapsSection(isDark),
                        ),
                        const Gap(24),

                        // 6. Time Scheduling Insights
                        PremiumLockedWidget(
                          child: _buildSchedulingInsightsSection(isDark),
                        ),
                        const Gap(24),

                        // 7. Weekly & Monthly Summaries
                        PremiumLockedWidget(
                          child: _buildWeeklyMonthlySection(isDark),
                        ),
                        const Gap(24),

                        // 8. AI-Generated Insights
                        PremiumLockedWidget(
                          child: _buildInsightsSection(isDark),
                        ),
                        const Gap(24),

                        // 9. Achievements & Engagement
                        PremiumLockedWidget(
                          child: _buildAchievementsSection(isDark),
                        ),
                        const Gap(24),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  // ========== 1. Overall Summary Metrics ==========
  Widget _buildOverallSummarySection(bool isDark) {
    if (_overallSummary == null) return const SizedBox.shrink();

    return _buildSectionCard(
      isDark: isDark,
      title: "Overall Summary",
      icon: LucideIcons.activity,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  isDark: isDark,
                  label: "Habits",
                  value: _overallSummary!['totalHabits'].toString(),
                  icon: LucideIcons.target,
                ),
              ),
              const Gap(12),
              Expanded(
                child: _buildMetricCard(
                  isDark: isDark,
                  label: "This Week",
                  value: _overallSummary!['activeHabitsThisWeek'].toString(),
                  icon: LucideIcons.calendarCheck,
                ),
              ),
            ],
          ),
          const Gap(12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  isDark: isDark,
                  label: "Completions",
                  value: _overallSummary!['totalCompletions'].toString(),
                  icon: LucideIcons.checkCircle2,
                ),
              ),
              const Gap(12),
              Expanded(
                child: _buildMetricCard(
                  isDark: isDark,
                  label: "Avg Streak",
                  value: _overallSummary!['averageStreakLength']
                      .toStringAsFixed(1),
                  icon: LucideIcons.trendingUp,
                ),
              ),
            ],
          ),
          const Gap(12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  isDark: isDark,
                  label: "Longest Streak",
                  value: _overallSummary!['longestStreak'].toString(),
                  icon: LucideIcons.flame,
                ),
              ),
              const Gap(12),
              Expanded(
                child: _buildMetricCard(
                  isDark: isDark,
                  label: "Completion Rate",
                  value:
                      "${_overallSummary!['overallCompletionRate'].toStringAsFixed(1)}%",
                  icon: LucideIcons.percent,
                ),
              ),
            ],
          ),
          const Gap(12),
          _buildConsistencyScoreCard(isDark),
        ],
      ),
    );
  }

  Widget _buildConsistencyScoreCard(bool isDark) {
    final score = _overallSummary!['consistencyScore'] as double;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColorTheme(isDark),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Consistency Score",
                style: GoogleFonts.poppins(
                  color: AppColors.textColor(isDark),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                "${score.toStringAsFixed(0)}%",
                style: GoogleFonts.poppins(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          const Gap(8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: AppColors.secondaryColorTheme(isDark),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ========== 2. Time-Based Progress & Trends ==========
  Widget _buildTimeProgressSection(bool isDark) {
    if (_timeProgress == null) return const SizedBox.shrink();

    return _buildSectionCard(
      isDark: isDark,
      title: "Progress & Trends",
      icon: LucideIcons.trendingUp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Daily Completions Chart
          _buildDailyCompletionsChart(isDark),
          const Gap(20),

          // Rolling 7-day success rate
          _buildMetricCard(
            isDark: isDark,
            label: "7-Day Success Rate",
            value:
                "${_timeProgress!['rolling7DaySuccessRate'].toStringAsFixed(1)}%",
            icon: LucideIcons.target,
          ),
          const Gap(12),

          // Most active day
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  isDark: isDark,
                  label: "Most Active Day",
                  value: _getDayName(_timeProgress!['mostActiveDay'] as int),
                  icon: LucideIcons.calendar,
                ),
              ),
              const Gap(12),
              Expanded(
                child: _buildMetricCard(
                  isDark: isDark,
                  label: "Longest Active Period",
                  value: "${_timeProgress!['longestActivePeriod']} days",
                  icon: LucideIcons.zap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCompletionsChart(bool isDark) {
    final dailyCompletions =
        _timeProgress!['dailyCompletions'] as Map<DateTime, int>;
    final entries = dailyCompletions.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final maxValue = entries.isEmpty
        ? 1
        : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    final barGroups = entries.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: maxValue == 0 ? 0.0 : value.toDouble(),
            color: AppColors.primaryColor,
            width: 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Daily Completions (Last 30 Days)",
          style: GoogleFonts.poppins(
            color: AppColors.textColor(isDark),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const Gap(12),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxValue == 0 ? 1.0 : maxValue.toDouble() * 1.2,
              minY: 0,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppColors.cardColorTheme(isDark),
                  tooltipRoundedRadius: 8,
                  tooltipPadding: const EdgeInsets.all(8),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final date = entries[groupIndex].key;
                    return BarTooltipItem(
                      '${date.month}/${date.day}\n${rod.toY.toInt()}',
                      GoogleFonts.poppins(
                        color: AppColors.textColor(isDark),
                        fontSize: 12,
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
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() % 5 == 0 &&
                          value.toInt() < entries.length) {
                        final date = entries[value.toInt()].key;
                        return Text(
                          '${date.month}/${date.day}',
                          style: GoogleFonts.poppins(
                            color: AppColors.greyColorTheme(isDark),
                            fontSize: 10,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: GoogleFonts.poppins(
                          color: AppColors.greyColorTheme(isDark),
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.secondaryColorTheme(isDark),
                    strokeWidth: 0.5,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
            ),
          ),
        ),
      ],
    );
  }

  // ========== 3. Behavior & Timing Patterns ==========
  Widget _buildBehaviorPatternsSection(bool isDark) {
    if (_behaviorPatterns == null) return const SizedBox.shrink();

    return _buildSectionCard(
      isDark: isDark,
      title: "Behavior Patterns",
      icon: LucideIcons.brain,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekday completion chart
          _buildWeekdayChart(isDark),
          const Gap(20),

          // Morning vs Evening
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  isDark: isDark,
                  label: "Morning Completions",
                  value: _behaviorPatterns!['morningVsEveningRatio']['morning']
                      .toString(),
                  icon: LucideIcons.sunrise,
                ),
              ),
              const Gap(12),
              Expanded(
                child: _buildMetricCard(
                  isDark: isDark,
                  label: "Evening Completions",
                  value: _behaviorPatterns!['morningVsEveningRatio']['evening']
                      .toString(),
                  icon: LucideIcons.moon,
                ),
              ),
            ],
          ),
          const Gap(12),
          _buildMetricCard(
            isDark: isDark,
            label: "Average Completion Hour",
            value: "${_behaviorPatterns!['averageCompletionHour']}:00",
            icon: LucideIcons.clock,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayChart(bool isDark) {
    final weekdayCompletions =
        _behaviorPatterns!['weekdayCompletions'] as Map<int, int>;
    final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    final maxValue = weekdayCompletions.values.isEmpty
        ? 1
        : weekdayCompletions.values.reduce((a, b) => a > b ? a : b);

    final barGroups = List.generate(7, (index) {
      final value = weekdayCompletions[index] ?? 0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: maxValue == 0 ? 0.0 : value.toDouble(),
            color: AppColors.primaryColor,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Completions by Day of Week",
          style: GoogleFonts.poppins(
            color: AppColors.textColor(isDark),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const Gap(12),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxValue == 0 ? 1.0 : maxValue.toDouble() * 1.2,
              minY: 0,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppColors.cardColorTheme(isDark),
                  tooltipRoundedRadius: 8,
                  tooltipPadding: const EdgeInsets.all(8),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${dayNames[groupIndex]}\n${rod.toY.toInt()}',
                      GoogleFonts.poppins(
                        color: AppColors.textColor(isDark),
                        fontSize: 12,
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
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < 7) {
                        return Text(
                          dayNames[value.toInt()],
                          style: GoogleFonts.poppins(
                            color: AppColors.greyColorTheme(isDark),
                            fontSize: 10,
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: GoogleFonts.poppins(
                          color: AppColors.greyColorTheme(isDark),
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.secondaryColorTheme(isDark),
                    strokeWidth: 0.5,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
            ),
          ),
        ),
      ],
    );
  }

  // ========== 4. Habit Comparison & Ranking ==========
  Widget _buildHabitRankingSection(bool isDark) {
    if (_habitRankings == null) return const SizedBox.shrink();

    final top3 = _habitRankings!['top3'] as List;
    final bottom3 = _habitRankings!['bottom3'] as List;
    final byCompletions = _habitRankings!['byCompletions'] as List;
    final totalHabits = byCompletions.length;

    return _buildSectionCard(
      isDark: isDark,
      title: "Habit Rankings",
      icon: LucideIcons.trophy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Top 3 Performing Habits",
            style: GoogleFonts.poppins(
              color: AppColors.textColor(isDark),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const Gap(12),
          ...top3.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final streak = item['streak'] as Streak;
            final completions = item['completions'] as int;
            final currentStreak = item['currentStreak'] as int;
            final consistency = item['consistency'] as double;
            return _buildRankingItem(
              isDark: isDark,
              rank: index + 1,
              streak: streak,
              completions: completions,
              currentStreak: currentStreak,
              consistency: consistency,
              isTop: true,
            );
          }),
          if (bottom3.isNotEmpty) ...[
            const Gap(20),
            Text(
              "Habits Needing Improvement",
              style: GoogleFonts.poppins(
                color: AppColors.textColor(isDark),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const Gap(12),
            ...bottom3.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final streak = item['streak'] as Streak;
              final completions = item['completions'] as int;
              final currentStreak = item['currentStreak'] as int;
              final consistency = item['consistency'] as double;
              return _buildRankingItem(
                isDark: isDark,
                rank: totalHabits - bottom3.length + index + 1,
                streak: streak,
                completions: completions,
                currentStreak: currentStreak,
                consistency: consistency,
                isTop: false,
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildRankingItem({
    required bool isDark,
    required int rank,
    required Streak streak,
    required int completions,
    required int currentStreak,
    required double consistency,
    required bool isTop,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColorTheme(isDark),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: isTop
              ? AppColors.primaryColor.withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isTop
                  ? AppColors.primaryColor.withValues(alpha: 0.2)
                  : Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: GoogleFonts.poppins(
                  color: isTop ? AppColors.primaryColor : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  streak.name,
                  style: GoogleFonts.poppins(
                    color: AppColors.textColor(isDark),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const Gap(4),
                Row(
                  children: [
                    Icon(
                      LucideIcons.checkCircle2,
                      size: 12,
                      color: AppColors.greyColorTheme(isDark),
                    ),
                    const Gap(4),
                    Text(
                      "$completions",
                      style: GoogleFonts.poppins(
                        color: AppColors.greyColorTheme(isDark),
                        fontSize: 11,
                      ),
                    ),
                    const Gap(8),
                    Icon(
                      LucideIcons.flame,
                      size: 12,
                      color: AppColors.greyColorTheme(isDark),
                    ),
                    const Gap(4),
                    Text(
                      "$currentStreak day streak",
                      style: GoogleFonts.poppins(
                        color: AppColors.greyColorTheme(isDark),
                        fontSize: 11,
                      ),
                    ),
                    const Gap(8),
                    Icon(
                      LucideIcons.percent,
                      size: 12,
                      color: AppColors.greyColorTheme(isDark),
                    ),
                    const Gap(4),
                    Text(
                      "${consistency.toStringAsFixed(0)}%",
                      style: GoogleFonts.poppins(
                        color: AppColors.greyColorTheme(isDark),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            isTop ? LucideIcons.trendingUp : LucideIcons.trendingDown,
            color: isTop ? AppColors.primaryColor : Colors.red,
          ),
        ],
      ),
    );
  }

  // ========== 5. Consistency & Gaps ==========
  Widget _buildConsistencyGapsSection(bool isDark) {
    if (_consistencyGaps == null) return const SizedBox.shrink();

    final inactiveHabits = _consistencyGaps!['inactiveHabits'] as List<Streak>;

    return _buildSectionCard(
      isDark: isDark,
      title: "Consistency & Gaps",
      icon: LucideIcons.alertCircle,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  isDark: isDark,
                  label: "Avg Gap Days",
                  value: _consistencyGaps!['averageGap'].toStringAsFixed(1),
                  icon: LucideIcons.clock,
                ),
              ),
              const Gap(12),
              Expanded(
                child: _buildMetricCard(
                  isDark: isDark,
                  label: "Total Missed Days",
                  value: _consistencyGaps!['totalMissedDays'].toString(),
                  icon: LucideIcons.xCircle,
                ),
              ),
            ],
          ),
          if (inactiveHabits.isNotEmpty) ...[
            const Gap(16),
            Text(
              "Inactive Habits (No activity in 7+ days)",
              style: GoogleFonts.poppins(
                color: AppColors.textColor(isDark),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const Gap(8),
            ...inactiveHabits.map((habit) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.alertCircle,
                        color: Colors.red,
                        size: 20,
                      ),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          habit.name,
                          style: GoogleFonts.poppins(
                            color: AppColors.textColor(isDark),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  // ========== 6. Time Scheduling Insights ==========
  Widget _buildSchedulingInsightsSection(bool isDark) {
    if (_schedulingInsights == null) return const SizedBox.shrink();

    final timeWindows =
        _schedulingInsights!['timeWindowCompletions'] as Map<String, int>;
    final bestWindow = _schedulingInsights!['bestPerformingWindow'] as String;

    final windowNames = {
      'earlyMorning': 'Early Morning (5-9)',
      'morning': 'Morning (9-12)',
      'afternoon': 'Afternoon (12-17)',
      'evening': 'Evening (17-21)',
      'night': 'Night (21-5)',
    };

    return _buildSectionCard(
      isDark: isDark,
      title: "Scheduling Insights",
      icon: LucideIcons.clock,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricCard(
            isDark: isDark,
            label: "Best Performing Time",
            value: windowNames[bestWindow] ?? bestWindow,
            icon: LucideIcons.star,
          ),
          const Gap(16),
          Text(
            "Completions by Time Window",
            style: GoogleFonts.poppins(
              color: AppColors.textColor(isDark),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const Gap(12),
          ...timeWindows.entries.map((entry) {
            final maxValue = timeWindows.values.reduce((a, b) => a > b ? a : b);
            final percentage = maxValue > 0 ? (entry.value / maxValue) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        windowNames[entry.key] ?? entry.key,
                        style: GoogleFonts.poppins(
                          color: AppColors.textColor(isDark),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        entry.value.toString(),
                        style: GoogleFonts.poppins(
                          color: AppColors.textColor(isDark),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Gap(4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: AppColors.secondaryColorTheme(isDark),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        entry.key == bestWindow
                            ? AppColors.primaryColor
                            : AppColors.greyColorTheme(isDark),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ========== 7. Weekly & Monthly Summaries ==========
  Widget _buildWeeklyMonthlySection(bool isDark) {
    if (_weeklyMonthlySummaries == null) return const SizedBox.shrink();

    return _buildSectionCard(
      isDark: isDark,
      title: "Weekly & Monthly Progress",
      icon: LucideIcons.calendar,
      child: Column(
        children: [
          _buildMetricCard(
            isDark: isDark,
            label: "Best Performing Week",
            value: _weeklyMonthlySummaries!['bestWeek'].toString(),
            icon: LucideIcons.trophy,
          ),
          const Gap(12),
          _buildMetricCard(
            isDark: isDark,
            label: "Best Performing Month",
            value: _weeklyMonthlySummaries!['bestMonth'].toString(),
            icon: LucideIcons.star,
          ),
        ],
      ),
    );
  }

  // ========== 8. AI-Generated Insights ==========
  Widget _buildInsightsSection(bool isDark) {
    if (_insights == null || _insights!.isEmpty) return const SizedBox.shrink();

    return _buildSectionCard(
      isDark: isDark,
      title: "Personalized Insights",
      icon: LucideIcons.sparkles,
      child: Column(
        children: _insights!
            .map((insight) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardColorTheme(isDark),
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        LucideIcons.lightbulb,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          insight,
                          style: GoogleFonts.poppins(
                            color: AppColors.textColor(isDark),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  // ========== 9. Achievements & Engagement ==========
  Widget _buildAchievementsSection(bool isDark) {
    if (_overallSummary == null) return const SizedBox.shrink();

    final totalCompletions = _overallSummary!['totalCompletions'] as int;
    final longestStreak = _overallSummary!['longestStreak'] as int;
    final consistencyScore = _overallSummary!['consistencyScore'] as double;

    List<Map<String, dynamic>> achievements = [];

    if (totalCompletions >= 100) {
      achievements.add({
        'title': 'Century Club',
        'description': '100+ total completions',
        'icon': LucideIcons.trophy,
        'unlocked': true,
      });
    } else {
      achievements.add({
        'title': 'Century Club',
        'description': '${100 - totalCompletions} more to go',
        'icon': LucideIcons.trophy,
        'unlocked': false,
      });
    }

    if (longestStreak >= 7) {
      achievements.add({
        'title': 'Week Warrior',
        'description': '7+ day streak achieved',
        'icon': LucideIcons.flame,
        'unlocked': true,
      });
    } else {
      achievements.add({
        'title': 'Week Warrior',
        'description': '${7 - longestStreak} more days needed',
        'icon': LucideIcons.flame,
        'unlocked': false,
      });
    }

    if (consistencyScore >= 80) {
      achievements.add({
        'title': 'Consistency Master',
        'description': '80%+ consistency score',
        'icon': LucideIcons.star,
        'unlocked': true,
      });
    } else {
      achievements.add({
        'title': 'Consistency Master',
        'description':
            '${(80 - consistencyScore).toStringAsFixed(0)}% more needed',
        'icon': LucideIcons.star,
        'unlocked': false,
      });
    }

    return _buildSectionCard(
      isDark: isDark,
      title: "Achievements",
      icon: LucideIcons.award,
      child: Column(
        children: achievements
            .map((achievement) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: achievement['unlocked']
                        ? AppColors.primaryColor.withValues(alpha: 0.1)
                        : AppColors.cardColorTheme(isDark),
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(
                      color: achievement['unlocked']
                          ? AppColors.primaryColor
                          : AppColors.greyColorTheme(isDark)
                              .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        achievement['icon'] as IconData,
                        color: achievement['unlocked']
                            ? AppColors.primaryColor
                            : AppColors.greyColorTheme(isDark),
                        size: 24,
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              achievement['title'] as String,
                              style: GoogleFonts.poppins(
                                color: AppColors.textColor(isDark),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              achievement['description'] as String,
                              style: GoogleFonts.poppins(
                                color: AppColors.greyColorTheme(isDark),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (achievement['unlocked'])
                        Icon(
                          LucideIcons.checkCircle2,
                          color: AppColors.primaryColor,
                        ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  // ========== Helper Widgets ==========
  Widget _buildSectionCard({
    required bool isDark,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColorTheme(isDark),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 20),
              const Gap(8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: AppColors.textColor(isDark),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const Gap(16),
          child,
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required bool isDark,
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryColorTheme(isDark),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 18),
              const Gap(8),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: AppColors.greyColorTheme(isDark),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: AppColors.textColor(isDark),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(int dayIndex) {
    final dayNames = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    return dayNames[dayIndex];
  }
}
