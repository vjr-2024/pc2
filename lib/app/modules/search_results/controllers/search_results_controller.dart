import 'package:get/get.dart';
import '../../../data/models/product_model.dart';

class SearchResultsController extends GetxController {
  final RxList<ProductModel> searchResults = <ProductModel>[].obs;

  // For sorting options
  final RxString selectedSort = ''.obs;

  // Apply sorting to search results
  void applySorting(String sortOption) {
    if (sortOption == 'Price: Low to High') {
      searchResults.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortOption == 'Price: High to Low') {
      searchResults.sort((a, b) => b.price.compareTo(a.price));
    }
    selectedSort.value = sortOption;
  }

  @override
  void onInit() {
    super.onInit();

    print('sr oninit called');
    // Fetch search results passed as arguments
    final List<ProductModel> results = (Get.arguments is List<ProductModel>)
        ? Get.arguments as List<ProductModel>
        : [];

    searchResults.assignAll(results);
  }
}
