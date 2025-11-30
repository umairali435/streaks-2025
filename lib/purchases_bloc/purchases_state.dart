import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:streaks/models/cached_offering.dart';

class PurchasesState extends Equatable {
  final bool isLoading;
  final bool isSubscriptionActive;
  final bool isSubscriptionStatusLoaded;
  final List<Offering> offerings;
  final Package? selectedPackage;
  final int selectedIndex;
  final int totalStreaksLength;
  final CachedOffering? cachedOffering;

  const PurchasesState({
    this.isLoading = false,
    this.isSubscriptionActive = false,
    this.isSubscriptionStatusLoaded = false,
    this.offerings = const [],
    this.selectedPackage,
    this.selectedIndex = 0,
    this.totalStreaksLength = 0,
    this.cachedOffering,
  });

  PurchasesState copyWith(
      {bool? isLoading,
      bool? isSubscriptionActive,
      bool? isSubscriptionStatusLoaded,
      List<Offering>? offerings,
      Package? selectedPackage,
      int? selectedIndex,
      int? totalStreaksLength,
      CachedOffering? cachedOffering}) {
    return PurchasesState(
      isLoading: isLoading ?? this.isLoading,
      isSubscriptionActive: isSubscriptionActive ?? this.isSubscriptionActive,
      isSubscriptionStatusLoaded:
          isSubscriptionStatusLoaded ?? this.isSubscriptionStatusLoaded,
      offerings: offerings ?? this.offerings,
      selectedPackage: selectedPackage ?? this.selectedPackage,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      totalStreaksLength: totalStreaksLength ?? this.totalStreaksLength,
      cachedOffering: cachedOffering ?? this.cachedOffering,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSubscriptionActive,
        isSubscriptionStatusLoaded,
        offerings,
        selectedPackage,
        selectedIndex,
        totalStreaksLength,
        cachedOffering,
      ];
}
