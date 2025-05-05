import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../controllers/orders_controller.dart';
import 'package:grocery_app/app/modules/orders/views/order_tracking_map.dart';

class OrdersView extends GetView<OrdersController> {
  OrdersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();
    controller.refreshOrders();

    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (status) {
              controller.filterOrdersByStatus(status);
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(value: 'Pending', child: Text('Pending')),
                const PopupMenuItem(
                    value: 'Delivered', child: Text('Delivered')),
                const PopupMenuItem(
                    value: 'Cancelled', child: Text('Cancelled')),
                const PopupMenuItem(value: 'Shipped', child: Text('Shipped')),
                const PopupMenuItem(
                    value: 'Out for Delivery', child: Text('Out for Delivery')),
                const PopupMenuItem(value: 'All', child: Text('All')),
              ];
            },
            icon: const Icon(Icons.filter_list, color: Colors.white),
          ),
        ],
      ),
      body: Obx(() {
        // Sort the filtered orders by timestamp in descending order
        controller.filteredOrders.sort((a, b) {
          DateTime aDate = (a['timestamp'] is Timestamp)
              ? (a['timestamp'] as Timestamp).toDate()
              : DateTime.now();
          DateTime bDate = (b['timestamp'] is Timestamp)
              ? (b['timestamp'] as Timestamp).toDate()
              : DateTime.now();
          return bDate.compareTo(aDate); // Descending order (latest first)
        });

        if (controller.filteredOrders.isEmpty) {
          return const Center(
            child: Text(
              'No orders found.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.filteredOrders.length,
          itemBuilder: (context, index) {
            final order = controller.filteredOrders[index];
            final products = order['products'] as List<dynamic>;
            final documentId = order['documentId'] ?? 'N/A';
            final deliveryBoyId = order['deliveryBoyId'] ??
                ''; // Extract deliveryBoyId from the order

            DateTime orderDate = (order['timestamp'] is Timestamp)
                ? (order['timestamp'] as Timestamp).toDate()
                : DateTime.now(); // Safely use the timestamp

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Invoice #: $documentId',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueAccent,
                          ),
                        ),
                        Chip(
                          label: Text(
                            order['status'] ?? 'Unknown',
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: _getStatusColor(order['status']),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date: ${orderDate.toLocal()}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const Divider(),
                    ...products.map((product) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              product['name'] ?? '',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              'x${product['quantity']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              '\₹${product['price']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const Divider(),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '\₹${order['totalPrice'] ?? '0.00'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                        ]),
                    const Divider(),

                    // ///display this button only if the status is shipped
                    // ElevatedButton(
                    //   onPressed: () async {
                    //     if (deliveryBoyId.isEmpty) {
                    //       _showSnackbar("Error", "No delivery boy assigned.");
                    //       return;
                    //     }

                    //     try {
                    //       // Request location permission first
                    //       bool hasPermission =
                    //           await _handleLocationPermission();
                    //       if (!hasPermission) return;

                    //       final deliveryBoyLocation =
                    //           await _fetchDeliveryBoyLocation(deliveryBoyId);

                    //       if (deliveryBoyLocation == null) {
                    //         _showSnackbar("Error",
                    //             "Delivery boy location not available $deliveryBoyId.");
                    //         return;
                    //       }

                    //       final userLocation = await _getCurrentLocation();

                    //       final directions = await _getRouteAndETA(
                    //         deliveryBoyLocation['latitude'],
                    //         deliveryBoyLocation['longitude'],
                    //         userLocation.latitude,
                    //         userLocation.longitude,
                    //       );

                    //       if (directions == null) {
                    //         _showSnackbar(
                    //             "Error", "Failed to fetch directions.");
                    //         return;
                    //       }

                    //       _navigateToMap(
                    //         context,
                    //         userLocation.latitude,
                    //         userLocation.longitude,
                    //         deliveryBoyLocation['latitude'],
                    //         deliveryBoyLocation['longitude'],
                    //         directions['eta'],
                    //         directions['polyline'],
                    //       );
                    //     } catch (e) {
                    //       _showSnackbar("Error", "An error occurred: $e");
                    //     }
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor:
                    //         Colors.blueAccent, // Button background color
                    //     foregroundColor:
                    //         Colors.black, // Text color changed to black
                    //   ),
                    //   child: const Text('Track Order'),
                    // ),
                    //
                    ElevatedButton(
                      onPressed: () async {
                        if (deliveryBoyId.isEmpty) {
                          _showSnackbar("Error", "No delivery boy assigned.");
                          return;
                        }

                        // Show loading dialog
                        _showLoadingDialog(context, "Fetching location...");

                        try {
                          bool hasPermission =
                              await _handleLocationPermission();
                          if (!hasPermission) {
                            Navigator.pop(context); // Dismiss loading dialog
                            return;
                          }

                          final deliveryBoyLocation =
                              await _fetchDeliveryBoyLocation(deliveryBoyId);

                          if (deliveryBoyLocation == null) {
                            Navigator.pop(context); // Dismiss loading dialog
                            _showSnackbar("Error",
                                "Delivery boy location not available.");
                            return;
                          }

                          final userLocation = await _getCurrentLocation();

                          final directions = await _getRouteAndETA(
                            deliveryBoyLocation['latitude'],
                            deliveryBoyLocation['longitude'],
                            userLocation.latitude,
                            userLocation.longitude,
                          );

                          if (directions == null) {
                            Navigator.pop(context); // Dismiss loading dialog
                            _showSnackbar(
                                "Error", "Failed to fetch directions.");
                            return;
                          }

                          Navigator.pop(context); // Dismiss loading dialog

                          _navigateToMap(
                            context,
                            userLocation.latitude,
                            userLocation.longitude,
                            deliveryBoyLocation['latitude'],
                            deliveryBoyLocation['longitude'],
                            directions['eta'],
                            directions['polyline'],
                          );
                        } catch (e) {
                          Navigator.pop(context); // Dismiss loading dialog
                          _showSnackbar("Error", "An error occurred: $e");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.black, // Text color
                      ),
                      child: const Text('Track Order'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // Handle location permission
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackbar("Location Disabled", "Please enable location services.");
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackbar("Permission Denied",
            "Location permission is required to track the order.");
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackbar("Permission Denied Forever",
          "Location permission is permanently denied.");
      return false;
    }

    return true;
  }

  Future<Map<String, dynamic>?> _fetchDeliveryBoyLocation(
      String deliveryBoyId) async {
    try {
      // Debug: Notify when fetching starts
      _showSnackbar(
          "Debug", "Fetching location for delivery boy ID: $deliveryBoyId");

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(deliveryBoyId)
          .get();

      // Debug: Check if the document exists
      if (!snapshot.exists) {
        _showSnackbar("Debug", "No document found for ID: $deliveryBoyId");
        return null;
      }

      final data = snapshot.data();

      // Debug: Check if data is null
      if (data == null) {
        _showSnackbar("Debug", "Document data is null for ID: $deliveryBoyId");
        return null;
      }

      // Debug: Show fetched data
      _showSnackbar("Debug", "Fetched data: ${data.toString()}");

      // Convert latitude and longitude to double
      final latitude = data['latitude']?.toDouble();
      final longitude = data['longitude']?.toDouble();

      // Debug: Check if latitude and longitude are present
      if (latitude == null || longitude == null) {
        _showSnackbar(
            "Debug", "Latitude or Longitude is missing for ID: $deliveryBoyId");
        return null;
      }

      _showSnackbar("Success", "Location fetched: ($latitude, $longitude)");
      return {'latitude': latitude, 'longitude': longitude};
    } catch (e) {
      _showSnackbar("Error", "Failed to fetch location: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getRouteAndETA(double originLat,
      double originLng, double destLat, double destLng) async {
    const String apiKey =
        'AIzaSyDfXX54MU-OKbx0UGTtzfwkXamvrcDz0m4'; // Replace with your actual API key
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$originLat,$originLng&destination=$destLat,$destLng&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data['status'] != 'OK') {
        _showSnackbar("Error", "Failed to fetch directions: ${data['status']}");
        return null;
      }

      return {
        'eta': data['routes'][0]['legs'][0]['duration']['text'],
        'polyline': data['routes'][0]['overview_polyline']['points'],
      };
    } catch (e) {
      return null;
    }
  }

  Future<Position> _getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void _showSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.black,
      duration: const Duration(seconds: 3),
    );
  }

  void _navigateToMap(
      BuildContext context,
      double orderLat,
      double orderLng,
      double deliveryBoyLat,
      double deliveryBoyLng,
      String eta,
      String polyline) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderTrackingMap(
          orderLat: orderLat,
          orderLng: orderLng,
          deliveryBoyLat: deliveryBoyLat,
          deliveryBoyLng: deliveryBoyLng,
          polylinePoints: polyline,
          eta: eta,
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

void _showLoadingDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing the dialog
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      );
    },
  );
}
