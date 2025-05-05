// lib/app/modules/delivery/controllers/delivery_dashboard_controller.dart

import 'package:get/get.dart';
import 'delivery_location_controller.dart';

class DeliveryDashboardController extends GetxController {
  // Create an instance of DeliveryLocationController
  final DeliveryLocationController locationController = Get.find();

  @override
  void onInit() {
    super.onInit();
    // Get the initial location when the controller is initialized
    locationController.getCurrentLocation();
  }

  // Use updateLiveLocation to update the live location if needed
  void updateDeliveryLocation(double lat, double lon) {
    locationController.updateLiveLocation(lat, lon);
  }
}
