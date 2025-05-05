import 'dart:io';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';
import 'package:csv/csv.dart';

import '../../../../utils/constants.dart';
import '../../../components/category_item.dart';
import '../../../components/custom_form_field.dart';
import '../../../components/custom_icon_button.dart';
import '../../../components/dark_transition.dart';
import '../../../components/product_item.dart';
import '../controllers/home_controller.dart';
import '../../../data/controllers/data_controller.dart';
import '../../../data/models/product_model.dart';
import '../../../services/firebase_data_service.dart';
import '../../../data/controllers/user_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);

  final HomeController controller1 = Get.find<HomeController>();
  final DataController dataController = Get.find<DataController>();
  final UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final TextEditingController searchController = TextEditingController();

    return DarkTransition(
      offset: Offset(context.width, -1),
      isDark: !controller.isLightTheme,
      builder: (context, _) => Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: -100.h,
              child: SvgPicture.asset(
                Constants.container,
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.background,
                  BlendMode.srcIn,
                ),
              ),
            ),
            ListView(
              children: [
                Column(
                  children: [
                    // User Greeting
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 24.w),
                      title: Text(
                        'Namasthe',
                        style: GoogleFonts.roboto(
                          fontSize: 12.sp,
                        ),
                      ),
                      subtitle:
                          FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(controller1.currentUser)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text(
                              'Guest',
                              style: GoogleFonts.roboto(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.normal,
                              ),
                            );
                          }

                          if (snapshot.hasError ||
                              !snapshot.hasData ||
                              snapshot.data?.data() == null) {
                            return Text(
                              'Guest',
                              style: GoogleFonts.roboto(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.normal,
                              ),
                            );
                          }

                          final data = snapshot.data?.data();
                          final username = data?['username'] ?? 'Guest';

                          return Text(
                            username,
                            style: GoogleFonts.roboto(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.normal,
                            ),
                          );
                        },
                      ),
                      leading: CircleAvatar(
                        radius: 22.r,
                        backgroundColor: theme.primaryColorDark,
                        child: ClipOval(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Image.asset(Constants.avatar),
                          ),
                        ),
                      ),
                    ),
                    10.verticalSpace,

                    // Search Field
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
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.h, horizontal: 10.w),
                        focusedBorderColor: Colors.transparent,
                        isSearchField: true,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.search,
                        prefixIcon: SvgPicture.asset(
                          Constants.searchIcon,
                          fit: BoxFit.none,
                        ),
                        onSubmitted: (query) {
                          print('onSubmitted called with value: $query');
                          if (query != null && query.isNotEmpty) {
                            print('search result process start');
                            // Perform the search
                            final searchResults = dataController.products
                                .where((product) => product.name
                                    .toLowerCase()
                                    .contains(query.toLowerCase()))
                                .toList();

                            print(
                                'search result count: ${searchResults.length}');
                            print('SearchResults: $searchResults');

                            if (searchResults.isNotEmpty) {
                              Get.toNamed('/search-results',
                                  arguments: searchResults);
                            } else {
                              print('search result empty');
                              Get.snackbar('No Results Found',
                                  'No products match your search query.');
                            }
                          } else {
                            // Handle empty search query if needed
                            print('empty search');
                          }
                        },
                      ),
                    ),
                    20.verticalSpace,

                    // Offers Carousel
                    Obx(() {
                      if (dataController.offers.isEmpty) {
                        return Center(
                          child: Text(
                            "No Offers Available",
                            style: GoogleFonts.roboto(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        );
                      }

                      return CarouselSlider.builder(
                        itemCount: dataController.offers.length,
                        itemBuilder: (context, index, realIndex) {
                          final offerImageUrl = dataController.offers[index];
                          final Widget displayedImage;
                          if (offerImageUrl.startsWith('/data') &&
                              File(offerImageUrl).existsSync()) {
                            // Image exists in local storage, display it
                            displayedImage = Image.file(
                              File(offerImageUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                dataController.logDebug(
                                    '❌ Error loading offer image: $error');
                                return Icon(Icons.broken_image,
                                    size: 50, color: Colors.grey);
                              },
                            );
                          } else {
                            // Fallback to default if image is not found locally
                            displayedImage = Image.asset(
                              Constants.logo,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                dataController.logDebug(
                                    '❌ Error loading placeholder image: $error');
                                return Icon(Icons.image_not_supported,
                                    size: 50, color: Colors.grey);
                              },
                            );
                          }

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: displayedImage,
                          );
                        },
                        options: CarouselOptions(
                          autoPlay: dataController.offers.length > 1,
                          enableInfiniteScroll:
                              dataController.offers.length > 1,
                          viewportFraction:
                              dataController.offers.length > 1 ? 0.8 : 1.0,
                          height: 200.h,
                          enlargeCenterPage: dataController.offers.length > 1,
                        ),
                      );
                    }),

                    // Categories Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Column(
                        children: [
                          20.verticalSpace,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Categories ',
                                style: GoogleFonts.roboto(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          16.verticalSpace,
                          Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 6.0,
                            runSpacing: 8.0,
                            children: [
                              for (int i = 0;
                                  i < controller.categories.length;
                                  i++)
                                // CategoryItem(
                                //     category: controller.categories[i]),
                                Container(
                                  width: MediaQuery.of(context).size.width / 4 -
                                      12, // Maximum of 4 items per row
                                  child: CategoryItem(
                                    category: controller.categories[i],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Ads Carousel
                    Obx(() {
                      if (dataController.ads.isEmpty) {
                        return Center(
                          child: Text(
                            "No Ads Available",
                            style: GoogleFonts.roboto(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        );
                      }

                      return CarouselSlider.builder(
                        itemCount: dataController.ads.length,
                        itemBuilder: (context, index, realIndex) {
                          final adImageUrl = dataController.ads[index];
                          final Widget displayedImage;
                          if (adImageUrl.startsWith('/data') &&
                              File(adImageUrl).existsSync()) {
                            // Image exists in local storage, display it
                            displayedImage = Image.file(
                              File(adImageUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                dataController.logDebug(
                                    '❌ Error loading ad image: $error');
                                return Icon(Icons.broken_image,
                                    size: 50, color: Colors.grey);
                              },
                            );
                          } else {
                            // Fallback to default if image is not found locally
                            displayedImage = Image.asset(
                              Constants.logo,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                dataController.logDebug(
                                    '❌ Error loading placeholder image: $error');
                                return Icon(Icons.image_not_supported,
                                    size: 50, color: Colors.grey);
                              },
                            );
                          }

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: displayedImage,
                          );
                        },
                        options: CarouselOptions(
                          autoPlay: dataController.ads.length > 1,
                          enableInfiniteScroll: dataController.ads.length > 1,
                          viewportFraction:
                              dataController.ads.length > 1 ? 0.8 : 1.0,
                          height: 200.h,
                          enlargeCenterPage: dataController.ads.length > 1,
                        ),
                      );
                    }),

                    // ✅ Upload Data from CSV Button (ONLY for Supplier)
                    Obx(() {
                      if (userController.userRole.value == 'supplier') {
                        return ElevatedButton(
                          onPressed: () async {
                            try {
                              dataController
                                  .logDebug("Starting data upload from CSV...");
                              await FirebaseDataService
                                  .updateCategoriesFromFirebase();
                              await FirebaseDataService
                                  .updateProductsFromFirebase();
                              dataController.logDebug(
                                  "Categories and Products updated from CSV.");
                              Get.snackbar("Success",
                                  "Categories and Products updated from CSV.");
                            } catch (e) {
                              dataController.logDebug("CSV Upload Failed: $e");
                              Get.snackbar(
                                  "Error", "Failed to upload data from CSV.");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, // Background color
                          ),
                          child: Text(
                            'Upload Data from CSV',
                            style: TextStyle(color: Colors.black), // Black text
                          ),
                        );
                      } else {
                        return SizedBox(); // Hide button for non-suppliers
                      }
                    }),

                    // // Debug Information Display
                    // Obx(() {
                    //   return Padding(
                    //     padding: EdgeInsets.all(16.0),
                    //     child: Text(
                    //       dataController.debugInfo.value,
                    //       style: TextStyle(
                    //         fontSize: 12.sp,
                    //         color: Colors.red,
                    //       ),
                    //     ),
                    //   );
                    // }),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
