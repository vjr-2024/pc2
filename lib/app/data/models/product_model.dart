import 'package:hive/hive.dart';

part 'product_model.g.dart'; // Hive generated file

// Model to represent bulk pricing
class BulkPrice {
  final int quantity; // Number of items in bulk
  final double price; // Price for the given quantity

  BulkPrice({
    required this.quantity,
    required this.price,
  });

  // Method to convert a map into a BulkPrice object (e.g., from Firestore)
  factory BulkPrice.fromMap(Map<String, dynamic> data) {
    return BulkPrice(
      quantity: data['quantity'] ?? 0,
      price: (data['price'] ?? 0).toDouble(),
    );
  }

  // Method to convert a BulkPrice object to a map (for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'quantity': quantity,
      'price': price,
    };
  }
}

@HiveType(typeId: 1)
class ProductModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String image;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String ctgry;

  @HiveField(4)
  final String pksz;

  @HiveField(5)
  final String description;

  @HiveField(6)
  int quantity;

  @HiveField(7)
  final double price;

  @HiveField(8)
  final String brand;

  @HiveField(9)
  final String subctgry;

  @HiveField(10)
  double effectivePrice; // New field for effective price

  @HiveField(11)
  final List<BulkPrice> bulkPrices; // Add bulkPrices field

  @HiveField(12)
  final double mrp; // Add MRP field

  @HiveField(13)
  final double gst; // Add GST field

  ProductModel({
    required this.id,
    required this.image,
    required this.name,
    required this.ctgry,
    required this.pksz,
    this.quantity = 0,
    required this.price,
    required this.description,
    required this.bulkPrices, // Initialize the bulkPrices field
    this.brand = '',
    this.subctgry = '',
    this.effectivePrice = 0.0, // Initialize effectivePrice
    required this.mrp, // Initialize MRP
    required this.gst, // Initialize GST
  });

  factory ProductModel.fromFirestore(String id, Map<String, dynamic> data) {
    // Parse the bulkPrices field from Firestore
    List<BulkPrice> bulkPrices = [];
    if (data['bulkPrices'] != null) {
      bulkPrices = List<BulkPrice>.from(
        (data['bulkPrices'] as List).map((bulk) => BulkPrice.fromMap(bulk)),
      );
    }

    double effectivePrice = data['effectivePrice']?.toDouble() ?? 0.0;

    return ProductModel(
      id: id,
      image: data['image'] ?? '',
      name: data['name'] ?? '',
      ctgry: data['ctgry'] ?? '',
      pksz: data['pksz'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      bulkPrices: bulkPrices, // Pass parsed bulkPrices
      effectivePrice: effectivePrice, // Set effectivePrice
      brand: data['brand'] ?? '',
      subctgry: data['subctgry'] ?? '',
      mrp: (data['mrp'] ?? 0).toDouble(), // Set MRP
      gst: (data['gst'] ?? 0).toDouble(), // Set GST
    );
  }

  void updateEffectivePrice(int quantity) {
    // Update the effective price based on the current quantity
    if (bulkPrices.isNotEmpty) {
      final selectedBulkPrice = bulkPrices.lastWhere(
        (bp) => bp.quantity <= quantity,
        orElse: () => BulkPrice(quantity: 0, price: price),
      );
      effectivePrice = selectedBulkPrice.price;
    } else {
      effectivePrice = price;
    }
  }

  // Optional: Add a method to convert the ProductModel back to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'ctgry': ctgry,
      'pksz': pksz,
      'description': description,
      'price': price,
      'quantity': quantity,
      'bulkPrices': bulkPrices.map((bulk) => bulk.toMap()).toList(),
      'effectivePrice': effectivePrice,
      'brand': brand,
      'subctgry': subctgry,
      'mrp': mrp, // Add MRP to map
      'gst': gst, // Add GST to map
    };
  }
}
