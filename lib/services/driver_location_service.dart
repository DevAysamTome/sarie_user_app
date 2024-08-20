import 'package:cloud_firestore/cloud_firestore.dart';

class DriverLocationService {
  final CollectionReference ordersCollection =
      FirebaseFirestore.instance.collection('orders');

  void updateDriverLocation(String orderId, GeoPoint newLocation) {
    ordersCollection.doc(orderId).update({
      'location': newLocation,
    }).then((_) {
      print("Driver location updated for order $orderId");
    }).catchError((error) {
      print("Failed to update driver location: $error");
    });
  }
}
