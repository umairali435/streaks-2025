import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:streaks/res/assets.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/purchases_bloc/purchases_bloc.dart';
import 'package:streaks/purchases_bloc/purchases_event.dart';
import 'package:streaks/purchases_bloc/purchases_state.dart';
import 'package:streaks/services/share_prefs_services.dart';

class SaleOfferScreen extends StatefulWidget {
  const SaleOfferScreen({super.key});

  @override
  State<SaleOfferScreen> createState() => _SaleOfferScreenState();
}

class _SaleOfferScreenState extends State<SaleOfferScreen> {
  static const Duration _offerDuration = Duration(days: 4, hours: 4);

  Timer? _ticker;
  Duration _remaining = Duration.zero;
  DateTime? _expiry;

  @override
  void initState() {
    super.initState();
    final purchasesBloc = context.read<PurchasesBloc>();
    if (purchasesBloc.state.offerings.isEmpty &&
        !purchasesBloc.state.isLoading) {
      purchasesBloc.add(FetchOffers());
    }
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

  String? _formatSubscriptionPeriod(dynamic period) {
    if (period == null) return null;
    final iso = period.toString();
    if (iso.isEmpty) return null;
    final parsed = _parseIsoPeriod(iso);
    return parsed == null ? null : 'per $parsed';
  }

  String? _formatIntroOffer(Package? package) {
    final intro = package?.storeProduct.introductoryPrice;
    if (intro == null) return null;

    final priceText = intro.priceString;
    if (priceText.isEmpty) return null;

    final cycles = intro.cycles;
    if (cycles > 1) {
      return '$priceText for your first $cycles billing cycles';
    }

    return '$priceText introductory rate on your first renewal';
  }

  String? _parseIsoPeriod(String iso) {
    if (!iso.startsWith('P')) return null;
    final match = RegExp(r'P(\d+)([YMWD])').firstMatch(iso);
    if (match == null) return null;
    final count = int.tryParse(match.group(1) ?? '') ?? 1;
    final designator = match.group(2);
    switch (designator) {
      case 'Y':
        return count == 1 ? 'year' : '$count years';
      case 'M':
        return count == 1 ? 'month' : '$count months';
      case 'W':
        return count == 1 ? 'week' : '$count weeks';
      case 'D':
        return count == 1 ? 'day' : '$count days';
      default:
        return null;
    }
  }

  Future<void> _handleClose({
    bool openCheckout = false,
    bool? keepDismissed,
  }) async {
    final isPremium = context.read<PurchasesBloc>().state.isSubscriptionActive;
    final shouldDismiss = keepDismissed ?? isPremium;
    await SharePrefsService.setSaleOfferBannerDismissed(shouldDismiss);
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

    return Scaffold(
      body: BlocConsumer<PurchasesBloc, PurchasesState>(
        listenWhen: (previous, current) =>
            previous.isSubscriptionActive != current.isSubscriptionActive,
        listener: (context, purchasesState) async {
          if (purchasesState.isSubscriptionActive) {
            await _handleClose(keepDismissed: true);
          }
        },
        builder: (context, purchasesState) {
          final offering = purchasesState.offerings.isNotEmpty
              ? purchasesState.offerings.first
              : null;
          final salePackage = offering?.getPackage("11_nov_sale");
          final salePriceText =
              salePackage?.storeProduct.priceString ?? "\$24.99";
          final comparePriceText = offering?.annual?.storeProduct.priceString;
          final billingLabel = _formatSubscriptionPeriod(
            salePackage?.storeProduct.subscriptionPeriod,
          );
          final introOfferText = _formatIntroOffer(salePackage);
          final bool isLoading = purchasesState.isLoading;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        AppColors.darkBackgroundColor,
                        AppColors.darkBackgroundColor.withValues(alpha: 0.85),
                        AppColors.darkBackgroundColor.withValues(alpha: 0.75),
                      ]
                    : [
                        Colors.white,
                        AppColors.primaryColor.withValues(alpha: 0.12),
                        Colors.white,
                      ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      _buildHeader(isDark),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildCountdown(isDark),
                              const SizedBox(height: 24),
                              _buildSaleSummaryCard(
                                isDark: isDark,
                                salePriceText: salePriceText,
                                comparePriceText: comparePriceText,
                                billingLabel: billingLabel,
                                introOfferText: introOfferText,
                                salePackage: salePackage,
                              ),
                              const SizedBox(height: 24),
                              _buildGuaranteePanel(isDark),
                              const SizedBox(height: 28),
                              _buildPrimaryCTA(isDark, salePackage),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isLoading) _buildFullScreenLoader(isDark),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCountdown(bool isDark) {
    final formatted = _formatDuration(_remaining);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: AppColors.cardColorTheme(isDark).withValues(alpha: 0.65),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 24.0,
            color: AppColors.primaryColor,
          ),
          const SizedBox(width: 12),
          Text(
            formatted == 'Expired' ? 'Offer ended' : 'Ends in $formatted',
            style: GoogleFonts.poppins(
              fontSize: 18.0,
              fontWeight: FontWeight.w700,
              color: AppColors.textColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Black Friday Sale',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textColor(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Limited seats for this lightning drop—lock yours in now.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.greyColorTheme(isDark),
                    height: 1.4,
                  ),
                ),
              ],
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
    );
  }

  Widget _buildSaleSummaryCard({
    required bool isDark,
    required String salePriceText,
    String? comparePriceText,
    String? billingLabel,
    String? introOfferText,
    required Package? salePackage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Image.asset(
                AppAssets.saleOffer,
                height: 110,
                fit: BoxFit.contain,
              ),
            ),
            Gap(10.0),
            Text(
              'Premium for less than your coffee habit',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.whiteColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  salePriceText,
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                if (billingLabel != null)
                  Text(
                    billingLabel,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (comparePriceText != null)
          Text(
            'Usually $comparePriceText — you\'re claiming the Black Friday price.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.whiteColor.withValues(alpha: 0.75),
            ),
          ),
        if (comparePriceText != null) const SizedBox(height: 18),
        if (introOfferText != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: AppColors.darkBackgroundColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    introOfferText,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkBackgroundColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGuaranteePanel(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cardColorTheme(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.verified_user,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Cancel anytime in settings. Your progress and data remain safe even if you switch back.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.5,
                color: AppColors.greyColorTheme(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullScreenLoader(bool isDark) {
    return Container(
      color: AppColors.blackColor.withValues(alpha: 0.65),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildPrimaryCTA(bool isDark, Package? salePackage) {
    return ElevatedButton(
      onPressed: () => _handleUnlock(salePackage),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.darkBackgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        minimumSize: const Size.fromHeight(56),
        textStyle: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
      child: const Text('Subscribe Today'),
    );
  }

  Future<void> _handleUnlock(Package? salePackage) async {
    if (salePackage == null) {
      await _handleClose(openCheckout: true);
      return;
    }

    final bloc = context.read<PurchasesBloc>();
    final state = bloc.state;
    final offering = state.offerings.isNotEmpty ? state.offerings.first : null;
    final available = offering?.availablePackages ?? [];
    final index =
        available.indexWhere((pkg) => pkg.identifier == salePackage.identifier);

    bloc
      ..add(
        SelectPackage(
          salePackage,
          index >= 0 ? index : state.selectedIndex,
        ),
      )
      ..add(PurchaseSubscription(salePackage));
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
