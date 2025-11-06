import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';

class ScreenshotService {
  final ScreenshotController _controller = ScreenshotController();

  ScreenshotController get controller => _controller;

  /// Save widget screenshot to gallery using `gallery_saver_plus`
  Future<void> captureAndSaveToGallery() async {
    try {
      if (Platform.isIOS) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          Fluttertoast.showToast(msg: "Storage permission denied");
          return;
        }
      }

      Uint8List? imageBytes = await _controller.capture();
      if (imageBytes == null) throw Exception("Capture failed");

      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath)..writeAsBytesSync(imageBytes);

      final saved = await GallerySaver.saveImage(imageFile.path);
      if (saved == true) {
        Fluttertoast.showToast(msg: "📸 Screenshot saved to gallery");
      } else {
        Fluttertoast.showToast(msg: "❌ Failed to save screenshot");
      }
    } catch (e) {
      debugPrint("Error saving screenshot: $e");
      Fluttertoast.showToast(msg: "❌ Error saving screenshot");
    }
  }

  /// Share screenshot of the widget
  Future<void> captureAndShare() async {
    try {
      Uint8List? imageBytes = await _controller.capture();
      if (imageBytes == null) throw Exception("Capture failed");

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/screenshot.png').create();
      await file.writeAsBytes(imageBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text:
              "🔥 Check out my streak progress! 💪\n\nJoin me and start building your own streaks with Streaks 2025! Download now and transform your habits into powerful streaks! 🚀",
        ),
      );
    } catch (e) {
      debugPrint("Error sharing screenshot: $e");
      Fluttertoast.showToast(msg: "❌ Error sharing screenshot");
    }
  }
}
