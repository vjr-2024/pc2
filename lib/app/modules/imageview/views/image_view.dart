import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/image_controller.dart';

class ImageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ImageController controller = Get.put(ImageController());

    return Scaffold(
      appBar: AppBar(title: Text('🖼 Image Viewer Debug')),
      body: Center(
        child: Obx(() {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Debug Info
                Text(
                  "📝 Debug Log:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Text(
                    controller.debugInfo.value,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
                SizedBox(height: 20),

                // Image Display
                controller.imagePath.isEmpty
                    ? Icon(Icons.warning, size: 100, color: Colors.orange)
                    : Column(
                        children: [
                          Text(
                            "📷 Loaded Image:",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Image.file(
                            File(controller.imagePath.value),
                            width: 300,
                            height: 300,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Column(
                                children: [
                                  Icon(Icons.error,
                                      size: 100, color: Colors.red),
                                  Text("❌ Error displaying image."),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
              ],
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.copyImageToLocal,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
