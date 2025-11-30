import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:streaks/bloc/streaks_bloc.dart';
import 'package:streaks/bloc/theme_bloc.dart';
import 'package:streaks/components/celebration_dialog.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/res/strings.dart';
import 'package:streaks/database/streaks_database.dart';
import 'package:streaks/services/badge_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StreakContainer extends StatefulWidget {
  final Streak streak;

  const StreakContainer({
    super.key,
    required this.streak,
  });

  @override
  State<StreakContainer> createState() => _StreakContainerState();
}

class _StreakContainerState extends State<StreakContainer> {
  int? _pendingStreakCheck;
  DateTime? _pendingDateCheck;

  bool? _localTodayChecked;
  List<DateTime>? _localStreakDates;

  bool _isCheckingBadge = false;

  void _requestReviewIfAppropriate(int currentStreak) {
    Future.microtask(() async {
      try {
        const milestones = [7, 14, 30, 50, 100, 200, 365];
        if (!milestones.contains(currentStreak)) {
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        const lastReviewKey = 'last_in_app_review_date';
        const lastReviewStreakKey = 'last_in_app_review_streak';

        final lastReviewDateStr = prefs.getString(lastReviewKey);
        final lastReviewStreak = prefs.getInt(lastReviewStreakKey) ?? 0;

        if (lastReviewStreak >= currentStreak) {
          return;
        }

        if (lastReviewDateStr != null) {
          final lastReviewDate = DateTime.parse(lastReviewDateStr);
          final daysSinceLastReview =
              DateTime.now().difference(lastReviewDate).inDays;
          if (daysSinceLastReview < 30) {
            return;
          }
        }

        await Future.delayed(const Duration(milliseconds: 1000));

        if (!mounted) return;

        final InAppReview inAppReview = InAppReview.instance;
        if (await inAppReview.isAvailable()) {
          await inAppReview.requestReview();

          await prefs.setString(
              lastReviewKey, DateTime.now().toIso8601String());
          await prefs.setInt(lastReviewStreakKey, currentStreak);
        }
      } catch (e) {
        debugPrint('Error requesting in-app review: $e');
      }
    });
  }

  int calculateCurrentStreak(List<DateTime> streakDates) {
    if (streakDates.isEmpty || widget.streak.selectedDays.isEmpty) return 0;

    final sortedDates = List<DateTime>.from(streakDates)
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    DateTime? startDate = todayOnly;
    if (!sortedDates
        .any((d) => DateTime(d.year, d.month, d.day) == todayOnly)) {
      final yesterday = todayOnly.subtract(const Duration(days: 1));
      if (sortedDates
          .any((d) => DateTime(d.year, d.month, d.day) == yesterday)) {
        startDate = yesterday;
      } else {
        return 0;
      }
    }

    int streakCount = 0;
    DateTime currentCheckDate = startDate;
    int dateIndex = 0;

    while (dateIndex < sortedDates.length &&
        currentCheckDate
            .isAfter(sortedDates.last.subtract(const Duration(days: 1)))) {
      final currentDateOnly = DateTime(
        currentCheckDate.year,
        currentCheckDate.month,
        currentCheckDate.day,
      );

      final dayIndex = currentCheckDate.weekday % 7;
      final isActiveDay = widget.streak.selectedDays.contains(dayIndex);

      if (isActiveDay) {
        if (dateIndex < sortedDates.length) {
          final completedDate = sortedDates[dateIndex];
          final completedDateOnly = DateTime(
            completedDate.year,
            completedDate.month,
            completedDate.day,
          );

          if (completedDateOnly == currentDateOnly) {
            streakCount++;
            dateIndex++;
          } else if (completedDateOnly.isAfter(currentDateOnly)) {
            break;
          } else {
            dateIndex++;
            continue;
          }
        } else {
          break;
        }
      }

      currentCheckDate = currentCheckDate.subtract(const Duration(days: 1));
    }

    return streakCount;
  }

  void _showCelebrationDialog(int currentStreak, int? unlockedBadgeLevel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CelebrationDialog(
        streakName: widget.streak.name,
        currentStreak: currentStreak,
        streakColor: Color(widget.streak.colorCode),
        unlockedBadgeLevel: unlockedBadgeLevel,
      ),
    );
  }

  void _checkBadgeUnlock() async {
    if (_pendingStreakCheck == null || _pendingDateCheck == null || !mounted) {
      return;
    }

    final streak = widget.streak;

    final todayWithoutTime = DateTime(
      _pendingDateCheck!.year,
      _pendingDateCheck!.month,
      _pendingDateCheck!.day,
    );

    final dateExists = streak.streakDates
        .any((d) => DateTime(d.year, d.month, d.day) == todayWithoutTime);

    if (!dateExists) {
      debugPrint('Badge check: Date not added yet, skipping');
      _isCheckingBadge = false;
      return;
    }

    final currentStreak = calculateCurrentStreak(streak.streakDates);
    debugPrint('Badge check: Current streak = $currentStreak');

    final unlockedBadges = streak.unlockedBadges ?? [];
    debugPrint('Badge check: Unlocked badges = $unlockedBadges');

    final newBadgeLevel = BadgeService.checkNewBadgeUnlocked(
      currentStreak,
      unlockedBadges,
    );
    debugPrint('Badge check: New badge level = $newBadgeLevel');

    final pendingCheck = _pendingStreakCheck;

    setState(() {
      _pendingStreakCheck = null;
      _pendingDateCheck = null;
      _isCheckingBadge = false;
    });

    if (newBadgeLevel != null && mounted && context.mounted) {
      debugPrint('Badge check: Unlocking badge $newBadgeLevel');
      await StreaksDatabase.unlockBadge(streak.id, newBadgeLevel);

      context.read<StreaksBloc>().add(LoadStreaks());

      if (mounted && context.mounted) {
        _showCelebrationDialog(pendingCheck ?? currentStreak, newBadgeLevel);
      }
    } else {
      debugPrint('Badge check: No new badge to unlock');
    }
  }

  @override
  void didUpdateWidget(StreakContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.streak.id != widget.streak.id ||
        !_listsEqual(oldWidget.streak.streakDates, widget.streak.streakDates)) {
      if (_localStreakDates != null || _localTodayChecked != null) {
        if (_pendingDateCheck != null) {
          final todayWithoutTime = DateTime(
            _pendingDateCheck!.year,
            _pendingDateCheck!.month,
            _pendingDateCheck!.day,
          );

          final wasAdded = widget.streak.streakDates
              .any((d) => DateTime(d.year, d.month, d.day) == todayWithoutTime);
          final wasRemoved = !wasAdded && _localTodayChecked == false;

          if (wasAdded || wasRemoved) {
            Future.microtask(() {
              if (mounted) {
                setState(() {
                  _localStreakDates = null;
                  _localTodayChecked = null;
                });

                if (_pendingStreakCheck != null &&
                    _pendingDateCheck != null &&
                    !_isCheckingBadge) {
                  _isCheckingBadge = true;
                  _checkBadgeUnlock();
                }
              }
            });
          }
        } else {
          setState(() {
            _localStreakDates = null;
            _localTodayChecked = null;
          });
        }
      }
    }
  }

  bool _listsEqual(List<DateTime> list1, List<DateTime> list2) {
    if (list1.length != list2.length) return false;
    final set1 = list1.map((d) => DateTime(d.year, d.month, d.day)).toSet();
    final set2 = list2.map((d) => DateTime(d.year, d.month, d.day)).toSet();
    return set1.length == set2.length && set1.every((d) => set2.contains(d));
  }

  bool _getTodayChecked() {
    DateTime today = DateTime.now();
    DateTime todayWithoutTime = DateTime(today.year, today.month, today.day);

    if (_localTodayChecked != null) {
      return _localTodayChecked!;
    }

    if (_localStreakDates != null) {
      return _localStreakDates!.contains(todayWithoutTime);
    }

    return widget.streak.streakDates.contains(todayWithoutTime);
  }

  List<DateTime> _getStreakDates() {
    if (_localStreakDates != null) {
      return _localStreakDates!;
    }
    return widget.streak.streakDates;
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    DateTime todayWithoutTime = DateTime(today.year, today.month, today.day);
    bool isTodayChecked = _getTodayChecked();
    List<DateTime> currentStreakDates = _getStreakDates();

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState is ThemeLoaded ? themeState.isDark : true;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Card(
            color: AppColors.cardColorTheme(isDark),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              padding: const EdgeInsets.all(12.0),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        IconData(
                          widget.streak.iconCode,
                          fontFamily: "Lucide",
                          fontPackage: 'lucide_icons',
                        ),
                        size: 28.0,
                        color: AppColors.textColor(isDark),
                      ),
                      const Gap(14.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.streak.name,
                            style: GoogleFonts.poppins(
                              color: AppColors.textColor(isDark),
                              fontWeight: FontWeight.w500,
                              fontSize: 16.0,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          DateTime today = DateTime.now();
                          int todayWeekday = today.weekday;
                          int todayIndex = todayWeekday == 7 ? 0 : todayWeekday;
                          bool isDayActive =
                              widget.streak.selectedDays.contains(todayIndex);

                          if (isDayActive && isTodayChecked) {
                            setState(() {
                              _localTodayChecked = false;
                              _localStreakDates =
                                  List<DateTime>.from(currentStreakDates)
                                    ..removeWhere((d) =>
                                        DateTime(d.year, d.month, d.day) ==
                                        todayWithoutTime);
                            });

                            context.read<StreaksBloc>().add(RemoveStreakDate(
                                widget.streak.id, todayWithoutTime));
                          } else if (isDayActive && !isTodayChecked) {
                            final currentStreak =
                                calculateCurrentStreak(currentStreakDates) + 1;

                            setState(() {
                              _localTodayChecked = true;
                              _localStreakDates =
                                  List<DateTime>.from(currentStreakDates)
                                    ..add(todayWithoutTime);
                              _pendingStreakCheck = currentStreak;
                              _pendingDateCheck = todayWithoutTime;
                            });

                            context.read<StreaksBloc>().add(AddStreakDate(
                                widget.streak.id, todayWithoutTime));

                            _requestReviewIfAppropriate(currentStreak);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Color(widget.streak.colorCode),
                                content: Text(
                                  "You can't check inactive date",
                                  style: GoogleFonts.poppins(
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: Container(
                          height: 35.0,
                          width: 35.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(widget.streak.colorCode),
                            ),
                            color: isTodayChecked
                                ? Color(widget.streak.colorCode)
                                : AppColors.backgroundColor(isDark),
                          ),
                          child: Icon(
                            LucideIcons.check,
                            size: 22.0,
                            color: AppColors.backgroundColor(isDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: AppColors.greyColorTheme(isDark).withAlpha(100),
                    height: 25.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      7,
                      (index) {
                        DateTime today = DateTime.now();
                        int selectedWeekIndex = widget.streak.selectedWeek;
                        int currentWeekIndex = today.weekday;
                        int dayDifference =
                            ((currentWeekIndex - selectedWeekIndex) % 7);
                        List<String> reorderedWeeks = AppText.weekDays
                            .sublist(selectedWeekIndex)
                          ..addAll(
                              AppText.weekDays.sublist(0, selectedWeekIndex));
                        List<int> reorderWeekdaysIndex = List.generate(
                            7, (index) => (selectedWeekIndex + index) % 7);
                        DateTime date = today
                            .subtract(Duration(days: dayDifference - index));
                        DateTime weekDay = date;
                        DateTime weekDayOnly =
                            DateTime(weekDay.year, weekDay.month, weekDay.day);
                        bool isDayChecked = currentStreakDates.any((d) =>
                            DateTime(d.year, d.month, d.day) == weekDayOnly);
                        bool isDayActive = widget.streak.selectedDays
                            .contains(reorderWeekdaysIndex[index]);
                        return Column(
                          children: [
                            Container(
                              height: 35.0,
                              margin: const EdgeInsets.symmetric(vertical: 5.0),
                              width: 35.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25.0),
                                border: Border.all(
                                  color: !isDayChecked && isDayActive
                                      ? Colors.grey.shade700
                                      : Colors.transparent,
                                ),
                                color: isDayChecked
                                    ? Color(widget.streak.colorCode)
                                    : isDayActive
                                        ? Colors.transparent
                                        : AppColors.backgroundColor(isDark),
                              ),
                              child: Center(
                                child: isDayChecked
                                    ? Container(
                                        height: 18.0,
                                        width: 18.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.blackColor
                                              .withValues(alpha: 0.8),
                                        ),
                                        child: Icon(
                                          LucideIcons.check,
                                          color: isDayChecked
                                              ? AppColors.whiteColor
                                              : isDayActive
                                                  ? Color(
                                                      widget.streak.colorCode,
                                                    )
                                                  : AppColors.backgroundColor(
                                                      isDark,
                                                    ),
                                          size: 10.0,
                                        ),
                                      )
                                    : Container(),
                              ),
                            ),
                            Text(
                              reorderedWeeks[index],
                              style: GoogleFonts.poppins(
                                  color: AppColors.textColor(isDark)),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
