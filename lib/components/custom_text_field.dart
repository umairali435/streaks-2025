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
            color: AppColors.whiteColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            fontSize: 18.0,
          ),
        ),
        const Gap(14.0),
        TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          onTap: onPressed,
          style: const TextStyle(color: AppColors.whiteColor),
          cursorColor: AppColors.whiteColor,
          decoration: InputDecoration(
            filled: true,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 14.0),
            fillColor: AppColors.cardColor,
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide(color: Colors.transparent),
            ),
          ),
        ),
        const Gap(14.0),
      ],
    );
  }
}
