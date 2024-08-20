import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  final String restaurantName;
  final DateTime orderDate;
  final List<Map<String, dynamic>> itemsList;

  const OrderTrackingScreen({super.key, 
    required this.orderId,
    required this.restaurantName,
    required this.orderDate,
    required this.itemsList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.7749, -122.4194), // استبدلها بالإحداثيات الفعلية
              zoom: 14.0,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('restaurant'),
                position: const LatLng(37.7749, -122.4194), // استبدلها بالإحداثيات الفعلية
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
              ),
              Marker(
                markerId: const MarkerId('delivery'),
                position: const LatLng(37.7849, -122.4094), // استبدلها بالإحداثيات الفعلية
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              ),
            },
            polylines: {
              const Polyline(
                polylineId: PolylineId('route'),
                points: [
                  LatLng(37.7749, -122.4194), // استبدلها بالإحداثيات الفعلية
                  LatLng(37.7849, -122.4094), // استبدلها بالإحداثيات الفعلية
                ],
                color: Colors.orange,
                width: 5,
              ),
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurantName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ordered At ${orderDate.toString()}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...itemsList.map((item) {
                      return Text('${item['quantity']}x ${item['mealName']}');
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
