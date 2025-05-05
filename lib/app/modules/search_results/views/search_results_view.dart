import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../../../components/custom_icon_button.dart';
import '../../../components/product_item.dart';
import '../controllers/search_results_controller.dart';

import '../../../data/models/product_model.dart';
import '../../../routes/app_pages.dart';
import '../../../data/controllers/data_controller.dart';

class SearchResultsView extends GetView<SearchResultsController> {
  const SearchResultsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final List<ProductModel>? searchResults =
        Get.arguments as List<ProductModel>?;

    if (searchResults == null || searchResults.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Search Results')),
        body: Center(child: Text('No search results found.')),
      );
    }

    final RxList<ProductModel> filteredProducts = searchResults.obs;
    final RxString selectedBrand = 'All'.obs; // Default to 'All'
    final RxString selectedSort =
        'Price: Low to High'.obs; // Default sort option

    // Extract unique brand names
    final List<String> brandList = [
      'All',
      ...filteredProducts.map((p) => p.brand).toSet()
    ];

    // Filtering logic
    void applyFilters() {
      final filtered = searchResults
          .where((product) => (selectedBrand.value == 'All' ||
              product.brand == selectedBrand.value))
          .toList();

      if (selectedSort.value == 'Price: Low to High') {
        filtered.sort((a, b) => a.price.compareTo(b.price));
      } else if (selectedSort.value == 'Price: High to Low') {
        filtered.sort((a, b) => b.price.compareTo(a.price));
      }

      filteredProducts.assignAll(filtered); // Update the observable list
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: SvgPicture.asset(
                  Constants.backArrowIcon,
                  fit: BoxFit.none,
                  colorFilter: ColorFilter.mode(
                    theme.appBarTheme.iconTheme?.color ?? Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const Text(
                'Search Results',
                style: TextStyle(color: Colors.black),
                //style: theme.textTheme.displaySmall,
                //style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      Constants.searchIcon,
                      fit: BoxFit.none,
                      colorFilter: ColorFilter.mode(
                        theme.appBarTheme.iconTheme?.color ?? Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  IconButton(
                    onPressed: () => Get.toNamed(Routes.cart),
                    icon: SvgPicture.asset(
                      Constants.cartIcon,
                      fit: BoxFit.none,
                      colorFilter: ColorFilter.mode(
                        theme.appBarTheme.iconTheme?.color ?? Colors.black,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
        child: Column(
          children: [
            // Filter and Sort Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Brand Filter Dropdown
                Obx(() => DropdownButton<String>(
                      value: selectedBrand.value,
                      items: brandList
                          .map((brand) => DropdownMenuItem<String>(
                                value: brand,
                                child: Text(brand),
                              ))
                          .toList(),
                      onChanged: (value) {
                        selectedBrand.value = value ?? 'All';
                        applyFilters();
                      },
                    )),
                // Price Sort Popup Menu
                Obx(() => PopupMenuButton<String>(
                      onSelected: (value) {
                        selectedSort.value = value;
                        applyFilters();
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'Price: Low to High',
                          child: Text('Price: Low to High'),
                        ),
                        PopupMenuItem(
                          value: 'Price: High to Low',
                          child: Text('Price: High to Low'),
                        ),
                      ],
                      child: Row(
                        children: [
                          Text(selectedSort.value),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    )),
              ],
            ),
            SizedBox(height: 16.h),
            // Product Grid
            Obx(() => Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1, // One product per row
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 1.0,
                      mainAxisExtent: 220.h,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) => ProductItem(
                      product: filteredProducts[index],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
