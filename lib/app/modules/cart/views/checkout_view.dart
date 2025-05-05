import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import this package for screen utility
import 'package:get/get.dart';
import '../../../components/custom_button.dart'; // Import the custom button component
import '../controllers/cart_controller.dart';

class CheckoutView extends GetView<CartController> {
  const CheckoutView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout', style: theme.textTheme.headlineSmall),
      ),
      body: GetBuilder<CartController>(
        builder: (_) => Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.orderPlaced)
                _buildOrderSummary(theme, controller)
              else ...[
                Text(
                  'Order Details',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                ...controller.products.map(
                  (product) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: RichText(
                                text: TextSpan(
                                  text: product.name,
                                  style: theme.textTheme.bodyLarge,
                                  children: [
                                    TextSpan(
                                      text:
                                          '\n₹${(product.effectivePrice * product.quantity).toStringAsFixed(2)}',
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        color: theme.colorScheme.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Text('x${product.quantity}',
                                style: theme.textTheme.bodyLarge),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'MRP: ₹${product.mrp.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          'Discount: ₹${(product.mrp - product.effectivePrice).toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          //'GST: ₹${(product.gst * product.quantity).toStringAsFixed(2)}',
                          'GST: ₹${((product.effectivePrice) * (1 - (1 / (1 + (product.gst) / 100))) * product.quantity).toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(thickness: 1),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₹${controller.products.fold<double>(0, (sum, product) => sum + (product.quantity * product.effectivePrice)).toStringAsFixed(2)}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total GST',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        //'₹${controller.products.fold<double>(0, (sum, product) => sum + (product.quantity * product.gst)).toStringAsFixed(2)}',
                        '₹${controller.products.fold<double>(0, (sum, product) => sum + (product.quantity * ((product.effectivePrice) * (1 - (1 / (1 + (product.gst) / 100)))))).toStringAsFixed(2)}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                Center(
                  child: CustomButton(
                    text: 'Place Order',
                    onPressed: () {
                      controller.orderSummary = List.from(controller
                          .products); // Ensure orderSummary is populated
                      controller.onPurchaseNowPressed();
                      controller.update(); // Trigger GetX update
                    },
                    fontSize: 16.sp,
                    radius: 50.r,
                    verticalPadding: 16.h,
                    hasShadow: false,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(ThemeData theme, CartController controller) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Invoice Number: ${controller.invoiceNumber}',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 16.h),
          ...controller.orderSummary.map(
            (product) => Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        text: product.name,
                        style: theme.textTheme.bodyLarge,
                        children: [
                          TextSpan(
                            text:
                                '\n₹${(product.effectivePrice * product.quantity).toStringAsFixed(2)}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text('x${product.quantity}',
                      style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          ),
          const Divider(thickness: 1),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₹${controller.orderSummary.fold<double>(0, (sum, product) => sum + (product.quantity * product.effectivePrice)).toStringAsFixed(2)}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
