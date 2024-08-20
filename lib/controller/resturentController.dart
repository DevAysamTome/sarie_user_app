// lib/controller/restaurantController.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantController {
  RestaurantController(someArgument);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchRestaurants() async {
    QuerySnapshot querySnapshot =
        await _firestore.collection('restaurants').get();
    return querySnapshot.docs
        .map((doc) => {'id': doc.id, 'data': doc.data()})
        .toList();
  }

  Future<Map<String, dynamic>> fetchRestaurantDetails(
      String restaurantId) async {
    DocumentSnapshot docSnapshot =
        await _firestore.collection('restaurants').doc(restaurantId).get();
    return {'id': docSnapshot.id, 'data': docSnapshot.data()};
  }

  Future<List<Map<String, dynamic>>> fetchMeals(String restaurantId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('meals')
        .get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
