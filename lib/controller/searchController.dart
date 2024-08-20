import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<String>> fetchSuggestions(String query) async {
  List<String> suggestions = [];

  if (query.isNotEmpty) {
    // البحث في مجموعة المطاعم
    QuerySnapshot restaurantSnapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .where('name', isGreaterThanOrEqualTo: query)
        .limit(5) // قم بتحديد عدد الاقتراحات التي ترغب في عرضها
        .get();

    for (var doc in restaurantSnapshot.docs) {
      suggestions.add(doc['name']);
    }

    // البحث في مجموعة الوجبات
    QuerySnapshot mealSnapshot = await FirebaseFirestore.instance
        .collectionGroup('meals')
        .where('mealName', isGreaterThanOrEqualTo: query)
        .limit(5)
        .get();

    for (var doc in mealSnapshot.docs) {
      suggestions.add(doc['mealName']);
    }

    // البحث في مجموعة الصيدليات
    QuerySnapshot pharmacySnapshot = await FirebaseFirestore.instance
        .collection('pharmacies')
        .where('name', isGreaterThanOrEqualTo: query)
        .limit(5)
        .get();

    for (var doc in pharmacySnapshot.docs) {
      suggestions.add(doc['name']);
    }

    // البحث في مجموعة محلات المشروبات
    QuerySnapshot beverageStoreSnapshot = await FirebaseFirestore.instance
        .collection('beverageStores')
        .where('name', isGreaterThanOrEqualTo: query)
        .limit(5)
        .get();

    for (var doc in beverageStoreSnapshot.docs) {
      suggestions.add(doc['name']);
    }
  }

  return suggestions;
}
