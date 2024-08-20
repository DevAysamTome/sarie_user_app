import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/services/location_tracking_service.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String orderId;
  final String restaurantName;
  final DateTime orderDate;
  final List<Map<String, dynamic>> itemsList;

  const LiveTrackingScreen({super.key, 
    required this.orderId,
    required this.restaurantName,
    required this.orderDate,
    required this.itemsList,
  });

  @override
  _LiveTrackingScreenState createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  late GoogleMapController _mapController;
  late LocationTrackingService _locationTrackingService;
  late Stream<DocumentSnapshot> _locationStream;
  late Marker _deliveryMarker;

  @override
  void initState() {
    super.initState();
    _locationTrackingService = LocationTrackingService();
    _locationStream = _locationTrackingService.getOrderLocation(widget.orderId);
    _deliveryMarker = Marker(
      markerId: const MarkerId('delivery'),
      position: const LatLng(0, 0), // سيتم تحديث هذه الإحداثيات لاحقًا
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _updateMarker(GeoPoint position) {
    setState(() {
      _deliveryMarker = Marker(
        markerId: const MarkerId('delivery'),
        position: LatLng(position.latitude, position.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
      _mapController.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
    });
  }

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
          StreamBuilder<DocumentSnapshot>(
            stream: _locationStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                final GeoPoint position = data['location'];
                _updateMarker(position);
              }
              return GoogleMap(
                onMapCreated: _onMapCreated,                initialCameraPosition: const CameraPosition(
                  target: LatLng(37.7749, -122.4194), // موقع افتراضي
                  zoom: 14.0,
                ),
                markers: {_deliveryMarker},
              );
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
                      widget.restaurantName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ordered At ${widget.orderDate.toString()}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.itemsList.map((item) {
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
