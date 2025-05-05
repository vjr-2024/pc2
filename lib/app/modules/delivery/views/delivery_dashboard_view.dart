import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/delivery_dashboard_controller.dart';

class DeliveryDashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DeliveryDashboardController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Dashboard'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() {
            return Text(
              'Live Location: ${controller.locationController.latitude.value}, ${controller.locationController.longitude.value}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            );
          }),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await controller.locationController.getCurrentLocation();
              Get.snackbar(
                'Location Updated',
                'Your location has been updated successfully.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: Text('Update Location'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await controller.locationController.getCurrentLocation();
        },
        child: Icon(Icons.location_on),
      ),
    );
  }
}
