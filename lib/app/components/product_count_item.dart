import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import '../data/controllers/data_controller.dart';
import '../data/models/product_model.dart';
import 'custom_icon_button.dart';

class ProductCountItem extends StatelessWidget {
  final ProductModel product;

  /// Optional callback function to notify quantity changes
  final Function(int)? onQuantityChanged;

  ProductCountItem({
    Key? key,
    required this.product,
    this.onQuantityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final dataController = Get.find<DataController>();

    // Compute the effective price based on current quantity
    double getEffectivePrice(int quantity) {
      if (product.bulkPrices.isNotEmpty) {
        final selectedBulkPrice = product.bulkPrices.lastWhere(
          (bp) => bp.quantity <= quantity,
          orElse: () => BulkPrice(quantity: 0, price: product.price),
        );
        return selectedBulkPrice.price;
      }
      return product.price;
    }

    TextEditingController _quantityController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row with effective price, decrement button, quantity entry field, and increment button
        Row(
          children: [
            // Effective price display
            Obx(() {
              final currentProduct =
                  dataController.products.firstWhere((p) => p.id == product.id);

              product.updateEffectivePrice(currentProduct.quantity
                  .toInt()); // Ensure the quantity is converted to int
              // return Container(
              //   width: 100.w,
              //   padding: EdgeInsets.symmetric(vertical: 4.h),
              //   alignment: Alignment.center,
              //   decoration: BoxDecoration(
              //     border: Border.all(color: theme.colorScheme.primary),
              //     borderRadius: BorderRadius.circular(8.r),
              //   ),
              //   child: Text(
              //     '₹${(product.effectivePrice).toStringAsFixed(2)}',
              //     style: theme.textTheme.bodyLarge,
              //   ),
              // );
              return Text(
                '₹${(product.effectivePrice).toStringAsFixed(2)}',
                style: theme.textTheme.bodyLarge,
              );
            }),
            8.horizontalSpace,
            Text(
              '₹${(product.mrp).toStringAsFixed(2)}',
              style: theme.textTheme.bodyLarge?.copyWith(
                decoration: TextDecoration.lineThrough, // Strikethrough effect
                color: Colors
                    .grey, // Optional: Makes it look faded like a typical MRP
              ),
            ),
            48.horizontalSpace,
            // Decrement button
            CustomIconButton(
              width: 24.w,
              height: 24.h,
              onPressed: () {
                if (product.quantity > 1) {
                  final newQuantity = product.quantity - 1;
                  dataController.updateProductQuantity(product.id, newQuantity);
                  _quantityController.text = newQuantity.toString();
                  onQuantityChanged?.call(newQuantity);
                } else {
                  print('Cannot decrease quantity below 1');
                }
              },
              icon: SvgPicture.asset(
                Constants.removeIcon,
                fit: BoxFit.none,
              ),
              backgroundColor: theme.cardColor,
            ),
            8.horizontalSpace,

            // Quantity entry cum display field
            Obx(() {
              final currentProduct =
                  dataController.products.firstWhere((p) => p.id == product.id);
              _quantityController.text = currentProduct.quantity.toString();

              return SizedBox(
                width: 50.w,
                height: 24.h,
                child: TextFormField(
                  controller: _quantityController,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onChanged: (value) {
                    final newQuantity =
                        int.tryParse(value) ?? currentProduct.quantity;
                    if (newQuantity > 0) {
                      dataController.updateProductQuantity(
                          product.id, newQuantity);
                      onQuantityChanged?.call(newQuantity);
                    }
                  },
                ),
              );
            }),
            8.horizontalSpace,

            // Increment button
            CustomIconButton(
              width: 24.w,
              height: 24.h,
              onPressed: () {
                final newQuantity = product.quantity + 1;
                dataController.updateProductQuantity(product.id, newQuantity);
                _quantityController.text = newQuantity.toString();
                onQuantityChanged?.call(newQuantity);
              },
              icon: SvgPicture.asset(
                Constants.addIcon,
                fit: BoxFit.none,
              ),
              backgroundColor: theme.primaryColor,
            ),
          ],
        ),
        10.verticalSpace,

        // // MRP Display
        // Obx(() {
        //   final double mrp = product.mrp.isFinite ? product.mrp : 0.0;
        //   return Container(
        //     width: double.infinity,
        //     padding: EdgeInsets.symmetric(vertical: 4.h),
        //     color: Colors.green
        //         .withOpacity(0.1), // Debug background (remove later)
        //     child: Text(
        //       'MRP: ₹${mrp.toStringAsFixed(2)}',
        //       style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black),
        //     ),
        //   );
        // }),
        // 10.verticalSpace,

        // // Effective Price Display
        // Obx(() {
        //   final double effectivePrice = product.effectivePrice.isFinite
        //       ? product.effectivePrice
        //       : product.price;
        //   return Container(
        //     width: double.infinity,
        //     padding: EdgeInsets.symmetric(vertical: 4.h),
        //     color:
        //         Colors.blue.withOpacity(0.1), // Debug background (remove later)
        //     child: Text(
        //       'Effective Price: ₹${effectivePrice.toStringAsFixed(2)}',
        //       style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black),
        //     ),
        //   );
        // }),
        // 10.verticalSpace,

        // // Quantity Display
        // Obx(() {
        //   final int quantity = product.quantity.isFinite ? product.quantity : 1;
        //   return Container(
        //     width: double.infinity,
        //     padding: EdgeInsets.symmetric(vertical: 4.h),
        //     color: Colors.orange
        //         .withOpacity(0.1), // Debug background (remove later)
        //     child: Text(
        //       'Quantity: $quantity',
        //       style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black),
        //     ),
        //   );
        // }),

        // Obx(() {
        //   return ((product.mrp > product.effectivePrice) &&
        //           product.quantity > 0)
        //       ? Text(
        //           'You saved: ₹${((product.mrp - product.effectivePrice) * product.quantity).toStringAsFixed(2)}',
        //           style: theme.textTheme.bodyMedium,
        //         )
        //       : SizedBox.shrink();
        // }),

        // Bulk pricing details
        if (product.bulkPrices.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...product.bulkPrices.map(
                (bulkPrice) => Row(
                  children: [
                    Text(
                      'Buy ${bulkPrice.quantity}+ items @ ',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      '${bulkPrice.price.toStringAsFixed(2)} ₹ per unit',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
