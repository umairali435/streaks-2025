import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:screenshot/screenshot.dart';

class ScreenshotService {
  final ScreenshotController _controller = ScreenshotController();

  ScreenshotController get controller => _controller;

  /// Save widget screenshot to gallery
  Future<void> captureAndSaveToGallery() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          Fluttertoast.showToast(msg: "Storage permission denied");
          return;
        }
      }

      Uint8List? imageBytes = await _controller.capture();
      if (imageBytes == null) throw Exception("Capture failed");

      final result = await ImageGallerySaver.saveImage(
        imageBytes,
        quality: 100,
        name: "screenshot_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (result['isSuccess'] == true) {
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

      final tempDir = Directory.systemTemp;
      final file = await File('${tempDir.path}/screenshot.png').create();
      await file.writeAsBytes(imageBytes);

      await SharePlus.instance.share(
        ShareParams(
            files: [XFile(file.path)], text: "Checkout my progress here"),
      );
    } catch (e) {
      debugPrint("Error sharing screenshot: $e");
      Fluttertoast.showToast(msg: "❌ Error sharing screenshot");
    }
  }
}
