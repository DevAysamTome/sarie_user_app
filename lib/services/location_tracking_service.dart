import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:user_app/views/order_tracking_screen/live_tracking_view.dart';

class LocationTrackingService {
  void trackOrder(BuildContext context, String orderId, String restaurantName, DateTime orderDate, List<Map<String, dynamic>> itemsList) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiveTrackingScreen(
          orderId: orderId,
          restaurantName: restaurantName,
          orderDate: orderDate,
          itemsList: itemsList,
        ),
      ),
    );
  }

  Stream<DocumentSnapshot> getOrderLocation(String orderId) {
    return FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots();
  }
}
