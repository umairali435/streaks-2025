import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:streaks/bloc/streaks_bloc.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/res/constants.dart';
import 'package:streaks/res/strings.dart';
import 'package:streaks/database/streaks_database.dart';

class StreakContainer extends StatelessWidget {
  final Streak streak;

  const StreakContainer({
    super.key,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    DateTime todayWithoutTime = DateTime(today.year, today.month, today.day);
    bool isTodayChecked = streak.streakDates.contains(todayWithoutTime);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        color: Color(streak.containerColor).withOpacity(0.2),
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
                  Container(
                    height: 45.0,
                    width: 45.0,
                    decoration: BoxDecoration(
                      color: Color(streak.colorCode),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Icon(
                      IconData(
                        streak.iconCode,
                        fontFamily: "Lucide",
                        fontPackage: 'lucide_icons',
                      ),
                      size: 28.0,
                      color: AppColors.whiteColor,
                    ),
                  ),
                  const Gap(10.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        streak.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: AppColors.whiteColor,
                          fontSize: 18.0,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      int weekDay = AppConstants.getWeekDay(DateTime.now());
                      bool isDayActive = streak.selectedDays.contains(weekDay);
                      if (isDayActive && isTodayChecked) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Color(streak.colorCode),
                            content: Text(
                              "You already check today",
                              style: GoogleFonts.poppins(
                                color: AppColors.whiteColor,
                              ),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else if (isDayActive && !isTodayChecked) {
                        context.read<StreaksBloc>().add(AddStreakDate(streak.id, todayWithoutTime));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Color(streak.colorCode),
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
                    child: BlocBuilder<StreaksBloc, StreaksState>(
                      builder: (context, state) {
                        if (state is StreaksUpdated) {
                          isTodayChecked = state.streaks.firstWhere((s) => s.id == streak.id).streakDates.contains(todayWithoutTime);
                        }
                        return Container(
                          height: 35.0,
                          width: 35.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(streak.colorCode),
                            ),
                            color: isTodayChecked ? Color(streak.colorCode) : AppColors.blackColor,
                          ),
                          child: Icon(
                            LucideIcons.check,
                            size: 22.0,
                            color: isTodayChecked ? AppColors.whiteColor : AppColors.blackColor,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const Gap(20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  7,
                  (index) {
                    DateTime today = DateTime.now();
                    int selectedWeekIndex = streak.selectedWeek;
                    int currentWeekIndex = today.weekday;
                    int dayDifference = ((currentWeekIndex - selectedWeekIndex) % 7);
                    List<String> reorderedWeeks = AppText.weekDays.sublist(selectedWeekIndex)..addAll(AppText.weekDays.sublist(0, selectedWeekIndex));
                    List<int> reorderWeekdaysIndex = List.generate(7, (index) => (selectedWeekIndex + index) % 7);
                    DateTime date = today.subtract(Duration(days: dayDifference - index));
                    DateTime weekDay = date;
                    bool isDayChecked = streak.streakDates.contains(DateTime(weekDay.year, weekDay.month, weekDay.day));
                    bool isDayActive = streak.selectedDays.contains(reorderWeekdaysIndex[index]);
                    return Column(
                      children: [
                        Container(
                          height: 35.0,
                          margin: const EdgeInsets.symmetric(vertical: 5.0),
                          width: 35.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            color: isDayChecked
                                ? Color(streak.colorCode)
                                : isDayActive
                                    ? AppColors.whiteColor
                                    : AppColors.blackColor,
                          ),
                          child: Center(
                            child: Icon(
                              LucideIcons.check,
                              color: isDayChecked
                                  ? AppColors.whiteColor
                                  : isDayActive
                                      ? Color(streak.colorCode)
                                      : AppColors.whiteColor,
                              size: 16.0,
                            ),
                          ),
                        ),
                        Text(
                          reorderedWeeks[index],
                          style: GoogleFonts.poppins(color: AppColors.whiteColor),
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
  }
}
