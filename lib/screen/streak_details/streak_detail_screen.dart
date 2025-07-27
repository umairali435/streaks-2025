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
import 'package:streaks/res/colors.dart';
import 'package:streaks/res/constants.dart';
import 'package:streaks/database/streaks_database.dart';
import 'package:streaks/screen/add_screen.dart';
import 'package:streaks/screen/streak_details/widgets/premium_overlay_widget.dart';
import 'package:streaks/services/screenshot_service.dart';

class StreakDetailScreen extends StatefulWidget {
  final Streak streak;

  const StreakDetailScreen({super.key, required this.streak});

  @override
  State<StreakDetailScreen> createState() => _StreakDetailScreenState();
}

class _StreakDetailScreenState extends State<StreakDetailScreen> {
  int longestStreak = 0;
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final result = calculateLongestStreak(widget.streak.streakDates);
      if (mounted) {
        setState(() {
          longestStreak = result;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
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
            icon: const Icon(
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
            icon: const Icon(
              LucideIcons.trash,
            ),
            onPressed: () async {
              final dialogWidget = Platform.isAndroid
                  ? AlertDialog(
                      title: const Text("Delete Streak"),
                      content: const Text(
                          "Are you sure you want to delete this streak?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            await StreaksDatabase.deleteStreakById(
                                    widget.streak.id)
                                .then((_) {
                              context.read<StreaksBloc>().add(LoadStreaks());
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            });
                          },
                          child: const Text("Delete"),
                        ),
                      ],
                    )
                  : CupertinoAlertDialog(
                      title: const Text("Delete Streak"),
                      content: const Text(
                          "Are you sure you want to delete this streak?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            await StreaksDatabase.deleteStreakById(
                                    widget.streak.id)
                                .then((_) {
                              context.read<StreaksBloc>().add(LoadStreaks());
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
      body: BlocBuilder<StreaksBloc, StreaksState>(
        builder: (context, state) {
          if (state is StreaksLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StreaksUpdated) {
            return Padding(
              padding: const EdgeInsets.all(AppConstants.sidePadding),
              child: ListView(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.cardColor,
                            borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "Current Streak",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.whiteColor,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.streak.streakDates.length.toString(),
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.whiteColor,
                                      fontSize: 45.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(20.0),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.cardColor,
                            borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "Longest Streak",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.whiteColor,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    longestStreak.toString(),
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.whiteColor,
                                      fontSize: 45.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(20.0),
                  StreaksDotsWidget(streak: widget.streak),
                  const Gap(20.0),
                  PremiumLockedWidget(
                    child: Card(
                      color: AppColors.cardColor,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: HeatMapCalendar(
                          flexible: true,
                          margin: const EdgeInsets.all(5.0),
                          colorMode: ColorMode.color,
                          showColorTip: false,
                          textColor: AppColors.blackColor,
                          defaultColor: AppColors.whiteColor.withAlpha(100),
                          weekFontSize: 12.0,
                          weekTextColor: AppColors.whiteColor,
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
                ],
              ),
            );
          } else {
            return const Center(child: Text('Failed to load streaks'));
          }
        },
      ),
    );
  }
}

class StreaksDotsWidget extends StatefulWidget {
  final Streak streak;
  const StreaksDotsWidget({super.key, required this.streak});

  @override
  State<StreaksDotsWidget> createState() => _StreaksDotsWidgetState();
}

class _StreaksDotsWidgetState extends State<StreaksDotsWidget> {
  final screenshotService = ScreenshotService();
  List<DateTime> allDates = [];
  List<DateTime> getAllDatesOfCurrentYear() {
    int year = DateTime.now().year;
    DateTime startDate = widget.streak.streakDates.isNotEmpty
        ? DateTime(
            widget.streak.streakDates.first.year,
            widget.streak.streakDates.first.month,
            widget.streak.streakDates.first.day,
          )
        : DateTime(year, 1, 1);
    DateTime endDate = DateTime(year, 12, 31);
    return List.generate(
      endDate.difference(startDate).inDays + 1,
      (index) => startDate.add(Duration(days: index)),
    );
  }

  @override
  void initState() {
    super.initState();
    allDates = getAllDatesOfCurrentYear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final streaksDots = Screenshot(
      controller: screenshotService.controller,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
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
                          color: AppColors.whiteColor,
                          fontSize: 18.0,
                        ),
                      ),
                      Text(
                        widget.streak.selectedDays.length == 7
                            ? "Everyday"
                            : "${widget.streak.selectedDays.length} days per week",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: AppColors.whiteColor,
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
              child: GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.0,
                  mainAxisSpacing: 4.0,
                  crossAxisSpacing: 4.0,
                ),
                itemCount: allDates.length,
                itemBuilder: (context, index) {
                  List<DateTime> dates = allDates;
                  DateTime date = dates[index];
                  bool isStreakDay = widget.streak.streakDates
                      .map((date) => DateTime(date.year, date.month, date.day))
                      .contains(DateTime(date.year, date.month, date.day));
                  return Container(
                    margin: const EdgeInsets.all(1.0),
                    decoration: BoxDecoration(
                      color: isStreakDay
                          ? Color(widget.streak.colorCode)
                          : AppColors.greyColor.withAlpha(100),
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
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.download,
                    color: AppColors.whiteColor,
                    size: 18.0,
                  ),
                  Gap(10.0),
                  Text(
                    "Download",
                    style: GoogleFonts.poppins(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.whiteColor,
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
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.share2,
                    color: AppColors.whiteColor,
                    size: 18.0,
                  ),
                  Gap(10.0),
                  Text(
                    "Share",
                    style: GoogleFonts.poppins(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.whiteColor,
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
