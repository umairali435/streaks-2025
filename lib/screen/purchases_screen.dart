import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:streaks/bloc/theme_bloc.dart';
import 'package:streaks/models/cached_offering.dart';
import 'package:streaks/purchases_bloc/purchases_bloc.dart';
import 'package:streaks/purchases_bloc/purchases_event.dart';
import 'package:streaks/purchases_bloc/purchases_state.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/screen/sale_offer_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  @override
  void initState() {
    super.initState();
    final purchasesBloc = context.read<PurchasesBloc>();
    if (purchasesBloc.state.offerings.isEmpty) {
      purchasesBloc
          .add(const FetchOffers(forceRefresh: true, showLoading: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState is ThemeLoaded ? themeState.isDark : true;
        return Scaffold(
          backgroundColor: AppColors.backgroundColor(isDark),
          body: SafeArea(
            child: BlocConsumer<PurchasesBloc, PurchasesState>(
              listener: (context, state) {
                if (state.isSubscriptionActive) {
                  // If needed, navigate or show success
                }
              },
              builder: (context, state) {
                return Column(
                  children: [
                    state.isSubscriptionActive
                        ? Expanded(child: Subscribed(isDark: isDark))
                        : Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ListView(
                                  padding: EdgeInsets.zero,
                                  children: [
                                    const Gap(20.0),
                                    Align(
                                      alignment: Alignment.center,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        child: Image.asset(
                                          "assets/app_icon.png",
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.10,
                                        ),
                                      ),
                                    ),
                                    const Gap(20.0),
                                    OfferingWidget(isDark: isDark),
                                    Packages(isDark: isDark),
                                    const Gap(10.0),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 8.0,
                                      ),
                                      child: _CustomButton(
                                        title: "Buy Subscription",
                                        onPressed: () {
                                          if (state.selectedPackage != null) {
                                            context.read<PurchasesBloc>().add(
                                                  PurchaseSubscription(
                                                      state.selectedPackage!),
                                                );
                                          } else {
                                            Fluttertoast.showToast(
                                              msg: "Select one package",
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.red,
                                            );
                                          }
                                        },
                                        isDark: isDark,
                                      ),
                                    ),
                                    TextButton(
                                      child: Text(
                                        "Restore Purchases",
                                        style: TextStyle(
                                            color: AppColors.primaryColor),
                                      ),
                                      onPressed: () {
                                        context
                                            .read<PurchasesBloc>()
                                            .add(RestoreSubscription());
                                      },
                                    ),
                                    BillingInfoWidget(isDark: isDark),
                                  ],
                                ),
                                if (state.isLoading)
                                  Container(
                                    padding: const EdgeInsets.all(20.0),
                                    decoration: BoxDecoration(
                                      color: AppColors.cardColorTheme(isDark),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    child: CircularProgressIndicator(
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                Positioned(
                                  top: 10.0,
                                  right: 10.0,
                                  child: IconButton(
                                    icon: Icon(
                                      LucideIcons.x,
                                      color: AppColors.textColor(isDark),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pushReplacement(
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              const SaleOfferScreen(),
                                          transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) =>
                                              FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class Packages extends StatefulWidget {
  final bool isDark;
  const Packages({super.key, required this.isDark});

  @override
  State<Packages> createState() => _PackagesState();
}

class _PackagesState extends State<Packages> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectInitialOffer();
    });
  }

  void _selectInitialOffer() {
    // Initial selection logic is handled in Bloc, but we can ensure here if needed
  }

  double calculateSavingsPercentage(double weeklyPrice, double yearlyPrice) {
    if (weeklyPrice <= 0) return 0;
    double totalWeeklyCost = weeklyPrice * 52;
    double savings = 1 - (yearlyPrice / totalWeeklyCost);
    return savings * 100;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchasesBloc, PurchasesState>(
      builder: (context, state) {
        if (state.offerings.isEmpty) {
          if (state.cachedOffering != null) {
            return _buildCachedPackages(
                context, state.cachedOffering!, widget.isDark);
          }
          return SizedBox(
            height: 200.0,
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            ),
          );
        }

        final offering = state.offerings.first;
        return _buildRealPackages(context, offering, state, widget.isDark);
      },
    );
  }

  Widget _buildRealPackages(BuildContext context, Offering offering,
      PurchasesState state, bool isDark) {
    final weekly = offering.weekly;
    final annual = offering.annual;

    if (weekly == null || annual == null) {
      return const SizedBox.shrink();
    }

    int percentage = calculateSavingsPercentage(
      weekly.storeProduct.price,
      annual.storeProduct.price,
    ).toInt();

    return Column(
      children: [
        PackagesWidgets(
          title: "YEARLY PLAN",
          subtitle: "${annual.storeProduct.priceString} per year",
          showTryForFree: false,
          selectedPackage: state.selectedIndex == 0,
          showPercentage: true,
          percentage: percentage.toString(),
          isDark: isDark,
          onTap: () {
            context.read<PurchasesBloc>().add(SelectPackage(annual, 0));
          },
        ),
        PackagesWidgets(
          title: "WEEKLY PLAN",
          subtitle: "${weekly.storeProduct.priceString} per week",
          showTryForFree: false,
          selectedPackage: state.selectedIndex == 1,
          showPercentage: false,
          isDark: isDark,
          onTap: () {
            context.read<PurchasesBloc>().add(SelectPackage(weekly, 1));
          },
        ),
      ],
    );
  }

  Widget _buildCachedPackages(
      BuildContext context, CachedOffering offering, bool isDark) {
    final weekly = offering.weekly;
    final annual = offering.annual;

    if (weekly == null || annual == null) {
      return const SizedBox.shrink();
    }

    int percentage = calculateSavingsPercentage(
      weekly.price,
      annual.price,
    ).toInt();

    return Column(
      children: [
        PackagesWidgets(
          title: "YEARLY PLAN",
          subtitle: "${annual.priceString} per year",
          showTryForFree: false,
          selectedPackage: false,
          showPercentage: true,
          percentage: percentage.toString(),
          isDark: isDark,
          onTap: () {},
        ),
        PackagesWidgets(
          title: "WEEKLY PLAN",
          subtitle: "${weekly.priceString} per week",
          showTryForFree: false,
          selectedPackage: false,
          showPercentage: false,
          isDark: isDark,
          onTap: () {},
        ),
      ],
    );
  }
}

class OfferingWidget extends StatelessWidget {
  final bool isDark;
  const OfferingWidget({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    List<String> benefits = [
      "Unlimited Habits",
      "Advanced Analytics",
      "Detailed Calendar Views",
      "Heatmap Views",
      "Custom Themes",
    ];

    List<IconData> benefitsIcons = [
      LucideIcons.infinity,
      LucideIcons.barChart2,
      LucideIcons.calendar,
      LucideIcons.layoutGrid,
      LucideIcons.palette,
    ];

    return Column(
      children: [
        Text(
          'Upgrade to Premium',
          style: TextStyle(
            color: AppColors.textColor(isDark),
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(20.0),
        Center(
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: benefits.asMap().entries.map((entry) {
                int index = entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(benefitsIcons[index], color: AppColors.primaryColor),
                      const Gap(10.0),
                      Text(
                        benefits[index],
                        style: TextStyle(
                          fontSize: 16.0,
                          color: AppColors.textColor(isDark),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const Gap(10.0),
      ],
    );
  }
}

class PackagesWidgets extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showTryForFree;
  final bool selectedPackage;
  final bool showPercentage;
  final String percentage;
  final VoidCallback onTap;
  final bool isDark;

  const PackagesWidgets({
    super.key,
    required this.title,
    required this.subtitle,
    required this.showTryForFree,
    required this.selectedPackage,
    this.showPercentage = true,
    this.percentage = "",
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: selectedPackage
                      ? AppColors.primaryColor.withValues(alpha: 0.1)
                      : AppColors.cardColorTheme(isDark),
                  border: Border.all(
                    color:
                        selectedPackage ? AppColors.primaryColor : Colors.grey,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  color: AppColors.textColor(isDark),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  color: AppColors.textColor(isDark),
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (showPercentage)
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                    vertical: 8.0,
                                  ),
                                  margin: const EdgeInsets.only(right: 10.0),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Text(
                                    "Save $percentage%",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color:
                                          isDark ? Colors.black : Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          Container(
                            height: 24.0,
                            width: 24.0,
                            decoration: BoxDecoration(
                              color: selectedPackage
                                  ? AppColors.primaryColor
                                  : null,
                              shape: BoxShape.circle,
                              border: selectedPackage
                                  ? null
                                  : Border.all(color: Colors.grey, width: 2.0),
                            ),
                            child: selectedPackage
                                ? Icon(
                                    LucideIcons.check,
                                    size: 16.0,
                                    color: isDark ? Colors.black : Colors.white,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BillingInfoWidget extends StatefulWidget {
  final bool isDark;
  const BillingInfoWidget({super.key, required this.isDark});

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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () async {
                _launchURL(
                  "https://streaks2025.blogspot.com/2025/01/privacy-policy.html",
                );
              },
              child: const Text(
                "Privacy Policy",
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _launchURL(
                  "https://streaks2025.blogspot.com/2025/11/streaks-2025-terms-of-use.html",
                );
              },
              child: const Text(
                "Terms of Use",
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30.0),
      ],
    );
  }
}

class Subscribed extends StatelessWidget {
  final bool isDark;
  const Subscribed({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    List<String> benefits = [
      "Unlimited Habits",
      "Advanced Analytics",
      "Detailed Calendar Views",
      "Heatmap Views",
      "Custom Themes",
    ];
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.crown,
              color: AppColors.primaryColor,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "🎉 Welcome to PRO!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor(isDark),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "You now have access to all premium features",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardColorTheme(isDark),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: benefits
                  .map(
                    (benefit) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.checkCircle,
                            color: AppColors.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              benefit,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textColor(isDark),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: isDark ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 4,
            ),
            child: const Text(
              "Start Exploring 🚀",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final bool isDark;

  const _CustomButton({
    required this.title,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }
}
