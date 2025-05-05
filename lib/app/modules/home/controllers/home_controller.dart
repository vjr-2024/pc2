import 'package:get/get.dart';
import '../../../../config/theme/my_theme.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../utils/constants.dart';

class HomeController extends GetxController {
  List<CategoryModel> categories = [];
  List<ProductModel> products = [];
  var isLightTheme = MySharedPref.getThemeIsLight();
  // for home screen cards
  var cards = [
    Constants.card1,
    Constants.card2,
    Constants.card3
  ]; //constants for now. fetch from some database later
  String? currentUser;

  Future<void> loadInitialData() async {
    await loadCategories(); // Await this function to ensure it completes
    print('home1 contr prd length: ${products.length}');
    print('home1 contr cat length: ${categories.length}');

    await loadProducts(); // Await this function to ensure it completes
    print('home2 contr prd length: ${products.length}');
    print('home2 contr cat length: ${categories.length}');
  }

  Future<void> loadCategories() async {
    categories = await _loadCategoriesFromLocal();
    print('cat load from loc cmplt: ${categories.length}');

    fetchAndUpdateCategories();
    print('cat load from firebase cmplt: ${categories.length}');
  }

  Future<List<CategoryModel>> _loadCategoriesFromLocal() async {
    final box = await Hive.openBox<CategoryModel>('categories');
    return box.values.toList();
  }

  Future<void> fetchAndUpdateCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    final freshCategories = snapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc.id, doc.data()))
        .toList();
    await _saveCategoriesToLocal(freshCategories);
    categories = freshCategories;
  }

  Future<void> _saveCategoriesToLocal(List<CategoryModel> categories) async {
    final box = await Hive.openBox<CategoryModel>('categories');
    await box.clear();
    await box.addAll(categories);
  }

  Future<void> loadProducts() async {
    print('prd loading from loc before fn call: ${products.length}');
    products = await _loadProductsFromLocal();
    print('prd load from loc cmplt: ${products.length}');

    fetchAndUpdateProducts();
    print('prod load from firebase cmplt: ${products.length}');
  }

  Future<List<ProductModel>> _loadProductsFromLocal() async {
    print('prd loading from loc in progress: ${products.length}');

    final box = await Hive.openBox<ProductModel>('products'); // Open Hive box
    print('prd loading from loc after hive fn: ${products.length}');

    final loadedProducts = box.values.toList(); // Retrieve data from Hive
    print('prd loading from loc after data fetch: ${products.length}');

    return loadedProducts;
  }

  Future<void> fetchAndUpdateProducts() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('products').get();
    final freshProducts = snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc.id, doc.data()))
        .toList();
    await _saveProductsToLocal(freshProducts);
    products = freshProducts;
  }

  Future<void> _saveProductsToLocal(List<ProductModel> products) async {
    final box = await Hive.openBox<ProductModel>('products');
    await box.clear();
    await box.addAll(products);
  }

  void saveProductToLocal(ProductModel product) async {
    await _saveProductToLocal(product);
  }

  Future<void> _saveProductToLocal(ProductModel product) async {
    final box = await Hive.openBox<ProductModel>('products');
    await box.put(product.id, product);
  }

  Future<void> saveAllProductsToLocal() async {
    await Future.forEach(products, (ProductModel product) async {
      await _saveProductToLocal(product);
    });
  }

  void onChangeThemePressed() async {
    await MyTheme.changeTheme();
    isLightTheme = await MySharedPref.getThemeIsLight();
    update(['Theme']);
  }

  @override
  void onInit() {
    loadInitialData();
    super.onInit();
  }
}
