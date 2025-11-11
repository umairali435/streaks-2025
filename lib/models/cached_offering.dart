import 'dart:convert';

import 'package:purchases_flutter/purchases_flutter.dart';

class CachedPackageInfo {
  final String identifier;
  final double price;
  final String currencyCode;
  final String priceString;

  const CachedPackageInfo({
    required this.identifier,
    required this.price,
    required this.currencyCode,
    required this.priceString,
  });

  factory CachedPackageInfo.fromPackage(Package package) {
    final product = package.storeProduct;
    return CachedPackageInfo(
      identifier: package.identifier,
      price: product.price,
      currencyCode: product.currencyCode,
      priceString: product.priceString,
    );
  }

  factory CachedPackageInfo.fromJson(Map<String, dynamic> json) {
    return CachedPackageInfo(
      identifier: json['identifier'] as String,
      price: (json['price'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String,
      priceString: json['priceString'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'price': price,
      'currencyCode': currencyCode,
      'priceString': priceString,
    };
  }
}

class CachedOffering {
  final CachedPackageInfo? weekly;
  final CachedPackageInfo? monthly;
  final CachedPackageInfo? annual;
  final DateTime lastUpdated;

  const CachedOffering({
    required this.weekly,
    required this.monthly,
    required this.annual,
    required this.lastUpdated,
  });

  factory CachedOffering.fromOffering(Offering offering) {
    return CachedOffering(
      weekly: offering.weekly != null
          ? CachedPackageInfo.fromPackage(offering.weekly!)
          : null,
      monthly: offering.monthly != null
          ? CachedPackageInfo.fromPackage(offering.monthly!)
          : null,
      annual: offering.annual != null
          ? CachedPackageInfo.fromPackage(offering.annual!)
          : null,
      lastUpdated: DateTime.now(),
    );
  }

  factory CachedOffering.fromJson(Map<String, dynamic> json) {
    return CachedOffering(
      weekly: json['weekly'] != null
          ? CachedPackageInfo.fromJson(
              Map<String, dynamic>.from(json['weekly'] as Map),
            )
          : null,
      monthly: json['monthly'] != null
          ? CachedPackageInfo.fromJson(
              Map<String, dynamic>.from(json['monthly'] as Map),
            )
          : null,
      annual: json['annual'] != null
          ? CachedPackageInfo.fromJson(
              Map<String, dynamic>.from(json['annual'] as Map),
            )
          : null,
      lastUpdated: DateTime.tryParse(json['lastUpdated'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  Map<String, dynamic> toJson() {
    return {
      'weekly': weekly?.toJson(),
      'monthly': monthly?.toJson(),
      'annual': annual?.toJson(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  static CachedOffering? fromJsonString(String? data) {
    if (data == null || data.isEmpty) return null;
    try {
      final Map<String, dynamic> decoded =
          jsonDecode(data) as Map<String, dynamic>;
      return CachedOffering.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}

