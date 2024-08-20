import 'package:flutter/material.dart';
import 'package:user_app/views/order_tracking_screen/order_tracking_view.dart';

class OrderTrackingService {
  void trackOrder(BuildContext context, String orderId, String restaurantName, DateTime orderDate, List<Map<String, dynamic>> itemsList) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderTrackingScreen(
          orderId: orderId,
          restaurantName: restaurantName,
          orderDate: orderDate,
          itemsList: itemsList,
        ),
      ),
    );
  }
}
