import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/controllers/user_controller.dart';
import '../../orders/views/orders_view.dart';
import '../../orders/views/supplier_orders_view.dart';
import '../../orders/views/delivery_boy_orders_view.dart';
import '../../profile/views/profile_view.dart';
import '../../home/views/home_view.dart';
import '../../delivery/views/delivery_dashboard_view.dart'; // New import
import '../controllers/base_controller.dart';
import '../../debug/views/debug_view.dart';

class BaseView extends StatelessWidget {
  final BaseController controller = Get.find<BaseController>();
  final UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BaseController>(
      builder: (_) => Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: controller.currentIndex,
            children: [
              HomeView(),
              _getDebugViewByRole(), // Dynamically load Debug view based on role
              _getOrdersViewByRole(),
              ProfileView(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex,
          onTap: controller.changeScreen,
          backgroundColor: Colors.blue, // Dark background color
          selectedItemColor: Colors.red, // Active icon color
          unselectedItemColor: Color(0xff5f0e0e), // Inactive icon color
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bug_report), label: 'Debug'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Orders'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  // Helper to load Debug view based on role
  Widget _getDebugViewByRole() {
    if (userController.userRole.value == 'deliveryBoy') {
      return DeliveryDashboardView(); // Show Delivery Dashboard for delivery boys
    } else {
      return DebugScreen(); // Default Debug Screen
    }
  }

  // Helper to load OrdersView based on role
  Widget _getOrdersViewByRole() {
    switch (userController.userRole.value) {
      case 'supplier':
        return SupplierOrdersView();
      case 'deliveryBoy':
        return DeliveryBoyOrdersView();
      default:
        return OrdersView();
    }
  }
}
