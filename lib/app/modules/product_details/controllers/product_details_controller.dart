import 'package:get/get.dart';

import '../../../data/models/product_model.dart';
import '../../cart/controllers/cart_controller.dart';

class ProductDetailsController extends GetxController {
  // Get product details from arguments
  final ProductModel product = Get.arguments;

  /// When the user presses the "Add to Cart" button
  void onAddToCartPressed() {
    if (product.quantity == 0) {
      // Call the updateCartItemQuantity method from CartController
      Get.find<CartController>().updateCartItemQuantity(product.id, 1);
      product.quantity += 1;
    }
    Get.back();
  }
}
