import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/res/components/bevargeCard.dart';
import 'package:user_app/views/home/drink_view/drink_details.dart';

class BeverageStoresScreen extends StatefulWidget {
  const BeverageStoresScreen({super.key});

  @override
  _BeverageStoresScreenState createState() => _BeverageStoresScreenState();
}

class _BeverageStoresScreenState extends State<BeverageStoresScreen> {
  late Future<List<Map<String, dynamic>>> beverageStoresFuture;
  List<String> categories = [];
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    beverageStoresFuture = fetchBeverageStoresData();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('beverageStores').get();

    Set<String> categorySet = {};
    for (var doc in querySnapshot.docs) {
      List<String> storeCategories = List<String>.from(doc['categories'] ?? []);
      categorySet.addAll(storeCategories);
    }

    setState(() {
      categories = ['All', ...categorySet];
    });
  }

  Future<List<Map<String, dynamic>>> fetchBeverageStoresData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('beverageStores').get();
    return Future.wait(querySnapshot.docs.map((doc) async {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      // Check if sub-collection 'meals' exists
      QuerySnapshot itemsSnapshot =
          await doc.reference.collection('meals').get();
      if (itemsSnapshot.docs.isNotEmpty) {
        data['meals'] = itemsSnapshot.docs.map((doc) => doc.data()).toList();
      }
      return data;
    }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: const Text(
            'محلات المشروبات',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // ListView for categories as horizontal carousel
            Container(
              height: 50, // Set height for ListView
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(categories[index]),
                      selected: selectedCategory == categories[index],
                      onSelected: (bool selected) {
                        setState(() {
                          selectedCategory =
                              selected ? categories[index] : 'All';
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: beverageStoresFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final beverageStores = snapshot.data ?? [];
                  final filteredBeverageStores =
                      beverageStores.where((beverageStore) {
                    List<String> storeCategories =
                        List<String>.from(beverageStore['categories'] ?? []);
                    bool matchesCategory = selectedCategory == 'All' ||
                        storeCategories.contains(selectedCategory);

                    return matchesCategory;
                  }).toList();
                  return ListView.builder(
                    itemCount: filteredBeverageStores.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map<String, dynamic> beverageStore =
                          filteredBeverageStores[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BeverageStoreDetailsScreen(
                                beverageStore: beverageStore,
                              ),
                            ),
                          );
                        },
                        child: BeverageStoreCard(
                          imageUrl: beverageStore['imageUrl'] ?? '',
                          title: beverageStore['name'] ?? 'اسم غير متوفر',
                          categories: List<String>.from(
                              beverageStore['categories'] ?? []),
                          items: List<Map<String, dynamic>>.from(
                              beverageStore['meals'] ?? []),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
