import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../../../components/custom_icon_button.dart';
import '../../../components/product_item.dart';
import '../controllers/products_controller.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/controllers/data_controller.dart';
import '../../../components/custom_form_field.dart';
import '../../../routes/app_pages.dart';

class ProductsView extends GetView<ProductsController> {
  const ProductsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final CategoryModel? category = Get.arguments as CategoryModel?;
    final TextEditingController searchController = TextEditingController();

    if (category == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Products')),
        body: Center(child: Text('No category selected.')),
      );
    }

    final DataController dataController = Get.find<DataController>();

    final RxList<ProductModel> filteredProducts = dataController.products
        .where((product) => product.ctgry == category.name)
        .toList()
        .obs;

    final RxString selectedBrand = 'All'.obs;
    final RxString selectedSort = 'Price: Low to High'.obs;

    final List<String> brandList = [
      'All',
      ...filteredProducts.map((p) => p.brand).toSet()
    ];

    void applyFilters() {
      final filtered = dataController.products
          .where((product) =>
              product.ctgry == category.name &&
              (selectedBrand.value == 'All' ||
                  product.brand == selectedBrand.value))
          .toList();

      if (selectedSort.value == 'Price: Low to High') {
        filtered.sort((a, b) => a.price.compareTo(b.price));
      } else if (selectedSort.value == 'Price: High to Low') {
        filtered.sort((a, b) => b.price.compareTo(a.price));
      }

      filteredProducts.assignAll(filtered);
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomIconButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  } else {
                    Get.back();
                  }
                },
                backgroundColor: theme.scaffoldBackgroundColor,
                borderColor: theme.dividerColor,
                icon: SvgPicture.asset(
                  Constants.backArrowIcon,
                  fit: BoxFit.none,
                  colorFilter: ColorFilter.mode(
                    theme.appBarTheme.iconTheme?.color ?? Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              Text(
                category.name,
                style: theme.textTheme.displaySmall,
              ),
              Row(
                children: [
                  SizedBox(width: 16.w),
                  CustomIconButton(
                    onPressed: () {
                      Get.toNamed(Routes.cart);
                    },
                    backgroundColor: theme.scaffoldBackgroundColor,
                    borderColor: theme.dividerColor,
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: CustomFormField(
                controller: searchController,
                backgroundColor: theme.primaryColorDark,
                textSize: 14.sp,
                hint: 'Search products',
                hintFontSize: 14.sp,
                hintColor: theme.hintColor,
                maxLines: 1,
                borderRound: 60.r,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                focusedBorderColor: Colors.transparent,
                isSearchField: true,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                prefixIcon: SvgPicture.asset(
                  Constants.searchIcon,
                  fit: BoxFit.none,
                ),
                onSubmitted: (query) {
                  if (query.isNotEmpty) {
                    final searchResults = dataController.products
                        .where((product) => product.name
                            .toLowerCase()
                            .contains(query.toLowerCase()))
                        .toList();

                    if (searchResults.isNotEmpty) {
                      Get.toNamed('/search-results', arguments: searchResults);
                    } else {
                      Get.snackbar('No Results Found',
                          'No products match your search query.');
                    }
                  }
                },
              ),
            ),
            5.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
            Obx(() => Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
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
