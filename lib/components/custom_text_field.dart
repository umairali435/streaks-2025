import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streaks/bloc/theme_bloc.dart';
import 'package:streaks/res/colors.dart';

class CustomTextField extends StatelessWidget {
  final String title, hintText;
  final TextEditingController controller;
  final VoidCallback? onPressed;
  final bool isReadOnly;
  final Function(String?)? onSaved;
  final Function(String)? onChanged;
  const CustomTextField({
    super.key,
    required this.title,
    this.hintText = "",
    required this.controller,
    this.onPressed,
    this.isReadOnly = false,
    this.onSaved,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState is ThemeLoaded ? themeState.isDark : true;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                color: AppColors.greyColorTheme(isDark),
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            const Gap(14.0),
            TextFormField(
              controller: controller,
              readOnly: isReadOnly,
              onTap: onPressed,
              style: TextStyle(color: AppColors.textColor(isDark)),
              cursorColor: AppColors.textColor(isDark),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: AppColors.greyColorTheme(isDark),
                  fontSize: 14.0,
                ),
                filled: true,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 14.0),
                fillColor: AppColors.cardColorTheme(isDark),
                border: InputBorder.none,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
              ),
            ),
            const Gap(14.0),
          ],
        );
      },
    );
  }
}
