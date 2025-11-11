import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:streaks/models/cached_offering.dart';

class OfferingCacheService {
  static const _cacheKey = 'cached_offering_v1';

  static Future<CachedOffering?> getCachedOffering() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    return CachedOffering.fromJsonString(cached);
  }

  static Future<void> cacheOffering(Offering offering) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = CachedOffering.fromOffering(offering);
    await prefs.setString(_cacheKey, cached.toJsonString());
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}
