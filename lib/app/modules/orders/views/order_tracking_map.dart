import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderTrackingMap extends StatefulWidget {
  final double orderLat;
  final double orderLng;
  final double deliveryBoyLat;
  final double deliveryBoyLng;
  final String eta;
  final String polylinePoints;

  const OrderTrackingMap({
    Key? key,
    required this.orderLat,
    required this.orderLng,
    required this.deliveryBoyLat,
    required this.deliveryBoyLng,
    required this.eta,
    required this.polylinePoints,
  }) : super(key: key);

  @override
  State<OrderTrackingMap> createState() => _OrderTrackingMapState();
}

class _OrderTrackingMapState extends State<OrderTrackingMap> {
  late GoogleMapController mapController;
  Set<Polyline> polylines = {};
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _setMarkers();
    _setPolylines();
  }

  void _setMarkers() {
    markers.add(
      Marker(
        markerId: const MarkerId('deliveryBoy'),
        position: LatLng(widget.deliveryBoyLat, widget.deliveryBoyLng),
        infoWindow: const InfoWindow(title: 'Delivery Boy'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    markers.add(
      Marker(
        markerId: const MarkerId('orderLocation'),
        position: LatLng(widget.orderLat, widget.orderLng),
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
  }

  void _setPolylines() {
    polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.blue,
        width: 5,
        points: _decodePolyline(widget.polylinePoints),
      ),
    );
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.deliveryBoyLat, widget.deliveryBoyLng),
          zoom: 13,
        ),
        markers: markers,
        polylines: polylines,
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Estimated Arrival:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              widget.eta,
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
