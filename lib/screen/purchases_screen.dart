import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:streaks/purchases_bloc/purchases_bloc.dart';
import 'package:streaks/purchases_bloc/purchases_event.dart';
import 'package:streaks/purchases_bloc/purchases_state.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/screen/streak_details/widgets/custom_loading_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _floatingController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    context.read<PurchasesBloc>().add(InitPurchases());

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _floatingAnimation = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
    _floatingController.repeat(reverse: true);
    _particleController.repeat();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _floatingController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [
              AppColors.primaryColor.withValues(alpha: 0.15),
              AppColors.primaryColor.withValues(alpha: 0.05),
              Colors.black,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Floating particles background
            ...List.generate(12, (index) => _buildFloatingParticle(index)),

            // Main content
            SafeArea(
              child: BlocBuilder<PurchasesBloc, PurchasesState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      // Custom App Bar
                      _buildCustomAppBar(),

                      state.isSubscriptionActive
                          ? Expanded(child: _buildAlreadySubscribedView())
                          : Expanded(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  _buildPurchaseContent(state),
                                  if (state.isLoading) _buildLoadingOverlay(),
                                ],
                              ),
                            ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final double animationValue =
            (_particleController.value + index * 0.08) % 1.0;
        final double x =
            30 + (index * 35.0) % MediaQuery.of(context).size.width;
        final double y =
            MediaQuery.of(context).size.height * (1 - animationValue);

        return Positioned(
          left: x,
          top: y,
          child: Opacity(
            opacity: 0.4,
            child: Container(
              width: 3 + (index % 4) * 1.5,
              height: 3 + (index % 4) * 1.5,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.6),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomAppBar() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  LucideIcons.chevronLeft,
                  color: AppColors.whiteColor,
                  size: 20,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'Premium Upgrade',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 44), // Balance the back button
          ],
        ),
      ),
    );
  }

  Widget _buildAlreadySubscribedView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatingAnimation.value),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(80),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.5),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    LucideIcons.crown,
                    color: Colors.black,
                    size: 60,
                  ),
                ),
                const Gap(30),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.white,
                      AppColors.primaryColor,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    "Welcome to Premium!",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Gap(15),
                Text(
                  "You're all set with unlimited access",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey.shade300,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPurchaseContent(PurchasesState state) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const Gap(20),
                _buildHeroSection(),
                const Gap(30),
                const Packages(),
                const Gap(30),
                _buildPurchaseButton(state),
                const Gap(20),
                _buildRestoreButton(),
                const Gap(20),
                const BillingInfoWidget(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroSection() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryColor.withValues(alpha: 0.2),
                  AppColors.primaryColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppColors.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                Positioned(
                  left: -30,
                  bottom: -30,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
                // Content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          LucideIcons.sparkles,
                          color: AppColors.primaryColor,
                          size: 30,
                        ),
                      ),
                      const Gap(20),
                      Text(
                        'Unlock Premium Features',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
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
        );
      },
    );
  }

  Widget _buildPurchaseButton(PurchasesState state) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            if (state.selectedPackage != null) {
              context
                  .read<PurchasesBloc>()
                  .add(PurchaseSubscription(state.selectedPackage!));
            } else {
              Fluttertoast.showToast(
                msg: "Select one package",
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.red,
              );
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.creditCard,
                  color: Colors.black,
                  size: 24,
                ),
                const Gap(12),
                Text(
                  // state.selectedIndex == 0
                  //     ? "Start Free Trial"
                  //     : "Buy Subscription",
                  "Buy Subscription",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRestoreButton() {
    return TextButton(
      onPressed: () async {
        context.read<PurchasesBloc>().add(RestoreSubscription());
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.rotateCw,
            color: AppColors.primaryColor,
            size: 20,
          ),
          const Gap(8),
          Text(
            "Restore Purchases",
            style: GoogleFonts.poppins(
              color: AppColors.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor.withValues(alpha: 0.2),
                AppColors.primaryColor.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: const CustomLoadingWidget(),
        ),
      ),
    );
  }
}

class Packages extends StatefulWidget {
  const Packages({super.key});

  @override
  State<Packages> createState() => _PackagesState();
}

class _PackagesState extends State<Packages> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double calculateSavingsPercentage(double weeklyPrice, double yearlyPrice) {
    double totalWeeklyCost = weeklyPrice * 52;
    double savings = 1 - (yearlyPrice / totalWeeklyCost);
    return savings * 100;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchasesBloc, PurchasesState>(
      builder: (context, state) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            children: state.offerings.map(
              (offers) {
                int percentage = calculateSavingsPercentage(
                  offers.weekly?.storeProduct.price ?? 0.0,
                  offers.annual?.storeProduct.price ?? 0.0,
                ).toInt();
                return Column(
                  children: [
                    PackagesWidgets(
                      title: "WEEKLY PLAN",
                      subtitle:
                          "${offers.weekly?.storeProduct.currencyCode} ${offers.weekly?.storeProduct.price.toStringAsFixed(2)} / Week",
                      showTryForFree: false,
                      selectedPackage: state.selectedIndex == 0 ? true : false,
                      showPercentage: false,
                      onTap: () async {
                        context
                            .read<PurchasesBloc>()
                            .add(SelectPackage(offers.weekly!, 0));
                      },
                    ),
                    const Gap(15),
                    PackagesWidgets(
                      title: "YEARLY PLAN",
                      subtitle:
                          "${offers.annual?.storeProduct.currencyCode} ${offers.annual?.storeProduct.price.toStringAsFixed(2)} / Year",
                      oldPrice:
                          "${offers.annual?.storeProduct.currencyCode} ${((offers.monthly?.storeProduct.price ?? 0.0) * 12).toStringAsFixed(2)}",
                      showTryForFree: false,
                      selectedPackage: state.selectedIndex == 1 ? true : false,
                      showPercentage: true,
                      percentage: percentage.toInt().toString(),
                      onTap: () async {
                        context
                            .read<PurchasesBloc>()
                            .add(SelectPackage(offers.annual!, 1));
                      },
                    ),
                  ],
                );
              },
            ).toList(),
          ),
        );
      },
    );
  }
}

class OfferingWidget extends StatelessWidget {
  const OfferingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Colors.white,
              AppColors.primaryColor,
            ],
          ).createShader(bounds),
          child: Text(
            'Upgrade to Premium',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Gap(15),
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            'Unlock unlimited habits, advanced analytics, detailed calendar views, custom themes and priority support',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade300,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class PackagesWidgets extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? oldPrice;
  final bool showTryForFree;
  final bool selectedPackage;
  final bool showPercentage;
  final String percentage;
  final VoidCallback onTap;

  const PackagesWidgets({
    super.key,
    required this.title,
    required this.subtitle,
    required this.showTryForFree,
    this.oldPrice,
    required this.selectedPackage,
    this.showPercentage = true,
    this.percentage = "",
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            gradient: selectedPackage
                ? LinearGradient(
                    colors: [
                      AppColors.primaryColor.withValues(alpha: 0.2),
                      AppColors.primaryColor.withValues(alpha: 0.1),
                    ],
                  )
                : null,
            color:
                selectedPackage ? null : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selectedPackage
                  ? AppColors.primaryColor
                  : Colors.grey.withValues(alpha: 0.3),
              width: selectedPackage ? 2 : 1,
            ),
            boxShadow: selectedPackage
                ? [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  if (showTryForFree)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: selectedPackage
                              ? [
                                  AppColors.primaryColor,
                                  AppColors.primaryColor.withValues(alpha: 0.8),
                                ]
                              : [
                                  Colors.grey.shade800,
                                  Colors.grey.shade700,
                                ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.gift,
                            color:
                                selectedPackage ? Colors.black : Colors.white,
                            size: 16,
                          ),
                          const Gap(5),
                          Text(
                            "Try for free",
                            style: GoogleFonts.poppins(
                              color:
                                  selectedPackage ? Colors.black : Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(8),
                        Row(
                          children: [
                            if (oldPrice != null) ...[
                              Text(
                                "$oldPrice ",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade500,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: AppColors.primaryColor,
                                  decorationThickness: 2.0,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                            Text(
                              subtitle,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Gap(10.0),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (showPercentage)
                Positioned(
                  top: 10,
                  right: 15,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.primaryColor.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      "Save $percentage%",
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              if (selectedPackage)
                Positioned(
                  bottom: 20.0,
                  right: 10.0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: AppColors.primaryColor, shape: BoxShape.circle),
                    child: Icon(
                      LucideIcons.check,
                      color: Colors.black,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class BillingInfoWidget extends StatefulWidget {
  const BillingInfoWidget({super.key});

  @override
  State<BillingInfoWidget> createState() => _BillingInfoWidgetState();
}

class _BillingInfoWidgetState extends State<BillingInfoWidget> {
  Future<void> _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchasesBloc, PurchasesState>(
      builder: (context, state) {
        return Column(
          children: [
            Text(
              // state.selectedIndex == 0
              // ? state.offerings.isNotEmpty
              // ? "3 days free trial, then ${state.offerings[0].monthly?.storeProduct.currencyCode} ${state.offerings[0].monthly?.storeProduct.price.toStringAsFixed(2)} / Month. Cancel anytime before trial ends."
              // : ""
              // :
              "Auto renewable subscription. Cancel anytime from your account settings.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade400,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const Gap(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegalButton(
                  "Privacy Policy",
                  LucideIcons.shield,
                  () => _launchURL(
                      "https://earningstrackerapp.blogspot.com/2024/08/sawizier-earnings-tracker-privacy-policy.html"),
                ),
                _buildLegalButton(
                  "Terms of Use",
                  LucideIcons.fileText,
                  () => _launchURL(
                      "https://earningstrackerapp.blogspot.com/2024/11/sawizier-terms-of-use.html"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegalButton(String text, IconData icon, VoidCallback onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: AppColors.primaryColor,
        size: 16,
      ),
      label: Text(
        text,
        style: GoogleFonts.poppins(
          color: AppColors.primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      ),
    );
  }
}
