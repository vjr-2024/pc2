import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class ImageController extends GetxController {
  var imagePath = ''.obs;
  var debugInfo = '🔍 Starting image copy process...'.obs;

  @override
  void onInit() {
    super.onInit();
    copyImageToLocal();
  }

  Future<void> copyImageToLocal() async {
    try {
      // Step 1: Load asset
      debugInfo.value = "🔎 Loading asset...";
      final byteData = await rootBundle.load('assets/images/sample.jpg');
      debugInfo.value += "\n✅ Asset loaded successfully.";

      // Step 2: Get local directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/sample.jpg';
      final file = File(filePath);
      debugInfo.value += "\n📂 Local file path: $filePath";

      // Step 3: Copy asset to local storage
      if (!await file.exists()) {
        await file.writeAsBytes(byteData.buffer.asUint8List());
        debugInfo.value += "\n✅ Image copied to local storage.";
      } else {
        debugInfo.value += "\n🟢 Image already exists.";
      }

      // Step 4: Confirm file existence
      if (await file.exists()) {
        imagePath.value = file.path;
        debugInfo.value += "\n🟢 Image is ready to display.";
      } else {
        debugInfo.value += "\n❌ Image not found after copying.";
      }
    } catch (e) {
      debugInfo.value = "❌ Error during image copy: $e";
    }
  }
}
