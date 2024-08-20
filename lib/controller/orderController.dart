import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference ordersCollection =
      FirebaseFirestore.instance.collection('orders');

  Stream<QuerySnapshot> getOngoingOrders(String userId) {
    return ordersCollection
        .where('orderStatus', isEqualTo: 'قيد الانتظار')
        .where('userId', isEqualTo: userId) // استخدام معرف المستخدم لتصفية الطلبات
        .snapshots();
  }

  Stream<QuerySnapshot> getOrderHistory(String userId) {
    return ordersCollection
        .where('orderStatus', isEqualTo: 'ملغي')
        .where('userId', isEqualTo: userId) // استخدام معرف المستخدم لتصفية الطلبات
        .snapshots();
  }
}
