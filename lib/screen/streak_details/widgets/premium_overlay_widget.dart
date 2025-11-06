import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:streaks/bloc/theme_bloc.dart';
import 'package:streaks/purchases_bloc/purchases_bloc.dart';
import 'package:streaks/purchases_bloc/purchases_state.dart';
import 'package:streaks/screen/purchases_screen.dart';

class PremiumLockedWidget extends StatelessWidget {
  final Widget child;

  const PremiumLockedWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState is ThemeLoaded ? themeState.isDark : true;
        return BlocBuilder<PurchasesBloc, PurchasesState>(
          builder: (context, state) {
            return Stack(
              children: [
                if (state.isSubscriptionActive)
                  child
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Opacity(
                        opacity: 0.2,
                        child: child,
                      ),
                    ),
                  ),
                if (!state.isSubscriptionActive)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PurchasesScreen(),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.8 : 0.75),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.crown,
                              color: Colors.white,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Unlock with Premium",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
