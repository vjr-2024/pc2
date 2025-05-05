import 'package:get/get.dart';
import '../../calendar/controllers/calendar_controller.dart';
import '../../category/controllers/category_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/base_controller.dart';
import '../../orders/controllers/orders_controller.dart';

class BaseBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize HomeController first so it can be passed to BaseController
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<BaseController>(
        () => BaseController(homeController: Get.find<HomeController>()));
    Get.lazyPut<CategoryController>(() => CategoryController());
    Get.lazyPut<OrdersController>(() => OrdersController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
