import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streaks/res/assets.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/services/share_prefs_services.dart';

class SaleOfferScreen extends StatefulWidget {
  const SaleOfferScreen({super.key});

  @override
  State<SaleOfferScreen> createState() => _SaleOfferScreenState();
}

class _SaleOfferScreenState extends State<SaleOfferScreen> {
  static const Duration _offerDuration = Duration(hours: 2);

  Timer? _ticker;
  Duration _remaining = Duration.zero;
  DateTime? _expiry;

  @override
  void initState() {
    super.initState();
    _initializeCountdown();
  }

  Future<void> _initializeCountdown() async {
    final previousExpiry = SharePrefsService.getSaleOfferExpiry();
    final expiry =
        await SharePrefsService.ensureSaleOfferExpiry(_offerDuration);

    if (!mounted) return;
    setState(() {
      _expiry = expiry;
      _remaining = _calculateRemaining(expiry);
    });

    if (previousExpiry == null || previousExpiry.isBefore(DateTime.now())) {
      await SharePrefsService.setSaleOfferBannerDismissed(false);
    }

    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    if (_expiry == null) return;

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _expiry == null) return;
      final updated = _calculateRemaining(_expiry!);
      if (!mounted) return;
      setState(() {
        _remaining = updated;
      });
      if (updated <= Duration.zero) {
        _ticker?.cancel();
      }
    });
  }

  Duration _calculateRemaining(DateTime expiry) {
    final diff = expiry.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  String _formatDuration(Duration duration) {
    if (duration <= Duration.zero) return 'Expired';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _handleClose({bool openCheckout = false}) async {
    await SharePrefsService.setSaleOfferBannerDismissed(false);
    if (!mounted) return;
    Navigator.of(context).pop(openCheckout);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackgroundColor : AppColors.lightBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '11.11 Celebration Sale',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textColor(isDark),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _handleClose(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.textColor(isDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryColor.withValues(alpha: 0.98),
                        AppColors.primaryColor,
                        AppColors.primaryColor.withValues(alpha: 0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.4),
                        blurRadius: 40,
                        offset: const Offset(0, 24),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCountdown(),
                        const SizedBox(height: 24),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Image.asset(
                              AppAssets.saleOffer,
                              height: 140,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Save 50% today only',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkBackgroundColor,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '\$49.99 → \$24.99 for your first year',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkBackgroundColor
                                      .withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 26),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.zero,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                FeatureItem(
                                  text:
                                      'Unlimited streaks, habits & pro scheduling tools',
                                  textColor: AppColors.darkBackgroundColor,
                                  iconColor: AppColors.darkBackgroundColor,
                                ),
                                SizedBox(height: 14),
                                FeatureItem(
                                  text:
                                      'Deep progress analytics with weekly momentum reports',
                                  textColor: AppColors.darkBackgroundColor,
                                  iconColor: AppColors.darkBackgroundColor,
                                ),
                                SizedBox(height: 14),
                                FeatureItem(
                                  text:
                                      'Adaptive reminders tuned to your timezone & rhythm',
                                  textColor: AppColors.darkBackgroundColor,
                                  iconColor: AppColors.darkBackgroundColor,
                                ),
                                SizedBox(height: 14),
                                FeatureItem(
                                  text:
                                      'Seasonal icon drops, widgets & premium themes',
                                  textColor: AppColors.darkBackgroundColor,
                                  iconColor: AppColors.darkBackgroundColor,
                                ),
                                SizedBox(height: 14),
                                FeatureItem(
                                  text:
                                      'VIP streak recovery concierge when life gets messy',
                                  textColor: AppColors.darkBackgroundColor,
                                  iconColor: AppColors.darkBackgroundColor,
                                ),
                                SizedBox(height: 14),
                                FeatureItem(
                                  text:
                                      'Invite-only community challenges & accountability vault',
                                  textColor: AppColors.darkBackgroundColor,
                                  iconColor: AppColors.darkBackgroundColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => _handleClose(openCheckout: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkBackgroundColor,
                            foregroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            minimumSize: const Size.fromHeight(56),
                            textStyle: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          child: const Text('Unlock Premium Now'),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            'Billed \$24.99 for year one, \$49.99/year after. Cancel anytime.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.darkBackgroundColor
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdown() {
    final formatted = _formatDuration(_remaining);

    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.timer_outlined,
              size: 28.0,
              color: Colors.black87,
            ),
            const SizedBox(width: 10),
            Text(
              formatted == 'Expired' ? 'Offer ended' : 'Ends in $formatted',
              style: GoogleFonts.poppins(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color iconColor;

  const FeatureItem({
    super.key,
    required this.text,
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_rounded,
          color: iconColor,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
