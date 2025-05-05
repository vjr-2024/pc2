import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../controllers/orders_controller.dart';
import 'package:grocery_app/app/modules/orders/views/order_tracking_map.dart';

class SupplierOrdersView extends GetView<OrdersController> {
  SupplierOrdersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();
    controller.refreshOrders();

    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text(
          'Supplier Orders',
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
                : DateTime.now();

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
                          const Divider(),
                          // Show Delivery Boy details if status is 'Shipped', 'Out for Delivery', or 'Delivered'
                          if (['Shipped', 'Out for Delivery', 'Delivered']
                                  .contains(order['status']) &&
                              deliveryBoyId.isNotEmpty)
                            FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(deliveryBoyId)
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }

                                if (!snapshot.hasData ||
                                    !snapshot.data!.exists) {
                                  return const SizedBox.shrink();
                                }

                                final deliveryBoyData = snapshot.data!;
                                final deliveryBoyName =
                                    deliveryBoyData['username'] ?? 'Unknown';
                                final deliveryBoyPhone =
                                    deliveryBoyData['phoneNumber'] ?? 'N/A';

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      'Delivery Boy: $deliveryBoyName',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Phone: $deliveryBoyPhone',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                        ]),
                    const Divider(),
                    if (order['status'] == 'Pending')
                      ElevatedButton(
                        onPressed: () async {
                          // Action to assign a delivery boy
                          _assignDeliveryBoyAndShip(context, documentId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Assign Delivery Boy'),
                      ),
                    if (order['status'] == 'Out for Delivery')
                      ElevatedButton(
                        onPressed: () async {
                          if (deliveryBoyId.isEmpty) {
                            _showSnackbar("Error", "No delivery boy assigned.");
                            return;
                          }

                          try {
                            // Request location permission first
                            bool hasPermission =
                                await _handleLocationPermission();
                            if (!hasPermission) return;

                            final deliveryBoyLocation =
                                await _fetchDeliveryBoyLocation(deliveryBoyId);

                            if (deliveryBoyLocation == null) {
                              _showSnackbar("Error",
                                  "Delivery boy location not available $deliveryBoyId.");
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
                              _showSnackbar(
                                  "Error", "Failed to fetch directions.");
                              return;
                            }

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
                            _showSnackbar("Error", "An error occurred: $e");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.blueAccent, // Button background color
                          foregroundColor:
                              Colors.black, // Text color changed to black
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
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(deliveryBoyId)
          .get();

      final data = snapshot.data();

      if (data == null) {
        return null;
      }

      // Ensure latitude and longitude are retrieved as doubles
      final latitude = data['latitude']?.toDouble();
      final longitude = data['longitude']?.toDouble();

      if (latitude == null || longitude == null) {
        return null;
      }

      return {'latitude': latitude, 'longitude': longitude};
    } catch (e) {
      _showSnackbar("Error", "Failed to fetch delivery boy location: $e");
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

  // Handle the assignment of a delivery boy
  void _assignDeliveryBoyAndShip(BuildContext context, String documentId) {
    showDialog(
      context: context,
      builder: (context) {
        String selectedDeliveryBoy = '';

        return StatefulBuilder(
          // Use StatefulBuilder to manage local state
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Assign Delivery Boy'),
              content: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'deliveryBoy') // Filter by role
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('No delivery boys available.');
                  }

                  return DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Select Delivery Boy'),
                    items: snapshot.data!.docs.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc.id,
                        child: Text(doc['username'] ??
                            doc['phoneNumber'] ??
                            'Unknown'), // Use phoneNumber if name is missing
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDeliveryBoy = value!;
                      });
                    },
                    value: selectedDeliveryBoy.isNotEmpty
                        ? selectedDeliveryBoy
                        : null,
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedDeliveryBoy.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('orders')
                          .doc(documentId)
                          .update({
                        'status': 'Shipped',
                        'deliveryBoyId': selectedDeliveryBoy,
                      });
                      Get.snackbar("Success", "Order marked as Shipped.",
                          snackPosition: SnackPosition.BOTTOM);
                      Navigator.pop(context);
                    } else {
                      Get.snackbar("Error", "Please select a delivery boy.",
                          snackPosition: SnackPosition.BOTTOM);
                    }
                  },
                  child: const Text('Assign & Ship'),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Show a dialog to select a delivery boy (mocked method)
}
