import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../home/controllers/home_controller.dart';

class ProfileController extends GetxController {
  var isLoading = true.obs;
  var username = ''.obs;
  var userEmail = ''.obs;
  var userAvatar = ''.obs;

  // Variable to track editing state
  var isEditing = false.obs;

  @override
  void onInit() {
    fetchUserDetails();
    print('edit var: $isEditing');
    super.onInit();
  }

  Future<void> fetchUserDetails() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc('currentUserId') // Replace with actual user ID
          .get();

      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

      username.value = data['username'] ?? 'Guest';
      userEmail.value = data['email'] ?? '';
      userAvatar.value = data['avatarUrl'] ?? '';
      isLoading.value = false;
    } catch (e) {
      // Handle errors
      print('Error fetching user details: $e');
      isLoading.value = false;
    }
  }

  void updateUserName(String value) {
    username.value = value;
  }

  void updateUserEmail(String value) {
    userEmail.value = value;
  }

  Future<void> saveChanges() async {
    final HomeController controller1 = Get.find<HomeController>();
    print('doc name: ${controller1.currentUser}');
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(controller1.currentUser)
          .update({
        'username': username.value,
        'email': userEmail.value,
      });
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile');
      print('Error updating profile: $e');
    }
  }

  void toggleEditing() {
    isEditing.value = !isEditing.value; // Toggle editing mode
  }
}
