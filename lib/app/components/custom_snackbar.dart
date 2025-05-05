import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackBar {
  // Success Snackbar
  static showCustomSnackBar({
    required String title,
    required String message,
    Duration? duration,
    Color? backgroundColor,
  }) {
    Get.snackbar(
      title,
      message,
      duration: duration ?? const Duration(seconds: 3),
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
      colorText: Colors.black, // Dark text for better visibility
      backgroundColor: backgroundColor ??
          const Color(0xFF388E3C), // Green background for success
      icon: const Icon(Icons.check,
          color: Colors.white), // White icon for success
      borderRadius: 8, // Rounded corners for visual appeal
      snackPosition: SnackPosition.TOP, // Position at the top for visibility
    );
  }

  // Error Snackbar
  static showCustomErrorSnackBar({
    required String title,
    required String message,
    Color? color,
    Duration? duration,
  }) {
    Get.snackbar(
      title,
      message,
      duration: duration ?? const Duration(seconds: 3),
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
      colorText: Colors.black, // Dark text for better readability
      backgroundColor: color ?? Colors.redAccent, // Red background for errors
      icon:
          const Icon(Icons.error, color: Colors.white), // White icon for error
      borderRadius: 8, // Rounded corners for visual appeal
      snackPosition: SnackPosition.TOP, // Position at the top for visibility
    );
  }

  // Toast-style message (not a traditional snackbar)
  static showCustomToast({
    String? title,
    required String message,
    Color? color,
    Duration? duration,
  }) {
    Get.rawSnackbar(
      title: title,
      duration: duration ?? const Duration(seconds: 3),
      snackStyle: SnackStyle.GROUNDED, // Grounded style for toasts
      backgroundColor: color ?? Colors.green, // Green background for success
      onTap: (snack) {
        Get.closeAllSnackbars(); // Close all snackbars on tap
      },
      message: message,
      borderRadius: 8, // Rounded corners for visual appeal
      snackPosition:
          SnackPosition.BOTTOM, // Position at the bottom for better visibility
    );
  }

  // Error Toast-style message
  static showCustomErrorToast({
    String? title,
    required String message,
    Color? color,
    Duration? duration,
  }) {
    Get.rawSnackbar(
      title: title,
      duration: duration ?? const Duration(seconds: 3),
      snackStyle: SnackStyle.GROUNDED, // Grounded style for toasts
      backgroundColor: color ?? Colors.redAccent, // Red background for errors
      onTap: (snack) {
        Get.closeAllSnackbars(); // Close all snackbars on tap
      },
      message: message,
      borderRadius: 8, // Rounded corners for visual appeal
      snackPosition:
          SnackPosition.BOTTOM, // Position at the bottom for better visibility
    );
  }
}
