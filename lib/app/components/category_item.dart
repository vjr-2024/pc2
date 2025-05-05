import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/category_model.dart';
import '../data/controllers/data_controller.dart';
import '../../../../utils/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryItem extends StatelessWidget {
  final CategoryModel category;

  const CategoryItem({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dataController = Get.find<DataController>();

    return Obx(() {
      final categoryWithImageUrl = dataController.categories.firstWhere(
        (c) => c.id == category.id,
        orElse: () => CategoryModel(id: '', name: '', image: ''),
      );

      final imageUrl = categoryWithImageUrl.image.isNotEmpty
          ? categoryWithImageUrl.image
          : category.image;

      final Widget displayedImage;
      if (imageUrl.startsWith('/data') && File(imageUrl).existsSync()) {
        displayedImage = Image.file(
          File(imageUrl),
          fit: BoxFit.cover,
          width: 72,
          height: 72,
          errorBuilder: (context, error, stackTrace) {
            dataController.logDebug('❌ Error loading image: $error');
            return Icon(Icons.broken_image,
                color: theme.colorScheme.error, size: 36);
          },
        );
      } else {
        displayedImage = Image.asset(
          Constants.logo,
          fit: BoxFit.cover,
          width: 72,
          height: 72,
          errorBuilder: (context, error, stackTrace) {
            dataController
                .logDebug('❌ Error loading placeholder image: $error');
            return Icon(Icons.image_not_supported,
                color: theme.colorScheme.error, size: 36);
          },
        );
      }

      return GestureDetector(
        onTap: () => Get.toNamed('/products', arguments: category),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: theme.cardColor,
              child: ClipOval(child: displayedImage),
            ),
            SizedBox(height: 5),
            // Text widget with max width and multi-line support
            Container(
              width: MediaQuery.of(context).size.width / 4 -
                  12, // Limiting width to 1/4 of screen
              child: Text(
                category.name,
                //style: TextStyle(fontSize: 12),
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
                maxLines: 2, // Limit to 2 lines
                overflow: TextOverflow.ellipsis, // Ellipsis for overflow
                softWrap: true, // Allow soft wrapping
                textAlign: TextAlign.center, // Center align text
              ),
            ),
          ],
        ),
      );
    });
  }
}
