import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../../../../utils/constants.dart';
import '../../../data/local/my_shared_pref.dart';

class LoginView extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final isLightTheme = MySharedPref.getThemeIsLight();
    final theme = context.theme;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image (for light/dark theme)
          Positioned.fill(
            child: Image.asset(
              isLightTheme ? Constants.background : Constants.backgroundDark,
              fit: BoxFit.fill,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                40.verticalSpace,
                // Logo
                CircleAvatar(
                  radius: 50.r,
                  backgroundColor: theme.primaryColorDark,
                  child: Image.asset(
                    Constants.logo,
                    width: 80.66.w,
                    height: 66.80.h,
                  ),
                ).animate().fade().slide(
                      duration: 300.ms,
                      begin: Offset(0, -1), // Slide vertically
                      curve: Curves.easeInSine,
                    ),
                30.verticalSpace,
                // App Title
                Text(
                  'PROCURECART',
                  style: theme.textTheme.displayLarge!
                      .copyWith(color: Colors.black),
                  textAlign: TextAlign.center,
                ).animate().fade().slide(
                      duration: 300.ms,
                      begin: Offset(0, -1), // Slide vertically
                      curve: Curves.easeInSine,
                    ),
                24.verticalSpace,
                // App Description
                Text(
                  'Get your groceries delivered at your doorstep',
                  style:
                      theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
                  textAlign: TextAlign.center,
                ).animate().fade().slide(
                      duration: 300.ms,
                      begin: Offset(0, -1), // Slide vertically
                      curve: Curves.easeInSine,
                    ),
                40.verticalSpace,

                // Mobile Number Input Section
                Obx(() {
                  if (!controller.otpSent.value) {
                    return Column(
                      children: [
                        // Mobile Number Input
                        TextField(
                          onChanged: (value) {
                            controller.phoneNumber.value = value;
                          },
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: const TextStyle(color: Colors.black),
                            border: const OutlineInputBorder(),
                            prefixIcon:
                                const Icon(Icons.phone, color: Colors.black),
                          ),
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: Colors.black),
                        ).animate().fadeIn(duration: 300.ms),
                        20.verticalSpace,

                        // Send OTP Button
                        controller.isLoading.value
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: () => controller.requestOTP(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ).animate().fadeIn(duration: 500.ms),
                      ],
                    );
                  } else {
                    // OTP Input Section
                    return Column(
                      children: [
                        // OTP Input
                        TextField(
                          onChanged: (value) =>
                              controller.otpCode.value = value,
                          decoration: InputDecoration(
                            labelText: 'Enter OTP',
                            labelStyle: const TextStyle(color: Colors.black),
                            border: const OutlineInputBorder(),
                            prefixIcon:
                                const Icon(Icons.lock, color: Colors.black),
                          ),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.black),
                        ).animate().fadeIn(duration: 300.ms),

                        20.verticalSpace,

                        // Verify OTP Button
                        controller.isLoading.value
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: () => controller.verifyOTP(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: Text(
                                  'Verify OTP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ).animate().fadeIn(duration: 500.ms),
                      ],
                    );
                  }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
