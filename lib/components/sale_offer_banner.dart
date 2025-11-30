import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streaks/res/assets.dart';
import 'package:streaks/res/colors.dart';

class SaleOfferBanner extends StatelessWidget {
  final Duration remaining;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const SaleOfferBanner({
    super.key,
    required this.remaining,
    required this.onDismiss,
    required this.onTap,
  });

  String _formatDuration(Duration duration) {
    if (duration <= Duration.zero) {
      return 'Expired';
    }
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final timePortion = '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
    if (days > 0) {
      return '${days}d $timePortion';
    }
    return timePortion;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsetsDirectional.only(top: 5.0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.greyColor,
        ),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppAssets.saleOffer,
                      width: 68,
                      height: 68,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Black Friday Midnight Countdown',
                        style: GoogleFonts.poppins(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBackgroundColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Save 50% on your first year of Premium.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkBackgroundColor
                              .withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.black,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 18.0,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Ends in ${_formatDuration(remaining)}',
                              style: GoogleFonts.poppins(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                onDismiss();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
