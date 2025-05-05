import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/no_data.dart';
import '../controllers/category_controller.dart';
import '../../debug/controllers/debug_controller.dart';
import '../../debug/views/debug_view.dart';

class CategoryView extends GetView<CategoryController> {
  const CategoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Category', style: context.theme.textTheme.displaySmall),
        centerTitle: true,
      ),
      //body: const NoData(text: 'This is Category Screen'),

      // Pass the debugInfo as a String (use .value to get the actual String from RxString)
      // body: DebugScreen(
      //     debugInfo: controller
      //         .debugInfo.value), // Use .value to get the actual string
    );
  }
}
