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

  static void setFirstTime() {
    _prefs.setBool(_key, false);
  }

  static bool isFirstTime() {
    return _prefs.getBool(_key) ?? true;
  }
}
