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

class StreakDetailScreen extends StatelessWidget {
  final Streak streak;

  const StreakDetailScreen({super.key, required this.streak});

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
  Widget build(BuildContext context) {
    int longestStreak = calculateLongestStreak(streak.streakDates);

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
          streak.name,
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
                    streak: streak,
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
              await StreaksDatabase.deleteStreakById(streak.id).then((_) {
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
                            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
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
                                    color: Color(streak.colorCode),
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    streak.streakDates.length.toString(),
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w900,
                                      color: Color(streak.colorCode),
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
                            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
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
                                    color: Color(streak.colorCode),
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
                                      color: Color(streak.colorCode),
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
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "365 Days",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w900,
                            color: Color(streak.colorCode),
                            fontSize: 18.0,
                          ),
                        ),
                        const Gap(10.0),
                        GridView.builder(
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 23),
                          itemCount: 365,
                          itemBuilder: (context, index) {
                            DateTime date = DateTime.now().add(Duration(days: index));
                            bool isStreakDay = streak.streakDates.contains(DateTime(date.year, date.month, date.day));
                            return Container(
                              margin: const EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                color: isStreakDay ? Color(streak.colorCode) : AppColors.greyColor,
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
