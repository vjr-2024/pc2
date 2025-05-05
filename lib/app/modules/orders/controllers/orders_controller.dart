import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../home/controllers/home_controller.dart';
import '../../../data/controllers/user_controller.dart';

class OrdersController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  RxList<Map<String, dynamic>> orders = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredOrders = <Map<String, dynamic>>[].obs;

  final UserController userController = Get.find<UserController>();

  @override
  void onInit() {
    super.onInit();
    fetchUserOrders(); // Fetch orders on initialization
  }

  /// Fetch orders based on user role (Supplier, Customer, or Delivery Boy)
  Future<void> fetchUserOrders() async {
    try {
      final HomeController homeController = Get.find<HomeController>();
      final String userId = homeController.currentUser ?? 'defaultUserId';
      final String userRole = userController.userRole.value;

      if (userId.isEmpty) {
        Get.snackbar(
            'Error', 'User not logged in. Please log in and try again.');
        return;
      }

      QuerySnapshot snapshot;

      if (userRole == 'supplier') {
        // 🔥 Supplier: Fetch ALL orders
        snapshot = await firestore.collection('orders').get();
      } else if (userRole == 'customer') {
        // 🛒 Customer: Fetch ONLY their orders
        snapshot = await firestore
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .get();
      } else if (userRole == 'deliveryBoy') {
        // 🚚 Delivery Boy: Fetch orders assigned to the delivery boy
        snapshot = await firestore
            .collection('orders')
            .where('deliveryBoyId', isEqualTo: userId)
            .get();
      } else {
        Get.snackbar('Error', 'Invalid user role.');
        return;
      }

      // Map the snapshot to list of orders with additional fields like documentId
      orders.value = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'documentId': doc.id,
          'timestamp': data['timestamp'] is Timestamp
              ? (data['timestamp'] as Timestamp).toDate()
              : null,
        };
      }).toList();

      if (userRole == 'supplier') {
        // Apply default filter to show 'Shipped' and 'Out for Delivery' orders
        filterOrdersByStatuses(['Shipped', 'Pending', 'Out for Delivery']);
      } else if (userRole == 'customer') {
        // Apply default filter to show 'Shipped' and 'Out for Delivery' orders
        filterOrdersByStatuses(['Shipped', 'Out for Delivery']);
      } else if (userRole == 'deliveryBoy') {
        // Apply default filter to show 'Shipped' and 'Out for Delivery' orders
        filterOrdersByStatuses(['Shipped', 'Out for Delivery']);
      } else {
        Get.snackbar('Error', 'Invalid user role.');
        return;
      }
      // Apply default filter to show 'Shipped' and 'Out for Delivery' orders
      //filterOrdersByStatuses(['Shipped', 'Out for Delivery']);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch orders. Please try again.');
    }
  }

  /// Refresh orders manually
  void refreshOrders() {
    fetchUserOrders();
  }

  /// Filter orders by one or more statuses
  void filterOrdersByStatuses(List<String> statuses) {
    if (statuses.isEmpty || statuses.contains('All')) {
      filteredOrders.assignAll(orders);
    } else {
      filteredOrders.assignAll(
        orders.where((order) => statuses.contains(order['status'])).toList(),
      );
    }
  }

  /// Filter orders by a single status
  void filterOrdersByStatus(String status) {
    filterOrdersByStatuses([status]);
  }
}
