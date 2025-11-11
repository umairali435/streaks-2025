import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

abstract class PurchasesEvent extends Equatable {
  const PurchasesEvent();

  @override
  List<Object?> get props => [];
}

class InitPurchases extends PurchasesEvent {}

class FetchOffers extends PurchasesEvent {
  final bool showLoading;
  final bool forceRefresh;

  const FetchOffers({this.showLoading = true, this.forceRefresh = false});

  @override
  List<Object?> get props => [showLoading, forceRefresh];
}

class PurchaseSubscription extends PurchasesEvent {
  final Package package;

  const PurchaseSubscription(this.package);

  @override
  List<Object?> get props => [package];
}

class RestoreSubscription extends PurchasesEvent {}

class SelectPackage extends PurchasesEvent {
  final Package package;
  final int index;

  const SelectPackage(this.package, this.index);

  @override
  List<Object?> get props => [package, index];
}

class TotalAddedStreaks extends PurchasesEvent {
  final int length;

  const TotalAddedStreaks(this.length);

  @override
  List<Object?> get props => [length];
}
