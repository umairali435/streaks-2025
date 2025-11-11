import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';

/// Centralizes RevenueCat configuration to guarantee we only configure once
/// before any Purchases API calls happen.
class PurchasesInitializer {
  PurchasesInitializer._();

  static Future<void>? _initializing;
  static bool _isConfigured = false;

  /// Ensures that [Purchases.configure] has been invoked.
  static Future<void> ensureConfigured() {
    if (_isConfigured) {
      return Future.value();
    }
    return _initializing ??= _configure();
  }

  static Future<void> _configure() async {
    if (_isConfigured) return;

    await Purchases.setLogLevel(LogLevel.debug);

    final configuration = Platform.isAndroid
        ? PurchasesConfiguration("goog_whruziDKNFJomxFBXTXiisBKHBR")
        : PurchasesConfiguration("appl_KVYUCljoRyvHdMLJNmTqoYPmYQT");

    await Purchases.configure(configuration);

    _isConfigured = true;
  }
}



