import 'package:flutter/material.dart';
import 'package:streaks/res/colors.dart';

class CustomButton extends StatelessWidget {
  final double? height;
  final double? width;
  final String label;
  final VoidCallback onTap;
  final bool isLoading;
  final double? margin;
  final double? radius;
  final Color color;
  const CustomButton({
    super.key,
    this.height = 45.0,
    this.width = double.infinity,
    required this.label,
    required this.onTap,
    this.margin,
    this.isLoading = false,
    this.color = AppColors.primaryColor,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: EdgeInsets.symmetric(vertical: margin ?? 14.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius ?? 10.0),
          color: color,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  height: 30.0,
                  width: 30.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.0,
                    color: AppColors.primaryColor,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    letterSpacing: 1.2,
                    fontSize: 16.0,
                    color: AppColors.blackColor,
                  ),
                ),
        ),
      ),
    );
  }
}
