import 'package:flutter/material.dart';
import 'dart:async';

import 'package:lucide_icons/lucide_icons.dart';
import 'package:streaks/screen/home_screen.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/res/theme_helper.dart';
import 'package:streaks/screen/main_navigation_screen.dart';

class CrossIconWidget extends StatefulWidget {
  const CrossIconWidget({super.key});

  @override
  State<CrossIconWidget> createState() => _CrossIconWidgetState();
}

class _CrossIconWidgetState extends State<CrossIconWidget> {
  final int _totalSeconds = 5;
  late final int _totalMilliseconds;
  int _elapsedMilliseconds = 0;
  bool _showLoader = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _totalMilliseconds = _totalSeconds * 1000;
    _startSmoothCountdown();
  }

  void _startSmoothCountdown() {
    const interval = Duration(milliseconds: 50);
    _timer = Timer.periodic(interval, (timer) {
      setState(() {
        _elapsedMilliseconds += 50;
        if (_elapsedMilliseconds >= _totalMilliseconds) {
          _showLoader = false;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  double get _progress {
    final remaining = _totalMilliseconds - _elapsedMilliseconds;
    return remaining.clamp(0, _totalMilliseconds) / _totalMilliseconds;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _showLoader
          ? Padding(
              padding: const EdgeInsets.only(right: 20.0, top: 20.0),
              child: SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  value: _progress,
                  strokeWidth: 4.0,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 8.0),
              child: IconButton(
                icon: Icon(
                  LucideIcons.x,
                  size: 24.0,
                  color: AppColors.textColor(context.isDarkTheme),
                ),
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const MainNavigationScreen(),
                  ),
                ),
              ),
            ),
    );
  }
}
