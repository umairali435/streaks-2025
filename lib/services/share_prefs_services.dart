import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharePrefsService {
  static final SharePrefsService _instance = SharePrefsService._internal();
  static late SharedPreferences _prefs;

  SharePrefsService._internal();

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharePrefsService get instance => _instance;

  static const String _key = 'isFirst';
  static const String _lastVersionKey = 'lastSeenVersion';

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
}
