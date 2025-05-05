import 'dart:io';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/product_model.dart';

class DataController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instanceFor(
    bucket: 'gs://flutter-procurekart.firebasestorage.app',
  );

  var categories = <CategoryModel>[].obs;
  var products = <ProductModel>[].obs;
  var ads = <String>[].obs; // Holds the list of ad image URLs
  var offers = <String>[].obs; // Holds the list of offer image URLs
  var isLoading = true.obs;

  var debugInfo = ''.obs; // Holds debug information for the UI

  void updateProductQuantity(String productId, int newQuantity) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      products[index].quantity = newQuantity;
      products.refresh(); // Notify listeners
    }
  }

  void logDebug(String message) {
    debugInfo.value += message + '\n'; // Append debug info
  }

  @override
  void onInit() async {
    super.onInit();
    listenForChanges(); // Listen for real-time changes for categories, products, ads, and offers
    logDebug('DataController initialized');
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;

      // Fetch categories
      await fetchCategories();

      // Fetch products
      await fetchProducts();

      // Fetch ads
      await fetchAds();

      // Fetch offers
      await fetchOffers();
    } catch (e) {
      logDebug('Error fetching data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCategories() async {
    final categorySnapshot = await firestore.collection('categories').get();
    final List<CategoryModel> fetchedCategories = [];

    for (var doc in categorySnapshot.docs) {
      final data = doc.data();
      final String imagePath = data['image'];
      final String version =
          data['imageVersion'] ?? ''; // Version for the image
      final String imageUrl = await _fetchImageUrl(imagePath, version);
      if (imageUrl.isNotEmpty) {
        fetchedCategories.add(CategoryModel(
          id: doc.id,
          name: data['name'],
          image: imageUrl,
        ));
      }
    }
    categories.assignAll(fetchedCategories);
  }

  Future<void> fetchProducts() async {
    final productSnapshot = await firestore.collection('products').get();
    final List<ProductModel> fetchedProducts = [];

    for (var doc in productSnapshot.docs) {
      final data = doc.data();
      final String imagePath = data['image'];
      final String version =
          data['imageVersion'] ?? ''; // Version for the image
      final String imageUrl = await _fetchImageUrl(imagePath, version);

      if (imageUrl.isNotEmpty) {
        fetchedProducts.add(ProductModel(
          id: doc.id,
          name: data['name'],
          image: imageUrl,
          ctgry: data['ctgry'],
          pksz: data['pksz'],
          description: data['description'],
          price: (data['price'] ?? 0).toDouble(),
          bulkPrices: (data['bulkPrices'] as List)
              .map((bulkPriceData) =>
                  BulkPrice.fromMap(bulkPriceData as Map<String, dynamic>))
              .toList(),
          brand: data['brand'] ?? '',
          subctgry: data['subctgry'] ?? '',
          mrp: (data['mrp'] ?? 0).toDouble(), // Add MRP field
          gst: (data['gst'] ?? 0).toDouble(), // Add GST field
        ));
      }
    }

    products.assignAll(fetchedProducts);
  }

  Future<void> fetchAds() async {
    final adsSnapshot = await firestore.collection('ads').get();
    final List<String> fetchedAds = [];

    for (var doc in adsSnapshot.docs) {
      final data = doc.data();
      final String imagePath =
          data['image']; // Path to the image in Firebase Storage
      final String version =
          data['imageVersion'] ?? ''; // Version for the image
      final String imageUrl = await _fetchImageUrl(imagePath, version);

      if (imageUrl.isNotEmpty) {
        fetchedAds.add(imageUrl); // Add the fetched URL to the list
      }
    }

    ads.assignAll(fetchedAds);
  }

  Future<void> fetchOffers() async {
    final offersSnapshot = await firestore.collection('offers').get();
    final List<String> fetchedOffers = [];

    for (var doc in offersSnapshot.docs) {
      final data = doc.data();
      final String imagePath =
          data['image']; // Path to the image in Firebase Storage
      final String version =
          data['imageVersion'] ?? ''; // Version for the image
      final String imageUrl = await _fetchImageUrl(imagePath, version);

      if (imageUrl.isNotEmpty) {
        fetchedOffers.add(imageUrl); // Add the fetched URL to the list
      }
    }

    offers.assignAll(fetchedOffers);
  }

  // Method to fetch image URL from Firebase and check local cache
  Future<String> _fetchImageUrl(String path, String version) async {
    try {
      final localPath = await _getLocalImagePath(path);

      // Check if image exists locally and if the version matches
      final file = File(localPath);
      if (await file.exists()) {
        final fileVersion = await _getFileVersion(localPath);
        if (fileVersion == version) {
          return file.path; // Return local path if the image is up-to-date
        }
      }

      // Fetch the image URL from Firebase Storage if not cached
      final imageUrl = await storage.ref(path).getDownloadURL();

      // Download and cache image locally
      await _downloadAndCacheImage(imageUrl, localPath, version);
      return localPath; // Return local path after caching
    } catch (e) {
      logDebug('Error fetching image URL: $e');
      return ''; // Return empty string if the image URL cannot be fetched
    }
  }

  // Get the local path to store the image
  Future<String> _getLocalImagePath(String path) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/${basename(path)}';
  }

  // Get the version stored in the file (for checking updates)
  Future<String> _getFileVersion(String localPath) async {
    final versionFile = File('$localPath.version');
    if (await versionFile.exists()) {
      return await versionFile.readAsString(); // Return the stored version
    }
    return '';
  }

  // Download image from URL and store it in local storage
  Future<void> _downloadAndCacheImage(
      String imageUrl, String localPath, String version) async {
    final response = await http.get(Uri.parse(imageUrl));
    final file = File(localPath);

    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
      final versionFile = File('$localPath.version');
      await versionFile
          .writeAsString(version); // Save version for future checks
    } else {
      throw Exception('Failed to download image');
    }
  }

  void listenForChanges() {
    firestore.collection('categories').snapshots().listen((_) async {
      await fetchCategories();
    });

    firestore.collection('products').snapshots().listen((_) async {
      await fetchProducts();
    });

    firestore.collection('ads').snapshots().listen((_) async {
      await fetchAds();
    });

    firestore.collection('offers').snapshots().listen((_) async {
      await fetchOffers();
    });
  }
}
