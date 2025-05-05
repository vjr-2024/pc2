// lib/app/modules/delivery/controllers/delivery_location_controller.dart

import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../home/controllers/home_controller.dart';

class DeliveryLocationController extends GetxController {
  // Observable variables to hold latitude and longitude
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;

  final HomeController controller1 = Get.find<HomeController>();

  // A method to get the current location of the device
  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, show an error message
      return;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request permission if it was denied
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Permission denied, can't proceed
        return;
      }
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Update the latitude and longitude
    latitude.value = position.latitude;
    longitude.value = position.longitude;

    // After updating the location, store it in Firebase
    await storeLocationInFirebase(position.latitude, position.longitude);
  }

  // A method to update the live location manually
  void updateLiveLocation(double lat, double lon) {
    latitude.value = lat;
    longitude.value = lon;

    // Store the updated location in Firebase
    storeLocationInFirebase(lat, lon);
  }

  // Method to store the location in Firebase
  Future<void> storeLocationInFirebase(double lat, double lon) async {
    // Get the current user's UID
    //String userId = FirebaseAuth.instance.currentUser!.uid;

    String? userId = controller1.currentUser;

    // Reference to the Firestore collection where the user's data is stored
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Update the user's location in Firestore
    try {
      await users.doc(userId).update({
        'latitude': lat,
        'longitude': lon,
      });
    } catch (e) {
      print("Error storing location: $e");
    }
  }
}
