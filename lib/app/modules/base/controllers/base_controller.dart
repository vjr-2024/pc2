import 'package:get/get.dart';
import '../../home/controllers/home_controller.dart';

class BaseController extends GetxController {
  final HomeController homeController;

  // Constructor with dependency injection
  BaseController({required this.homeController});

  int currentIndex = 0;

  /// Change the current screen index
  void changeScreen(int index) {
    currentIndex = index;
    update(); // Notify UI for updates
  }

  /// Getter to calculate total cart items count
  int get cartItemsCount {
    return homeController.products.fold<int>(
      0,
      (sum, product) => sum + product.quantity,
    );
  }
}
