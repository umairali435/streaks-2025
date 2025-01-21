import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streaks/res/colors.dart';

class CustomTextField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final VoidCallback? onPressed;
  final bool isReadOnly;
  final Function(String?)? onSaved;
  final Function(String)? onChanged;
  const CustomTextField({
    super.key,
    required this.title,
    required this.controller,
    this.onPressed,
    this.isReadOnly = false,
    this.onSaved,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: AppColors.whiteColor,
            letterSpacing: 0.8,
            fontSize: 18.0,
          ),
        ),
        const Gap(8.0),
        TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          onTap: onPressed,
          style: const TextStyle(color: AppColors.whiteColor),
          decoration: const InputDecoration(
            filled: true,
            isDense: true,
            fillColor: AppColors.blackColor,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: FlexColor.greyDarkSecondary),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: FlexColor.greyDarkSecondary),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: FlexColor.greyDarkSecondaryContainer),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
          ),
        ),
        const Gap(14.0),
      ],
    );
  }
}
