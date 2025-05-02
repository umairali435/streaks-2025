import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:streaks/res/colors.dart';

class CustomLoadingWidget extends StatelessWidget {
  const CustomLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? CircularProgressIndicator(
            color: AppColors.primaryColor,
          )
        : CupertinoActivityIndicator(
            color: AppColors.primaryColor,
          );
  }
}
