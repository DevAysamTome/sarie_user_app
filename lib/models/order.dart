import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_app/models/cartItem.dart';

class Order {
  final String storeId;
  final DateTime orderEndTime;
  List<CartItem> items;
  String orderId;

  Order({
    required this.storeId,
    required this.items,
    required this.orderId,
  }) : orderEndTime = DateTime.now().add(const Duration(minutes: 10)); // Initialize here

  void addItem(CartItem item) {
    items.add(item);
  }

  void removeItem(int index) {
    items.removeAt(index);
  }

  double get totalPrice {
    double total = 0;
    for (var item in items) {
      total += item.meal.price * item.quantity;
    }
    return total;
  }

  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalPrice': totalPrice,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'orderStatus': 'قيد التنفيذ',
      'orderId': orderId,
      'orderEndTime': orderEndTime, // Add orderEndTime to the map
    };
  }

  static Future<Order> createOrder({
    required String storeId,
    required List<CartItem> items,
  }) async {
    // الحصول على الرقم المتزايد للطلب
    final orderRef = FirebaseFirestore.instance.collection('orders').doc();
    final orderId = orderRef.id;

    final order = Order(
      storeId: storeId,
      items: items,
      orderId: orderId,
    );

    // حفظ الطلب في Firestore
    await orderRef.set(order.toMap());

    return order;
  }
}
