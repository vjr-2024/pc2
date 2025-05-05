import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/data/local/my_shared_pref.dart';
import 'app/routes/app_pages.dart';
import 'config/theme/my_theme.dart';
import 'config/translations/localization_service.dart';
import 'app/data/models/product_model.dart';
import 'app/data/models/category_model.dart';
import 'app/data/models/user_model.dart'; // Import User model
import 'app/data/controllers/data_controller.dart';
import 'app/modules/home/controllers/home_controller.dart';
import 'app/modules/home/views/home_view.dart'; // Import HomeView
import 'app/modules/login/views/login_view.dart';
import 'app/components/permission_handler.dart';
import 'app/data/controllers/user_controller.dart';
import 'firebase/messaging/my_firebase_messaging_service.dart';
import 'app/modules/login/controllers/login_controller.dart'; // Import LoginController
import 'app/modules/base/views/base_view.dart'; // Import HomeView
import 'app/modules/splash/views/splash_view.dart'; // Import HomeView

import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'app/modules/home/controllers/home_controller.dart';
import 'app/data/controllers/user_controller.dart';
import 'app/data/models/user_model.dart'
    as custom; // Alias the custom User model
import 'dart:io';

Future<void> main() async {
  print('Starting Grocery App...');
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyDWMOD4-AFTtlp_QrIBhB_hUYfyssJA7kQ",
        appId: "1:804460982172:android:00a1098eeaa138e581e259",
        messagingSenderId: "804460982172",
        projectId: "flutter-procurekart",
      ),
    );
    print("✅ Firebase initialized.");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar("Firebase", "Firebase initialized successfully");
    });
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar("Error", "Firebase initialization failed: $e");
    });
  }

  // Initialize Hive
  try {
    await MySharedPref.init();
    await Hive.initFlutter();
    Hive.registerAdapter(ProductModelAdapter());
    await Hive.openBox<ProductModel>('productsBox');
    Hive.registerAdapter(CategoryModelAdapter());
    await Hive.openBox<CategoryModel>('categoriesBox');
    Hive.registerAdapter(UserAdapter()); // Register UserAdapter
    await Hive.openBox<User>('userBox'); // Open userBox
    print("✅ Hive initialized.");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar("Hive", "Hive initialized successfully.");
    });
  } catch (e) {
    print("❌ Hive initialization failed: $e");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar("Error", "Hive initialization failed: $e");
    });
  }

  // Firebase Messaging Setup
  try {
    await MyFirebaseMessagingService.initLocalNotification();
    await MyFirebaseMessagingService.setupNotificationChannel();
    FirebaseMessaging.onBackgroundMessage(
        MyFirebaseMessagingService.firebaseMessagingBackgroundHandler);
    await requestNotificationPermission();
    MyFirebaseMessagingService.setupForegroundNotifications();
  } catch (e) {
    print("❌ Firebase Messaging setup failed: $e");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar("Error", "Firebase Messaging setup failed: $e");
    });
  }

  // Initialize Controllers
  try {
    Get.put(UserController());
    final dataController = Get.put(DataController());
    print("✅ Controllers initialized.");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar("Controllers", "Controllers initialized successfully.");
    });

    final homeController = Get.put(HomeController());
    await homeController.loadInitialData();
  } catch (e) {
    print("❌ Error during controller initialization or navigation: $e");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar("Error", "Error during controller initialization: $e");
    });
  }

  // Now we are ready to launch the app
  runApp(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, widget) {
        return FutureBuilder<bool>(
          future: _checkUserStatus(), // Checks if user is logged in
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // return MaterialApp(
              //   home: Scaffold(
              //     body: Center(child: CircularProgressIndicator()),
              //   ),
              //   //home: SplashView(),
              // );
              return MaterialApp(
                home: Scaffold(
                  body: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('Constants.background'),
                        fit: BoxFit
                            .cover, // Adjust the image to cover the entire screen
                      ),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return MaterialApp(
                home: Scaffold(
                  body: Center(child: Text("Error during initialization")),
                ),
              );
            }

            // If no error, decide which screen to show
            final isLoggedIn = snapshot.data ?? false;

            return GetMaterialApp(
              title: "Grocery App",
              debugShowCheckedModeBanner: false,
              builder: (context, widget) {
                bool themeIsLight = MySharedPref.getThemeIsLight();
                return Theme(
                  data: MyTheme.getThemeData(isLight: themeIsLight),
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                    child: widget!,
                  ),
                );
              },
              initialRoute: isLoggedIn
                  ? '/base'
                  : '/login', // Decide route based on login status
              getPages: AppPages.routes,
              locale: MySharedPref.getCurrentLocal(),
              translations: LocalizationService.getInstance(),
            );
          },
        );
      },
    ),
  );
}

// This function checks if the user is logged in and returns true/false
Future<bool> _checkUserStatus() async {
  try {
    final userBox = Hive.box<User>('userBox');
    final user = userBox.get('currentUser');
    if (user != null) {
      print(
          "✅ User is already logged in with phone number: ${user.phoneNumber}");
      final HomeController controller1 = Get.find<HomeController>();
      controller1.currentUser = user.phoneNumber;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.phoneNumber)
          .get();

      if (userDoc.exists) {
        String role = userDoc.get('role');
        // Set user role in UserController
        final usercontroller = Get.find<UserController>();
        usercontroller.setUserRole(role);
        await usercontroller.loginUser(user.phoneNumber);
      } else {
        Get.snackbar('Error', 'User role not found.');
      }
      //final usercontroller = Get.find<UserController>();
      //await usercontroller.loginUser(user.phoneNumber);
      return true; // User is logged in
    } else {
      print("✅ No user found, user is not logged in.");
      return false; // User is not logged in
    }
  } catch (e) {
    print("❌ Error during user status check: $e");
    return false; // Default to not logged in in case of an error
  }
}

Future<void> requestNotificationPermission() async {
  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print("✅ Notification permission granted.");
    Get.snackbar("Permission", "Notification permission granted.");
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print("⚠️ Provisional notification permission granted.");
    Get.snackbar("Permission", "Provisional notification permission granted.");
  } else {
    print("❌ Notification permission denied.");
    Get.snackbar("Permission", "Notification permission denied.");
  }
}

class NoPermissionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HomeController controller1 = Get.find<HomeController>();
    return Scaffold(
      appBar: AppBar(title: Text('Permission Required')),
      body: Center(
        child: Text(
            'Storage permission is required to continue.-- ${controller1.currentUser}'),
      ),
    );
  }
}
