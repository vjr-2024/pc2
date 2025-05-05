import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class UserController extends GetxController {
  var userRole = ''.obs;

  void setUserRole(String role) {
    userRole.value = role;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> loginUser(String userId) async {
    try {
      // Simulate successful login process
      print("✅ User $userId logged in successfully.");
      Get.snackbar("Login", "User $userId logged in successfully.");

      // Fetch FCM token
      String? fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        print("✅ FCM Token: $fcmToken");
        Get.snackbar("FCM Token", fcmToken);

        // Save token to Firestore
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': fcmToken,
        });
        print("✅ FCM Token saved to Firestore.");
        Get.snackbar("Success", "FCM Token saved to Firestore.");
      } else {
        print("⚠️ Failed to fetch FCM token.");
        Get.snackbar("Error", "Failed to fetch FCM token.");
      }
    } catch (e) {
      print("❌ Error during login or token saving: $e");
      Get.snackbar("Error", "Failed to login or save token: $e");
    }
  }
}
