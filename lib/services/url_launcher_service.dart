import 'package:url_launcher/url_launcher.dart';

class UrlLauncherService {
  static Future<void> launchUrl(String url) async {
    await canLaunchUrl(Uri.parse(url)) ? await launchUrl(url) : throw 'Could not launch $url';
  }
}
