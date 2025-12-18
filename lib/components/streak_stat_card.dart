import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/res/constants.dart';

class StreakStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? suffix;
  final bool isDark;

  const StreakStatCard({
    super.key,
    required this.title,
    required this.value,
    this.suffix,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardColorTheme(isDark),
          border: Border.all(color: AppColors.darkBorderColor),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor(isDark),
                  fontSize: 16.0,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor(isDark),
                    fontSize: 45.0,
                  ),
                ),
                if (suffix != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                    child: Text(
                      suffix!,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColor(isDark),
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
