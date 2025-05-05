import 'package:get/get.dart';
import '../../../data/controllers/data_controller.dart';

class DebugController extends GetxController {
  var debugInfo = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Get DataController instance
    final DataController dataController = Get.find<DataController>();

    // Bind DataController's debugInfo to DebugController's debugInfo
    ever(dataController.debugInfo, (String value) {
      debugInfo.value =
          value; // Updates automatically when DataController changes
    });
  }
}
