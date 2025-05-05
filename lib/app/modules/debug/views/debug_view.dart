import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/debug_controller.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DebugController debugController = Get.find<DebugController>();

    return Scaffold(
      appBar: AppBar(title: Text('Debug Info')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () => SingleChildScrollView(
            child: SelectableText(
              debugController.debugInfo.value,
              style: TextStyle(fontSize: 14.0, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
