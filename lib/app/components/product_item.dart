import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../data/models/product_model.dart';
import '../routes/app_pages.dart';
import '../data/controllers/data_controller.dart';
import 'product_count_item.dart';
import 'dart:io'; // Add this import
import '../../../../utils/constants.dart';

class ProductItem extends StatelessWidget {
  final ProductModel product;
  const ProductItem({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    // Fetch the product data from the DataController
    final dataController = Get.find<DataController>();
    final productWithImageUrl = dataController.products
        .firstWhere((p) => p.id == product.id, orElse: () {
      return ProductModel(
        id: '',
        name: '',
        image: '',
        price: 0.0,
        pksz: '',
        ctgry: '',
        bulkPrices: [
          BulkPrice(quantity: 0, price: 0.0)
        ], // Default bulk price as fallback
        description: '',
        brand: '',
        subctgry: '',
        mrp: 0.0, // Add MRP field
        gst: 0.0, // Add GST field
      );
    });

    // Logic for displaying image from local storage
    final imageUrl = productWithImageUrl.image;
    final Widget displayedImage;
    if (imageUrl.startsWith('/data') && File(imageUrl).existsSync()) {
      displayedImage = Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
      );
    } else {
      displayedImage = Image.asset(
        Constants.logo,
        fit: BoxFit.cover,
      );
    }

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.productdetails, arguments: product),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 100.h, // Minimum height to avoid shrinking too small
          maxHeight: 250.h, // Prevent unnecessary height expansion
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First Row: Product name, package size, and description
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side: Product name, package size, description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product name
                        Text(
                          product.name,
                          style: theme.textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ).animate().fade().slide(
                              duration: 300.ms,
                              begin: Offset(0, 1), // Slide vertically (Y-axis)
                              curve: Curves.easeInSine,
                            ),
                        5.verticalSpace,
                        // Package size and description
                        Text(
                          product.pksz,
                          style: theme.textTheme.bodyMedium,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          product.description,
                          style: theme.textTheme.bodySmall,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Right side: Product image
                  SizedBox(
                    width: 60.w, // Adjust image size if necessary
                    child: displayedImage,
                  ),
                ],
              ),
              10.verticalSpace, // Space between the top content and quantity control

              // Quantity control (ProductCountItem)
              Row(
                children: [
                  ProductCountItem(product: product),
                ],
              ),
              SizedBox(height: 10.h), // Add space to avoid overflow

              // (product.mrp > product.effectivePrice && product.quantity > 0)
              //     ? Text(
              //         'You saved: ₹${((product.mrp - product.effectivePrice) * product.quantity).toStringAsFixed(2)}',
              //         style: theme.textTheme.bodyMedium,
              //       )
              //     : SizedBox
              //         .shrink(), // Returns an empty widget if the condition is false

              // New fields
              // Text('MRP: ₹${product.mrp.toStringAsFixed(2)}',
              //     style: theme.textTheme.bodyMedium),
              // Text(
              //     'Discount: ₹${(product.mrp - product.effectivePrice).toStringAsFixed(2)}',
              //     style: theme.textTheme.bodyMedium),
              // Text(
              //     'GST: ₹${(product.gst * product.quantity).toStringAsFixed(2)}',
              //     style: theme.textTheme.bodyMedium),
              // Text(
              //     'Price: ₹${(product.effectivePrice * product.quantity).toStringAsFixed(2)}',
              //     style: theme.textTheme.bodyLarge
              //         ?.copyWith(color: theme.colorScheme.secondary)),
              // Text('Quantity: x${product.quantity}',
              //     style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}
