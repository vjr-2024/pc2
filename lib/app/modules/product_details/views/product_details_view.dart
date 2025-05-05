import 'dart:io'; // For File operations
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../../../components/custom_icon_button.dart';
import '../../../components/custom_button.dart';
import '../../../components/custom_card.dart';
import '../../../components/product_count_item.dart';
import '../../../components/product_item.dart';
import '../../../data/controllers/data_controller.dart';
import '../../../data/models/product_model.dart';
import '../../../routes/app_pages.dart';
import '../../../components/custom_form_field.dart';
import '../controllers/product_details_controller.dart';

class ProductDetailsView extends GetView<ProductDetailsController> {
  const ProductDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final dataController = Get.find<DataController>();
    final TextEditingController searchController = TextEditingController();

    // Fetch the current product details
    final product = controller.product;
    final productWithImageUrl = dataController.products.firstWhere(
      (p) => p.id == product.id,
      orElse: () => ProductModel(
        id: '',
        name: '',
        image: '',
        price: 0.0,
        pksz: '',
        ctgry: '',
        bulkPrices: [],
        description: '',
        brand: '',
        subctgry: '',
        mrp: 0.0, // Add MRP field
        gst: 0.0, // Add GST field
      ),
    );

    final imageUrl = productWithImageUrl.image.isNotEmpty
        ? productWithImageUrl.image
        : product.image;

    // Determine the displayed image
    final Widget displayedImage =
        (imageUrl.startsWith('/data') && File(imageUrl).existsSync())
            ? Image.file(File(imageUrl), fit: BoxFit.cover)
            : Image.asset(Constants.logo, fit: BoxFit.cover);

    // Fetch up to 3 products from the same brand
    final List<ProductModel> similarProducts = dataController.products
        .where((p) => p.brand == product.brand && p.id != product.id)
        .take(3)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
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
                prefixIcon:
                    SvgPicture.asset(Constants.searchIcon, fit: BoxFit.none),
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
            SizedBox(
              height: 330.h,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SvgPicture.asset(
                      Constants.container,
                      fit: BoxFit.fill,
                      colorFilter: ColorFilter.mode(
                          theme.colorScheme.surface, BlendMode.srcIn),
                    ),
                  ),
                  Positioned(
                    top: 24.h,
                    left: 24.w,
                    right: 24.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomIconButton(
                          onPressed: () {
                            if (Get.previousRoute.isNotEmpty) {
                              Get.back();
                            } else {
                              Get.offAllNamed(Routes.home);
                            }
                          },
                          icon: SvgPicture.asset(
                            Constants.backArrowIcon,
                            fit: BoxFit.none,
                            colorFilter: ColorFilter.mode(
                              theme.appBarTheme.iconTheme?.color ??
                                  Colors.black,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(width: 16.w),
                            CustomIconButton(
                              onPressed: () {
                                Get.toNamed(Routes.cart);
                              },
                              icon: SvgPicture.asset(
                                Constants.cartIcon,
                                fit: BoxFit.none,
                                colorFilter: ColorFilter.mode(
                                  theme.appBarTheme.iconTheme?.color ??
                                      Colors.black,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 80.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: displayedImage.animate().fade().scale(
                            duration: 800.ms,
                            curve: Curves.fastOutSlowIn,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            30.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                product.name,
                style: theme.textTheme.displayMedium,
              ).animate().fade().slide(
                    duration: 300.ms,
                    begin: Offset(-1, 0),
                    curve: Curves.easeInSine,
                  ),
            ),
            8.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                '${product.pksz}, ${product.price}₹',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ).animate().fade().slide(
                    duration: 300.ms,
                    begin: Offset(-1, 0),
                    curve: Curves.easeInSine,
                  ),
            ),
            8.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ProductCountItem(
                product: product,
                onQuantityChanged: (quantity) {
                  controller.product.quantity = quantity;
                },
              ).animate().fade(duration: 200.ms),
            ),

            // (product.mrp > product.effectivePrice && product.quantity > 0)
            //     ? Text(
            //         'You saved: ₹${((product.mrp - product.effectivePrice) * product.quantity).toStringAsFixed(2)}',
            //         style: theme.textTheme.bodyMedium,
            //       )
            //     : SizedBox
            //         .shrink(), // Returns an empty widget if the condition is false

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                product.description,
                style: theme.textTheme.bodyLarge,
              ).animate().fade().slide(
                    duration: 300.ms,
                    begin: Offset(-1, 0),
                    curve: Curves.easeInSine,
                  ),
            ),
            20.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: CustomButton(
                text: 'Add to cart',
                onPressed: () => controller.onAddToCartPressed(),
                fontSize: 16.sp,
                radius: 50.r,
                verticalPadding: 16.h,
                hasShadow: false,
              ).animate().fade().slide(
                    duration: 300.ms,
                    begin: Offset(0, 1),
                    curve: Curves.easeInSine,
                  ),
            ),
            30.verticalSpace,

            // More products from the same brand
            if (similarProducts.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  "More from this brand",
                  style: theme.textTheme.displaySmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              10.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: similarProducts.map((product) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: ProductItem(product: product),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
