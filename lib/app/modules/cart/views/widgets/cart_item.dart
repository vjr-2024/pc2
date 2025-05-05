import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../components/product_count_item.dart';
import '../../../../data/models/product_model.dart';
import '../../controllers/cart_controller.dart';
import '../../../../data/controllers/data_controller.dart';

class CartItem extends GetView<CartController> {
  final ProductModel product;
  const CartItem({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    // Fetch the product data from the DataController
    final dataController = Get.find<DataController>();
    final productWithImageUrl = dataController.products.firstWhere(
      (p) => p.id == product.id,
      orElse: () => ProductModel(
        id: '',
        name: '',
        image: '',
        price: 0.0, // Default price
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

    // Fallback image URL
    final imageUrl = productWithImageUrl.image.isNotEmpty
        ? productWithImageUrl.image
        : product.image;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First row: Product image and details
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.network(imageUrl, width: 50.w, height: 40.h),
              16.horizontalSpace,
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: product.name,
                        style: theme.textTheme.headlineSmall,
                        children: [
                          TextSpan(
                            text: '\n1kg, ${product.price}₹',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          10.verticalSpace,

          // Second row: Product count item
          Align(
            alignment: Alignment.centerRight, // Align to the right
            // child: ProductCountItem(
            //   product: product,
            //   onQuantityChanged: (quantity) {
            //     // Update the cart or any state with the new quantity
            //     controller.updateCartItemQuantity(product.id, quantity);
            //     print('Quantity for ${product.name} updated to $quantity');
            //   },
            // ),
            child: ProductCountItem(product: product),
          ),
          10.verticalSpace,
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
          // Text('GST: ₹${(product.gst * product.quantity).toStringAsFixed(2)}',
          //     style: theme.textTheme.bodyMedium),
          // Text(
          //     'Price: ₹${(product.effectivePrice * product.quantity).toStringAsFixed(2)}',
          //     style: theme.textTheme.bodyLarge
          //         ?.copyWith(color: theme.colorScheme.secondary)),
          // Text('Quantity: x${product.quantity}',
          //     style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
