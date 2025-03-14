import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:streaks/bloc/streaks_bloc.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/res/constants.dart';
import 'package:streaks/database/streaks_database.dart';
import 'package:streaks/screen/add_screen.dart';

class StreakDetailScreen extends StatefulWidget {
  final Streak streak;

  const StreakDetailScreen({super.key, required this.streak});

  @override
  State<StreakDetailScreen> createState() => _StreakDetailScreenState();
}

class _StreakDetailScreenState extends State<StreakDetailScreen> {
  List<DateTime> allDates = [];
  List<DateTime> getAllDatesOfCurrentYear() {
    int year = DateTime.now().year;
    DateTime startDate = DateTime(year, 1, 1);
    DateTime endDate = DateTime(year, 12, 31);

    return List.generate(
      endDate.difference(startDate).inDays + 1,
      (index) => startDate.add(Duration(days: index)),
    );
  }

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
    allDates = getAllDatesOfCurrentYear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int longestStreak = calculateLongestStreak(widget.streak.streakDates);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            LucideIcons.chevronLeft,
            color: AppColors.whiteColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          widget.streak.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w900,
            color: AppColors.whiteColor,
            fontSize: 18.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              LucideIcons.edit,
              color: AppColors.whiteColor,
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
              color: AppColors.whiteColor,
            ),
            onPressed: () async {
              await StreaksDatabase.deleteStreakById(widget.streak.id)
                  .then((_) {
                context.read<StreaksBloc>().add(LoadStreaks());
                Navigator.of(context).pop();
              });
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Current Streak",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w900,
                                    color: Color(widget.streak.colorCode),
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
                                      fontWeight: FontWeight.w900,
                                      color: Color(widget.streak.colorCode),
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
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Longest Streak",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w900,
                                    color: Color(widget.streak.colorCode),
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
                                      fontWeight: FontWeight.w900,
                                      color: Color(widget.streak.colorCode),
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
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "365 Days",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w900,
                            color: Color(widget.streak.colorCode),
                            fontSize: 18.0,
                          ),
                        ),
                        const Gap(10.0),
                        GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 23),
                          itemCount: 365,
                          itemBuilder: (context, index) {
                            List<DateTime> dates = allDates;
                            DateTime date = dates[index];
                            bool isStreakDay = widget.streak.streakDates
                                .map((date) =>
                                    DateTime(date.year, date.month, date.day))
                                .contains(
                                    DateTime(date.year, date.month, date.day));
                            return Container(
                              margin: const EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                color: isStreakDay
                                    ? Color(widget.streak.colorCode)
                                    : AppColors.greyColor,
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                            );
                          },
                        ),
                      ],
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
