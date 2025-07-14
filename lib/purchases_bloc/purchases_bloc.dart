import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:streaks/database/streaks_database.dart';

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
    await _initSubscription(emit);
    add(FetchOffers());
  }

  Future<void> _initSubscription(Emitter<PurchasesState> emit) async {
    await Purchases.setLogLevel(LogLevel.debug);
    late PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration =
          PurchasesConfiguration("goog_FVrtLHMkDutnKdFqQyNdlgAonGs");
    } else {
      configuration =
          PurchasesConfiguration("appl_KVYUCljoRyvHdMLJNmTqoYPmYQT");
    }
    await Purchases.configure(configuration);

    Purchases.addCustomerInfoUpdateListener((customerInfo) async {});
    CustomerInfo info = await Purchases.getCustomerInfo();
    if (emit.isDone) {
      emit(state.copyWith(
          isSubscriptionActive: info.activeSubscriptions.isNotEmpty));
    }
  }

  Future<void> _onFetchOffers(
      FetchOffers event, Emitter<PurchasesState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current != null) {
        emit(state.copyWith(offerings: [current], isLoading: false));
        emit(state.copyWith(
          selectedPackage: current.monthly,
          selectedIndex: 0,
        ));
      }
    } on PlatformException catch (e) {
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
      await Purchases.purchasePackage(event.package);
      emit(state.copyWith(isLoading: false));
      Fluttertoast.showToast(
        msg: "Your Purchase is Successfull",
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
      );
    } on PlatformException catch (e) {
      emit(state.copyWith(isLoading: false, isSubscriptionActive: true));
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
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      bool active = customerInfo.activeSubscriptions.isNotEmpty;
      emit(state.copyWith(
        isLoading: false,
        isSubscriptionActive: active,
      ));

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
