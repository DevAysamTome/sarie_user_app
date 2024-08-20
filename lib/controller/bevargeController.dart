// lib/controller/beverageStoreController.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BeverageStoreController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BeverageStoreController();

  Future<List<Map<String, dynamic>>> fetchBeverageStores() async {
    QuerySnapshot querySnapshot =
        await _firestore.collection('beverageStores').get();
    return querySnapshot.docs
        .map((doc) => {'id': doc.id, 'data': doc.data()})
        .toList();
  }

  Future<Map<String, dynamic>> fetchBeverageStoreDetails(
      String storeId) async {
    DocumentSnapshot docSnapshot =
        await _firestore.collection('beverageStores').doc(storeId).get();
    return {'id': docSnapshot.id, 'data': docSnapshot.data()};
  }

  Future<List<Map<String, dynamic>>> fetchItems(String storeId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('beverageStores')
        .doc(storeId)
        .collection('meals')
        .get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
