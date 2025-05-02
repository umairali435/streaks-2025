import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchasesState extends Equatable {
  final bool isLoading;
  final bool isSubscriptionActive;
  final List<Offering> offerings;
  final Package? selectedPackage;
  final int selectedIndex;

  const PurchasesState({
    this.isLoading = false,
    this.isSubscriptionActive = false,
    this.offerings = const [],
    this.selectedPackage,
    this.selectedIndex = 0,
  });

  PurchasesState copyWith({
    bool? isLoading,
    bool? isSubscriptionActive,
    List<Offering>? offerings,
    Package? selectedPackage,
    int? selectedIndex,
  }) {
    return PurchasesState(
      isLoading: isLoading ?? this.isLoading,
      isSubscriptionActive: isSubscriptionActive ?? this.isSubscriptionActive,
      offerings: offerings ?? this.offerings,
      selectedPackage: selectedPackage ?? this.selectedPackage,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSubscriptionActive,
        offerings,
        selectedPackage,
        selectedIndex,
      ];
}
