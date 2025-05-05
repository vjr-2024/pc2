// lib/app/modules/delivery/bindings/delivery_dashboard_binding.dart

import 'package:get/get.dart';
import '../controllers/delivery_dashboard_controller.dart';
import '../controllers/delivery_location_controller.dart'; // Import DeliveryLocationController

class DeliveryDashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Inject both controllers
    Get.lazyPut<DeliveryDashboardController>(
        () => DeliveryDashboardController());
    Get.lazyPut<DeliveryLocationController>(() =>
        DeliveryLocationController()); // Ensure DeliveryLocationController is injected
  }
}
