import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharePrefsService {
  static final SharePrefsService _instance = SharePrefsService._internal();
  static late SharedPreferences _prefs;

  SharePrefsService._internal();

  static const String _saleOfferExpiryKey = 'saleOfferExpiry';
  static const String _saleOfferBannerDismissedKey =
      'saleOfferBannerDismissed';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharePrefsService get instance => _instance;

  static const String _key = 'isFirst';
  static const String _lastVersionKey = 'lastSeenVersion';
  static const String _firstHabitDialogKey = 'firstHabitDialogPending';

  static void setFirstTime() {
    _prefs.setBool(_key, false);
  }

  static bool isFirstTime() {
    return _prefs.getBool(_key) ?? true;
  }

  static Future<void> setLastSeenVersion(String version) async {
    await _prefs.setString(_lastVersionKey, version);
  }

  static String? getLastSeenVersion() {
    return _prefs.getString(_lastVersionKey);
  }

  static Future<bool> shouldShowWhatsNew() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;
    String? lastSeenVersion = getLastSeenVersion();

    return isFirstTime() || lastSeenVersion != currentVersion;
  }

  static Future<void> markVersionAsSeen() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    await setLastSeenVersion(packageInfo.version);
    setFirstTime();
  }

  static void setFirstHabitDialogPending() {
    _prefs.setBool(_firstHabitDialogKey, true);
  }

  static bool shouldShowFirstHabitDialog() {
    return _prefs.getBool(_firstHabitDialogKey) ?? false;
  }

  static void markFirstHabitDialogShown() {
    _prefs.setBool(_firstHabitDialogKey, false);
  }

  static DateTime? getSaleOfferExpiry() {
    final milliseconds = _prefs.getInt(_saleOfferExpiryKey);
    if (milliseconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  static Future<DateTime> ensureSaleOfferExpiry(Duration duration) async {
    final now = DateTime.now();
    final currentExpiry = getSaleOfferExpiry();

    if (currentExpiry == null || currentExpiry.isBefore(now)) {
      final newExpiry = now.add(duration);
      await _prefs.setInt(
        _saleOfferExpiryKey,
        newExpiry.millisecondsSinceEpoch,
      );
      await _prefs.setBool(_saleOfferBannerDismissedKey, false);
      return newExpiry;
    }

    return currentExpiry;
  }

  static Future<void> clearSaleOfferExpiry() async {
    await _prefs.remove(_saleOfferExpiryKey);
  }

  static bool isSaleOfferBannerDismissed() {
    return _prefs.getBool(_saleOfferBannerDismissedKey) ?? false;
  }

  static Future<void> setSaleOfferBannerDismissed(bool dismissed) async {
    await _prefs.setBool(_saleOfferBannerDismissedKey, dismissed);
  }
}
