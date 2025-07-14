import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchasesState extends Equatable {
  final bool isLoading;
  final bool isSubscriptionActive;
  final List<Offering> offerings;
  final Package? selectedPackage;
  final int selectedIndex;
  final int totalStreaksLength;

  const PurchasesState({
    this.isLoading = false,
    this.isSubscriptionActive = true,
    this.offerings = const [],
    this.selectedPackage,
    this.selectedIndex = 0,
    this.totalStreaksLength = 0,
  });

  PurchasesState copyWith(
      {bool? isLoading,
      bool? isSubscriptionActive,
      List<Offering>? offerings,
      Package? selectedPackage,
      int? selectedIndex,
      int? totalStreaksLength}) {
    return PurchasesState(
      isLoading: isLoading ?? this.isLoading,
      isSubscriptionActive: isSubscriptionActive ?? this.isSubscriptionActive,
      offerings: offerings ?? this.offerings,
      selectedPackage: selectedPackage ?? this.selectedPackage,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      totalStreaksLength: totalStreaksLength ?? this.totalStreaksLength,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSubscriptionActive,
        offerings,
        selectedPackage,
        selectedIndex,
        totalStreaksLength,
      ];
}
