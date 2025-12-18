import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streaks/bloc/theme_bloc.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/screen/streak_details/widgets/custom_button.dart';
import 'package:streaks/services/badge_service.dart';

class CelebrationDialog extends StatefulWidget {
  final String streakName;
  final int currentStreak;
  final Color streakColor;
  final int? unlockedBadgeLevel;

  const CelebrationDialog({
    super.key,
    required this.streakName,
    required this.currentStreak,
    required this.streakColor,
    this.unlockedBadgeLevel,
  });

  @override
  State<CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<CelebrationDialog>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _stopConfettiTimer;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
    _confettiController.play();

    _stopConfettiTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        try {
          _confettiController.stop();
        } catch (e) {
          debugPrint('Could not stop confetti: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _stopConfettiTimer?.cancel();
    _stopConfettiTimer = null;

    try {
      _confettiController.stop();
    } catch (e) {
      debugPrint('Could not stop confetti in dispose: $e');
    }

    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState is ThemeLoaded ? themeState.isDark : true;
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20.0),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.cardColorTheme(isDark),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.streakColor.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Show badge if unlocked, otherwise show emoji
                        if (widget.unlockedBadgeLevel != null)
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: widget.streakColor,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.streakColor
                                        .withValues(alpha: 0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  BadgeService.getBadgeAssetPath(
                                      widget.unlockedBadgeLevel!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                        else
                          Text(
                            '🎉',
                            style: TextStyle(fontSize: 64),
                          ),
                        const Gap(16.0),
                        if (widget.unlockedBadgeLevel != null)
                          Column(
                            children: [
                              Text(
                                'Badge Unlocked!',
                                style: GoogleFonts.poppins(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor(isDark),
                                ),
                              ),
                              const Gap(8.0),
                              Text(
                                BadgeService.getBadgeDescription(
                                    widget.unlockedBadgeLevel!),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: widget.streakColor,
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            'Great Job!',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor(isDark),
                            ),
                          ),
                        Text(
                          widget.streakName,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: widget.streakColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: widget.streakColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.streakColor,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '🔥',
                                style: TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.currentStreak} Day Streak!',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                        CustomButton(
                          color: widget.streakColor,
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          label: 'Keep Going!',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: 3.14 / 2,
                  maxBlastForce: 5,
                  minBlastForce: 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  gravity: 0.1,
                  shouldLoop: false,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple,
                    Colors.yellow,
                    Colors.red,
                    Colors.cyan,
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
