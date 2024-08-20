// lib/controller/beverageStoreController.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PharmasyController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PharmasyController();

  Future<List<Map<String, dynamic>>> fetchPharmasyStores() async {
    QuerySnapshot querySnapshot =
        await _firestore.collection('pharmacies').get();
    return querySnapshot.docs
        .map((doc) => {'id': doc.id, 'data': doc.data()})
        .toList();
  }

  Future<Map<String, dynamic>> fetchPharmasyDetails(String storeId) async {
    DocumentSnapshot docSnapshot =
        await _firestore.collection('pharmacies').doc(storeId).get();
    return {'id': docSnapshot.id, 'data': docSnapshot.data()};
  }
}
