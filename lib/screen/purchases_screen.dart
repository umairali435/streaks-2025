import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:streaks/purchases_bloc/purchases_bloc.dart';
import 'package:streaks/purchases_bloc/purchases_event.dart';
import 'package:streaks/purchases_bloc/purchases_state.dart';
import 'package:streaks/res/colors.dart';
import 'package:streaks/screen/streak_details/widgets/custom_button.dart';
import 'package:streaks/screen/streak_details/widgets/custom_loading_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  @override
  void initState() {
    context.read<PurchasesBloc>().add(InitPurchases());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<PurchasesBloc, PurchasesState>(
          listener: (context, state) {
            if (state.isSubscriptionActive) {
              Navigator.pop(context);
            }
          },
          child: BlocBuilder<PurchasesBloc, PurchasesState>(
            builder: (context, state) {
              return Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        LucideIcons.chevronLeft,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                  state.isSubscriptionActive
                      ? Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.crown,
                                color: AppColors.primaryColor,
                              ),
                              Text(
                                "You are Subscribe to PRO",
                                style: TextStyle(
                                  fontSize: 22.0,
                                  color: AppColors.whiteColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ListView(
                                padding: EdgeInsets.zero,
                                children: [
                                  Image.asset(
                                    'assets/subscription_image.png',
                                    height: MediaQuery.of(context).size.height *
                                        0.30,
                                  ),
                                  const OfferingWidget(),
                                  const Packages(),
                                  const Gap(10.0),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 50.0),
                                    child: CustomButton(
                                      radius: 25.0,
                                      margin: 5.0,
                                      label: state.selectedIndex == 0
                                          ? "Start Free Trial"
                                          : "Buy Subscription",
                                      onTap: () async {
                                        if (state.selectedPackage != null) {
                                          context.read<PurchasesBloc>().add(
                                              PurchaseSubscription(
                                                  state.selectedPackage!));
                                        } else {
                                          Fluttertoast.showToast(
                                            msg: "Select one package",
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Colors.red,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  TextButton(
                                    child: Text(
                                      "Restore Purchases",
                                      style: TextStyle(
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    onPressed: () async {
                                      context
                                          .read<PurchasesBloc>()
                                          .add(RestoreSubscription());
                                    },
                                  ),
                                  BillingInfoWidget(),
                                ],
                              ),
                              state.isLoading
                                  ? Container(
                                      padding: const EdgeInsets.all(20.0),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryColor,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                      child: const CustomLoadingWidget(),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                ],
              );
            },
          ),
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

class _PackagesState extends State<Packages> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchasesBloc, PurchasesState>(
      builder: (context, state) {
        return Column(
          children: state.offerings.map(
            (offers) {
              return Column(
                children: [
                  PackagesWidgets(
                    title: "3 Days Free Trail",
                    subtitle:
                        "then ${offers.monthly?.storeProduct.currencyCode} ${offers.monthly?.storeProduct.price.toStringAsFixed(2)} / Month",
                    showTryForFree: true,
                    selectedPackage: state.selectedIndex == 0 ? true : false,
                    showPercentage: false,
                    onTap: () async {
                      context
                          .read<PurchasesBloc>()
                          .add(SelectPackage(offers.monthly!, 0));
                    },
                  ),
                  PackagesWidgets(
                    title: "YEARLY",
                    subtitle:
                        "${offers.annual?.storeProduct.currencyCode} ${offers.annual?.storeProduct.price.toStringAsFixed(2)} / Year",
                    oldPrice:
                        "${offers.annual?.storeProduct.currencyCode} ${((offers.monthly?.storeProduct.price ?? 0.0) * 12).toStringAsFixed(2)}",
                    showTryForFree: false,
                    selectedPackage: state.selectedIndex == 1 ? true : false,
                    showPercentage: true,
                    percentage: "50",
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
        const Text(
          'Upgrade to Premium',
          style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Unlock all features, unlimited streaks, statistics, export & import your data and more',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.greyColor,
              fontSize: 14.0,
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
    return InkWell(
      splashColor: AppColors.primaryColor.withAlpha(50),
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: double.infinity,
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: selectedPackage
                        ? AppColors.primaryColor
                        : AppColors.greyColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showTryForFree)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: selectedPackage
                              ? AppColors.primaryColor
                              : AppColors.secondaryColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6.0),
                            topRight: Radius.circular(6.0),
                          ),
                        ),
                        child: Text(
                          "Try for free",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.blackColor,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: AppColors.whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          Row(
                            children: [
                              if (oldPrice != null)
                                Text(
                                  "$oldPrice ",
                                  style: TextStyle(
                                    color: AppColors.whiteColor,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: AppColors.primaryColor,
                                    decorationThickness: 3.0,
                                    fontSize: 14.0,
                                  ),
                                ),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (showPercentage)
                Container(
                  height: 20.0,
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  margin: const EdgeInsets.only(right: 30.0),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    "Save $percentage%",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.blackColor,
                    ),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                state.selectedIndex == 0
                    ? state.offerings.isNotEmpty
                        ? "3 days free trial, then ${state.offerings[0].monthly?.storeProduct.currencyCode} ${state.offerings[0].monthly?.storeProduct.price.toStringAsFixed(2)} / Month cancel anytime before trial ends"
                        : ""
                    : "Auto Renewable, Cancel Anytime",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.greyColor,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () async {
                    _launchURL(
                        "https://earningstrackerapp.blogspot.com/2024/08/sawizier-earnings-tracker-privacy-policy.html");
                  },
                  child: Text(
                    "Privacy Policy",
                    style: TextStyle(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await _launchURL(
                        "https://earningstrackerapp.blogspot.com/2024/11/sawizier-terms-of-use.html");
                  },
                  child: Text(
                    "Terms of Use",
                    style: TextStyle(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30.0,
            ),
          ],
        );
      },
    );
  }
}
