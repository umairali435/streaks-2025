import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:streaks/database/streaks_database.dart';
import 'package:streaks/models/cached_offering.dart';
import 'package:streaks/services/offering_cache_service.dart';
import 'package:streaks/services/share_prefs_services.dart';
import 'package:streaks/services/purchases_initializer.dart';

import 'purchases_event.dart';
import 'purchases_state.dart';

class PurchasesBloc extends Bloc<PurchasesEvent, PurchasesState> {
  PurchasesBloc() : super(const PurchasesState()) {
    on<InitPurchases>(_onInit);
    on<FetchOffers>(_onFetchOffers);
    on<PurchaseSubscription>(_onPurchase);
    on<RestoreSubscription>(_onRestore);
    on<SelectPackage>(_onSelectPackage);
    on<TotalAddedStreaks>(_onFetchStreaksLength);
  }

  Future<void> _onInit(
      InitPurchases event, Emitter<PurchasesState> emit) async {
    final cached = await OfferingCacheService.getCachedOffering();
    if (cached != null) {
      emit(state.copyWith(cachedOffering: cached));
    }
    await _initSubscription(emit);
    add(const FetchOffers());
  }

  Future<void> _initSubscription(Emitter<PurchasesState> emit) async {
    await PurchasesInitializer.ensureConfigured();

    Purchases.addCustomerInfoUpdateListener((customerInfo) async {});
    CustomerInfo info = await Purchases.getCustomerInfo();
    if (info.activeSubscriptions.isNotEmpty) {
      await SharePrefsService.setSaleOfferBannerDismissed(true);
    }

    bool active = info.activeSubscriptions.isNotEmpty;
    emit(
      state.copyWith(
        isSubscriptionActive: active,
        isSubscriptionStatusLoaded: true,
      ),
    );
  }

  Future<void> _onFetchOffers(
      FetchOffers event, Emitter<PurchasesState> emit) async {
    if (!event.forceRefresh && state.offerings.isNotEmpty) {
      return;
    }

    try {
      await PurchasesInitializer.ensureConfigured();
      if (event.showLoading) {
        emit(state.copyWith(isLoading: true));
      }
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;

      if (current != null) {
        await OfferingCacheService.cacheOffering(current);
        final CachedOffering cached = CachedOffering.fromOffering(current);
        final Package? defaultPackage = current.weekly ??
            current.annual ??
            current.monthly ??
            (current.availablePackages.isNotEmpty
                ? current.availablePackages.first
                : null);
        final int defaultIndex =
            defaultPackage == null || defaultPackage == current.weekly ? 0 : 1;
        emit(state.copyWith(
          offerings: [current],
          isLoading: false,
          cachedOffering: cached,
          selectedPackage: defaultPackage,
          selectedIndex: defaultIndex,
        ));
      } else if (event.showLoading) {
        emit(state.copyWith(isLoading: false));
      }
    } on PlatformException catch (e) {
      if (event.showLoading) {
        emit(state.copyWith(isLoading: false));
      }
      Fluttertoast.showToast(
        msg: e.message.toString(),
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _onFetchStreaksLength(
      TotalAddedStreaks event, Emitter<PurchasesState> emit) async {
    final streaks = await StreaksDatabase.getAllStreaksLength();
    emit(state.copyWith(totalStreaksLength: streaks));
  }

  Future<void> _onPurchase(
      PurchaseSubscription event, Emitter<PurchasesState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await PurchasesInitializer.ensureConfigured();
      await Purchases.purchasePackage(event.package);
      await SharePrefsService.setSaleOfferBannerDismissed(true);
      emit(state.copyWith(
        isLoading: false,
        isSubscriptionActive: true,
        isSubscriptionStatusLoaded: true,
      ));
      Fluttertoast.showToast(
        msg: "Your Purchase is Successfull",
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
      );
    } on PlatformException catch (e) {
      emit(state.copyWith(isLoading: false));
      Fluttertoast.showToast(
        msg: e.message.toString(),
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _onRestore(
      RestoreSubscription event, Emitter<PurchasesState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await PurchasesInitializer.ensureConfigured();
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      bool active = customerInfo.activeSubscriptions.isNotEmpty;
      emit(state.copyWith(
        isLoading: false,
        isSubscriptionActive: active,
        isSubscriptionStatusLoaded: true,
      ));
      if (active) {
        await SharePrefsService.setSaleOfferBannerDismissed(true);
      }

      if (!active) {
        Fluttertoast.showToast(
          msg: "No active subscription",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
        );
      }
    } on PlatformException catch (e) {
      emit(state.copyWith(isLoading: false));
      Fluttertoast.showToast(
        msg: e.message.toString(),
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _onSelectPackage(
      SelectPackage event, Emitter<PurchasesState> emit) async {
    emit(state.copyWith(
      selectedPackage: event.package,
      selectedIndex: event.index,
    ));
  }
}
