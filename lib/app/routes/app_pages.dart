import 'package:get/get.dart';

import '../modules/base/bindings/base_binding.dart';
import '../modules/base/views/base_view.dart';
import '../modules/calendar/bindings/calendar_binding.dart';
import '../modules/calendar/views/calendar_view.dart';
import '../modules/cart/bindings/cart_binding.dart';
import '../modules/cart/views/cart_view.dart';
import '../modules/cart/views/checkout_view.dart';

import '../modules/category/bindings/category_binding.dart';
import '../modules/category/views/category_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/product_details/bindings/product_details_binding.dart';
import '../modules/product_details/views/product_details_view.dart';
import '../modules/products/bindings/products_binding.dart';
import '../modules/products/views/products_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/welcome/bindings/welcome_binding.dart';
import '../modules/welcome/views/welcome_view.dart';
import '../modules/orders/bindings/orders_binding.dart';
import '../modules/orders/views/orders_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/search_results/bindings/search_results_binding.dart';
import '../modules/search_results/views/search_results_view.dart';
import '../modules/imageview/bindings/image_binding.dart';
import '../modules/imageview/views/image_view.dart';
import '../modules/debug/bindings/debug_binding.dart';
import '../modules/debug/views/debug_view.dart';
import '../modules/delivery/bindings/delivery_dashboard_binding.dart';
import '../modules/delivery/views/delivery_dashboard_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.splash;
  //static const initial = Routes.login;
  //static const initial = Routes.imageview;
  //static const initial = Routes.debug;

  static final routes = [
    GetPage(
      name: _Paths.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.welcome,
      page: () => const WelcomeView(),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: _Paths.base,
      //page: () => const BaseView(),
      page: () => BaseView(),
      binding: BaseBinding(),
    ),
    GetPage(
      name: _Paths.home,
      //page: () => const HomeView(),
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.cart,
      page: () => const CartView(),
      binding: CartBinding(),
    ),
    GetPage(
      name: _Paths.productdetails,
      page: () => const ProductDetailsView(),
      binding: ProductDetailsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.category,
      page: () => const CategoryView(),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: _Paths.calendar,
      page: () => const CalendarView(),
      binding: CalendarBinding(),
    ),
    GetPage(
      name: _Paths.orders,
      page: () => OrdersView(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: _Paths.login,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.profile,
      page: () => ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.products,
      page: () => const ProductsView(),
      binding: ProductsBinding(),
    ),
    GetPage(
      name: _Paths.searchresults,
      page: () => SearchResultsView(),
      binding: SearchResultsBinding(),
    ),
    GetPage(
      name: _Paths.imageview,
      page: () => ImageView(),
      binding: ImageBinding(),
    ),
    GetPage(
      name: _Paths.debug,
      page: () => DebugScreen(),
      binding: DebugBinding(),
    ),
    GetPage(
      name: _Paths.deliveryBoyDashboard,
      page: () => DeliveryDashboardView(),
      binding: DeliveryDashboardBinding(),
    ),
    GetPage(
      name: _Paths.checkout,
      page: () => const CheckoutView(),
      binding: CartBinding(),
    ),
  ];
}
