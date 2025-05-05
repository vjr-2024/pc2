import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../components/custom_snackbar.dart';
import '../../../data/models/product_model.dart';
import '../../base/controllers/base_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../../data/controllers/data_controller.dart';

class CartController extends GetxController {
  List<ProductModel> products = []; // Cart products
  List<ProductModel> orderSummary = []; // Summary of the current order
  bool orderPlaced = false;
  String? invoiceNumber; // Stores the generated invoice number

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    getCartProducts();
  }

  void getCartProducts() {
    try {
      print('gat cart products');
      final DataController dataController = Get.find<DataController>();
      products = dataController.products.where((p) => p.quantity > 0).toList();
      //updateOrderSummary();
      update();
    } catch (e) {
      CustomSnackBar.showCustomSnackBar(
        title: 'Error',
        message: 'Failed to fetch cart products. Please try again.',
      );
    }
  }

  void updateOrderSummary() {
    print('upd ord sum, qaunt: ${products.length}');
    orderSummary = products.map((product) {
      return ProductModel(
        id: product.id,
        image: product.image ?? '',
        name: product.name,
        ctgry: product.ctgry ?? '',
        pksz: product.pksz ?? '',
        description: product.description ?? '',
        quantity: product.quantity,
        price: product.price,
        bulkPrices: product.bulkPrices ?? [],
        effectivePrice:
            product.effectivePrice, // Directly use the effective price
        brand: product.brand ?? '',
        subctgry: product.subctgry ?? '',
        mrp: product.mrp, // Add MRP field
        gst: product.gst, // Add GST field
      );
    }).toList();
    update();
  }

  void updateCartItemQuantity(String productId, int quantity) {
    // try {
    //   final dataController = Get.find<DataController>();
    //   final productIndex =
    //       products.indexWhere((product) => product.id == productId);
    //   if (productIndex != -1) {
    //     if (quantity > 0) {
    //       products[productIndex].quantity = quantity;
    //       // Directly update the effective price
    //       products[productIndex].effectivePrice =
    //           dataController.getEffectivePrice(productId);
    //     } else {
    //       products.removeAt(productIndex);
    //     }
    //     updateOrderSummary();
    //     update();
    //     CustomSnackBar.showCustomSnackBar(
    //       title: 'Success',
    //       message: 'Product quantity updated.',
    //     );
    //   }
    // } catch (e) {
    //   CustomSnackBar.showCustomSnackBar(
    //     title: 'Error',
    //     message: 'Failed to update product quantity.',
    //   );
    // }
  }

  void clearCart() {
    try {
      print('clear cart fn called');
      final dataController = Get.find<DataController>();
      for (var product in dataController.products) {
        product.quantity = 0;
      }
      products.clear();
      orderPlaced = true; // Retain order summary for review
      update();
    } catch (e) {
      CustomSnackBar.showCustomSnackBar(
        title: 'Error',
        message: 'Failed to clear the cart. Please try again.',
      );
    }
  }

  Future<void> onPurchaseNowPressed() async {
    if (products.isEmpty) {
      CustomSnackBar.showCustomSnackBar(
        title: 'Cart Empty',
        message: 'Please add items to your cart before purchasing.',
      );
      return;
    }

    try {
      updateOrderSummary();

      ///
      await saveOrderToFirestore();
      clearCart();
      CustomSnackBar.showCustomSnackBar(
        title: 'Success',
        message: 'Order placed successfully!',
      );
    } catch (e) {
      CustomSnackBar.showCustomSnackBar(
        title: 'Error',
        message: 'Failed to place the order. Please try again.',
      );
    }
  }

  Future<void> saveOrderToFirestore() async {
    final homeController = Get.find<BaseController>().homeController;
    final userId = Get.find<HomeController>().currentUser;

    if (userId == null || userId.isEmpty) {
      throw Exception('User ID not found. Please log in again.');
    }

    final order = {
      'userId': userId,
      'products': orderSummary.map((product) {
        return {
          'productId': product.id,
          'name': product.name,
          'quantity': product.quantity,
          'price': product.effectivePrice, // Use updated effectivePrice
        };
      }).toList(),
      'totalPrice': orderSummary.fold<double>(
        0,
        (sum, product) => sum + (product.quantity * product.effectivePrice),
      ),
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
    };

    final invoiceId = await generateSequentialInvoiceNumber();
    invoiceNumber = invoiceId; // Store the invoice number for display

    try {
      await firestore.collection('orders').doc(invoiceId).set(order);
      print('Order saved to Firestore with ID: $invoiceId');
    } catch (e) {
      print('Error saving order to Firestore: $e');
      throw Exception('Failed to save the order.');
    }
    update();
  }

  Future<String> generateSequentialInvoiceNumber() async {
    final counterRef = firestore.collection('counters').doc('invoiceCounter');

    return firestore.runTransaction((transaction) async {
      final counterSnapshot = await transaction.get(counterRef);

      if (!counterSnapshot.exists) {
        transaction.set(counterRef, {'currentInvoice': 1000});
        return 'INV-1000';
      }

      final currentInvoice = counterSnapshot.get('currentInvoice');
      final nextInvoice = currentInvoice + 1;

      transaction.update(counterRef, {'currentInvoice': nextInvoice});

      return 'INV-$nextInvoice';
    });
  }
}
