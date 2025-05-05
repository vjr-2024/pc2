import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../data/controllers/data_controller.dart';

class FirebaseDataService {
  static final DataController dataController = Get.find<DataController>();
  static final FirebaseStorage storage = FirebaseStorage.instanceFor(
    bucket: 'gs://flutter-procurekart.firebasestorage.app',
  );

  static Future<void> updateCategoriesFromFirebase() async {
    try {
      dataController
          .logDebug("Fetching categories CSV from Firebase Storage...");
      final ref = storage.ref().child('categories.csv'); // FIXED
      final url = await ref.getDownloadURL();
      final request = await HttpClient().getUrl(Uri.parse(url));
      final response = await request.close();
      final csvData = await utf8.decoder.bind(response).join();

      List<List<dynamic>> rows = CsvToListConverter().convert(csvData);
      dataController.logDebug("Categories CSV Data Loaded.");

      for (int i = 1; i < rows.length; i++) {
        List<dynamic> row = rows[i];
        Map<String, dynamic> categoryData = {
          'name': row[0]?.toString() ?? '',
          'description': row[1]?.toString() ?? '',
          'image': row[2]?.toString() ?? '',
          'imageVersion': row[3]?.toString() ?? '',
        };

        await FirebaseFirestore.instance
            .collection('categories')
            .doc(categoryData['name'].toString())
            .set(categoryData, SetOptions(merge: true));
      }

      dataController.logDebug("Categories updated successfully.");
    } catch (e) {
      dataController
          .logDebug("Error updating categories from Firebase Storage: $e");
    }
  }

  static Future<void> updateProductsFromFirebase() async {
    try {
      dataController.logDebug("Fetching products CSV from Firebase Storage...");
      final ref = storage.ref().child('products.csv'); // FIXED
      final url = await ref.getDownloadURL();
      final request = await HttpClient().getUrl(Uri.parse(url));
      final response = await request.close();
      final csvData = await utf8.decoder.bind(response).join();

      List<List<dynamic>> rows = CsvToListConverter().convert(csvData);
      dataController.logDebug("Products CSV Data Loaded.");

      for (int i = 1; i < rows.length; i++) {
        List<dynamic> row = rows[i];

        List<Map<String, dynamic>> bulkPrices = [];
        if (row.length > 10 &&
            row[10] != null &&
            row[10].toString().isNotEmpty) {
          try {
            bulkPrices = (jsonDecode(row[10]) as List)
                .map((item) => {
                      'quantity': item['quantity'] ?? 0,
                      'price': item['price'] ?? 0.0,
                    })
                .toList();
          } catch (e) {
            dataController.logDebug("Error parsing bulkPrices for row $i: $e");
          }
        }

        Map<String, dynamic> productData = {
          'name': row[0]?.toString() ?? '',
          'id': row[1]?.toString() ?? '',
          'ctgry': row[2]?.toString() ?? '',
          'image': row[3]?.toString() ?? '',
          'description': row[4]?.toString() ?? '',
          'pksz': row[5]?.toString() ?? '',
          'price': num.tryParse(row[6]?.toString() ?? '') ?? 0,
          'quantity': num.tryParse(row[7]?.toString() ?? '') ?? 0,
          'brand': row[8]?.toString() ?? '',
          'subctgry': row[9]?.toString() ?? '',
          'bulkPrices': bulkPrices.isNotEmpty ? bulkPrices : [],
          'imageVersion': row[11]?.toString() ?? '',
          'mrp': num.tryParse(row[12]?.toString() ?? '') ?? 0,
          'gst': num.tryParse(row[13]?.toString() ?? '') ?? 0,
          'stock': num.tryParse(row[14]?.toString() ?? '') ?? 0,
        };

        await FirebaseFirestore.instance
            .collection('products')
            .doc(productData['id'].toString())
            .set(productData, SetOptions(merge: true));
      }

      dataController.logDebug("Products updated successfully.");
    } catch (e) {
      dataController
          .logDebug("Error updating products from Firebase Storage: $e");
    }
  }
}
