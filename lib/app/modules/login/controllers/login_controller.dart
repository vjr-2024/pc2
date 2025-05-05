import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import '../../home/controllers/home_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../data/controllers/user_controller.dart';
import '../../../data/models/user_model.dart'
    as custom; // Alias the custom User model
import 'dart:io';

class LoginController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // Observables to hold user input and state
  var phoneNumber = ''.obs;
  var otpCode = ''.obs;
  var isLoading = false.obs;
  var otpSent = false.obs; // Track if OTP is sent

  // Temporary flag to allow bypassing OTP verification (for testing)
  var bypassOTP = false.obs;
  // var bypassOTP = true.obs;

  var loginwithoutOTP = true.obs;

  // 🚀 Function to request OTP
  Future<void> requestOTP() async {
    try {
      isLoading(true);
      Get.snackbar('Debug', 'Requesting OTP...',
          duration: Duration(seconds: 3));

      // Check if the phone number is 10 digits and doesn't start with '+'
      if (phoneNumber.value.length == 10 &&
          !phoneNumber.value.startsWith('+')) {
        phoneNumber.value = '+91' + phoneNumber.value; // Add +91 if needed
      }

      if (phoneNumber.value.isEmpty || !phoneNumber.value.startsWith('+')) {
        Get.snackbar('Error', 'Please enter a valid phone number',
            duration: Duration(seconds: 3));
        return;
      }

      // 👉 Direct Login Without OTP
      if (loginwithoutOTP.value) {
        Get.snackbar('Debug', 'Direct login without OTP...',
            duration: Duration(seconds: 3));
        print('Login directly with phone number, without OTP.');
        print('Phone Number: ${phoneNumber.value}');
        final HomeController controller1 = Get.find<HomeController>();
        controller1.currentUser = phoneNumber.value;

        await storeUserDetails("dummyid", phoneNumber.value);
        Get.snackbar('Success', 'Logged in successfully',
            duration: Duration(seconds: 3));
        clearOTPCode();
        final usercontroller = Get.find<UserController>();
        await usercontroller.loginUser(phoneNumber.value);

        // ✅ Write phone number to Hive
        final userBox = Hive.box<custom.User>('userBox');
        final user =
            custom.User(userId: "dummyid", phoneNumber: phoneNumber.value);
        userBox.put('currentUser', user);

        // ✅ Navigate user by role
        await navigateUserByRole(phoneNumber.value);

        return;
      }

      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber.value,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
          Get.snackbar('Success', 'OTP auto-verification successful',
              duration: Duration(seconds: 3));
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage = '';
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'The provided phone number is not valid.';
              break;
            case 'quota-exceeded':
              errorMessage = 'SMS quota exceeded. Please try again later.';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many requests. Please try again later.';
              break;
            default:
              errorMessage =
                  e.message ?? 'Verification failed. Please try again.';
              break;
          }
          Get.snackbar('Error', errorMessage, duration: Duration(seconds: 3));
        },
        codeSent: (String verificationId, int? resendToken) {
          Get.snackbar('OTP Sent', 'OTP sent to ${phoneNumber.value}',
              duration: Duration(seconds: 3));
          otpSent(true);
          debugPrint('OTP sent: ${otpSent.value}');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          Get.snackbar('Timeout', 'OTP auto-retrieval timeout',
              duration: Duration(seconds: 3));
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to send OTP. Please try again.',
          duration: Duration(seconds: 3));
      debugPrint("Error in OTP request: $e");
    } finally {
      isLoading(false);
      Get.snackbar('Debug', 'Request OTP process completed.',
          duration: Duration(seconds: 3));
    }
  }

  // ✅ Function to verify OTP
  Future<void> verifyOTP() async {
    try {
      isLoading(true);
      Get.snackbar('Debug', 'Verifying OTP...', duration: Duration(seconds: 3));
      print('Phone Number2: ${phoneNumber.value}');

      if (bypassOTP.value) {
        Get.snackbar('Debug', 'Bypassing OTP...',
            duration: Duration(seconds: 3));
        print('Bypass OTP enabled.');
        final HomeController controller1 = Get.find<HomeController>();
        controller1.currentUser = phoneNumber.value;

        await storeUserDetails("dummyid", phoneNumber.value);
        Get.snackbar('Success', 'Logged in successfully',
            duration: Duration(seconds: 3));
        clearOTPCode();
        await navigateUserByRole(phoneNumber.value);
        return;
      }

      if (otpCode.value.isEmpty || otpCode.value.length != 6) {
        Get.snackbar('Error', 'Please enter a valid 6-digit OTP',
            duration: Duration(seconds: 3));
        return;
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: '<verificationId>',
        smsCode: otpCode.value,
      );

      final UserCredential userCredential =
          await auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await storeUserDetails(userCredential.user!.uid, phoneNumber.value);
        Get.snackbar('Success', 'Logged in successfully',
            duration: Duration(seconds: 3));
        clearOTPCode();
        await navigateUserByRole(phoneNumber.value);

        // ✅ Write phone number to Hive
        final userBox = Hive.box<custom.User>('userBox');
        final user = custom.User(
            userId: userCredential.user!.uid, phoneNumber: phoneNumber.value);
        userBox.put('currentUser', user);
      } else {
        Get.snackbar('Error', 'Login failed. Please try again.',
            duration: Duration(seconds: 3));
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-verification-code':
            Get.snackbar('Error', 'The OTP you entered is incorrect.',
                duration: Duration(seconds: 3));
            break;
          case 'session-expired':
            Get.snackbar('Error', 'OTP has expired. Please request a new OTP.',
                duration: Duration(seconds: 3));
            break;
          default:
            Get.snackbar('Error', e.message ?? 'OTP verification failed.',
                duration: Duration(seconds: 3));
        }
      } else {
        Get.snackbar('Error', 'OTP verification failed. Please try again.',
            duration: Duration(seconds: 3));
      }
      debugPrint("Error in OTP verification: $e");
    } finally {
      isLoading(false);
      Get.snackbar('Debug', 'Verify OTP process completed.',
          duration: Duration(seconds: 3));
    }
  }

  // 📝 Store user details securely
  Future<void> storeUserDetails(String userId, String phoneNumber) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(phoneNumber)
          .get();

      if (!userDoc.exists) {
        await secureStorage.write(key: 'userId', value: userId);
        await secureStorage.write(key: 'phoneNumber', value: phoneNumber);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(phoneNumber)
            .set({
          'userId': userId,
          'phoneNumber': phoneNumber,
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
          'username': '',
          'email': '',
          'legalEntityName': '',
          'panNumber': '',
        });

        debugPrint("User details stored successfully.");
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to store user details.');
      debugPrint("Error storing user details: $e");
    }
  }

  // 🚦 Navigate user based on role
  Future<void> navigateUserByRole(String phoneNumber) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(phoneNumber)
          .get();

      if (userDoc.exists) {
        String role = userDoc.get('role');
        // Set user role in UserController
        UserController userController = Get.find<UserController>();
        userController.setUserRole(role);

        if (role == 'customer') {
          Get.offAllNamed(Routes.base); // Customer navigates to BaseView
        } else if (role == 'deliveryBoy') {
          Get.offAllNamed(Routes.base); // Delivery Boy Dashboard
        } else if (role == 'supplier') {
          Get.offAllNamed(Routes.base); // Supplier navigates to BaseView
        } else {
          NoUserroleScreen();
          Get.snackbar('Error', 'Unknown user role');
        }
      } else {
        NoUserDocwithPhnum();

        Get.snackbar('Error', 'User role not found.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to check user role.');
      debugPrint("Error in role check: $e");
    }
  }

  // 🔒 Logout
  Future<void> logout() async {
    await secureStorage.deleteAll();
    Get.snackbar('Success', 'Logged out successfully');

    // ✅ Delete logged-in status file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/loggedin.txt';
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      debugPrint("Logged-in status file deleted successfully.");
    }
  }

  void clearPhoneNumber() {
    phoneNumber.value = '';
  }

  void clearOTPCode() {
    otpCode.value = '';
  }
}

class NoUserroleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('No User role')),
      body: Center(
        child: Text('user role: '),
      ),
    );
  }
}

class NoUserDocwithPhnum extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('No User document')),
      body: Center(
        child: Text('usr document: '),
      ),
    );
  }
}
