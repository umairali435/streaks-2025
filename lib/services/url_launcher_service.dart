import 'package:url_launcher/url_launcher.dart';

class UrlLauncherService {
  static Future<void> launchURL(String url) async {
    Uri uri = Uri.parse(url);
    await launchUrl(uri);
  }
}
