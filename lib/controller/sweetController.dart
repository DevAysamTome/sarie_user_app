// lib/controller/beverageStoreController.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SweetStoreController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SweetStoreController();

  Future<List<Map<String, dynamic>>> fetchsweetStores() async {
    QuerySnapshot querySnapshot =
        await _firestore.collection('sweetStore').get();
    return querySnapshot.docs
        .map((doc) => {'id': doc.id, 'data': doc.data()})
        .toList();
  }

  Future<Map<String, dynamic>> fetchSweetStoreDetails(
      String storeId) async {
    DocumentSnapshot docSnapshot =
        await _firestore.collection('sweetStore').doc(storeId).get();
    return {'id': docSnapshot.id, 'data': docSnapshot.data()};
  }

  Future<List<Map<String, dynamic>>> fetchItems(String storeId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('sweetStore')
        .doc(storeId)
        .collection('meals')
        .get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
