import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:user_app/views/order_tracking_screen/constants.dart';

class OrderTrackingPage extends StatefulWidget {
  final LatLng orderLocation; // موقع الطلب
  final LatLng restaurantLocation; // موقع المطعم
  final String deliveryWorkerId; // معرف عامل التوصيل

  const OrderTrackingPage({
    super.key,
    required this.orderLocation,
    required this.restaurantLocation,
    required this.deliveryWorkerId,
  });

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();
  List<LatLng> polylineCoordinates = [];
  LatLng? deliveryWorkerLocation;
  String? deliveryWorkerName;

  @override
  void initState() {
    super.initState();
    getDeliveryWorkerLocation();
    getPolyPoints();
  }

  // جلب إحداثيات ومعلومات عامل التوصيل من Firestore
  void getDeliveryWorkerLocation() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> deliveryWorkerSnapshot =
          await FirebaseFirestore.instance
              .collection('deliveryWorkers')
              .doc(widget.deliveryWorkerId)
              .get();

      if (deliveryWorkerSnapshot.exists) {
        final data = deliveryWorkerSnapshot.data();
        if (data != null) {
          setState(() {
            deliveryWorkerLocation =
                LatLng(data['latitude'], data['longitude']);
            deliveryWorkerName = data['fullName'];
          });
        }
      }
    } catch (e) {
      print('Error fetching delivery worker location: $e');
    }
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: google_api_key,
        request: PolylineRequest(
          origin: PointLatLng(
            widget.restaurantLocation.latitude,
            widget.restaurantLocation.longitude,
          ),
          destination: PointLatLng(
            widget.orderLocation.latitude,
            widget.orderLocation.longitude,
          ),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        if (mounted) {
          setState(() {
            polylineCoordinates.clear(); // Clear existing coordinates
            for (var point in result.points) {
              polylineCoordinates.add(LatLng(point.latitude, point.longitude));
            }
          });
        }
      } else {
        print('No route found');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No route found')),
          );
        }
      }
    } catch (e) {
      print('Error getting route: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting route: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track order",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: deliveryWorkerLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: deliveryWorkerLocation!,
                zoom: 13.5,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              polylines: {
                Polyline(
                  polylineId: const PolylineId("route"),
                  color: primaryColor,
                  width: 6,
                  points: polylineCoordinates,
                ),
              },
              markers: {
                Marker(
                  markerId: const MarkerId("orderLocation"),
                  position: LatLng(widget.orderLocation.latitude,
                      widget.orderLocation.longitude),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueCyan),
                ),
                Marker(
                  markerId: const MarkerId("restaurantLocation"),
                  position: LatLng(widget.restaurantLocation.latitude,
                      widget.restaurantLocation.longitude),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen),
                ),
                if (deliveryWorkerLocation != null)
                  Marker(
                    markerId: const MarkerId("deliveryWorkerLocation"),
                    position: deliveryWorkerLocation!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueOrange),
                    infoWindow: InfoWindow(
                      title: "عامل التوصيل",
                      snippet: deliveryWorkerName,
                    ),
                  ),
              },
            ),
    );
  }
}
