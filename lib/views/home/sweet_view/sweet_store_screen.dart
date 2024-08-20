import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/res/components/bevargeCard.dart';
import 'package:user_app/views/home/sweet_view/sweet_details.dart';

class SweetStoreScreen extends StatefulWidget {
  const SweetStoreScreen({super.key});

  @override
  _SweetStoreScreenState createState() => _SweetStoreScreenState();
}

class _SweetStoreScreenState extends State<SweetStoreScreen> {
  late Future<List<Map<String, dynamic>>> sweetStoresFuture;
  List<String> categories = [];
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    sweetStoresFuture = fetchSweetStoresData();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('sweetStore').get();

    Set<String> categorySet = {};
    for (var doc in querySnapshot.docs) {
      List<String> storeCategories = List<String>.from(doc['categories'] ?? []);
      categorySet.addAll(storeCategories);
    }

    setState(() {
      categories = ['All', ...categorySet];
    });
  }

  Future<List<Map<String, dynamic>>> fetchSweetStoresData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('sweetStore').get();
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
          centerTitle: true,
          title: const Text(
            'محلات الحلويات',
            style: TextStyle(color: Colors.white),
          ),
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
                future: sweetStoresFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final sweetStores = snapshot.data ?? [];
                  final filteredsweetStores = sweetStores.where((sweetStore) {
                    List<String> storeCategories =
                        List<String>.from(sweetStore['categories'] ?? []);
                    bool matchesCategory = selectedCategory == 'All' ||
                        storeCategories.contains(selectedCategory);

                    return matchesCategory;
                  }).toList();
                  return ListView.builder(
                    itemCount: filteredsweetStores.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map<String, dynamic> sweetStore =
                          filteredsweetStores[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SweetDetailsScreen(
                                sweetStore: sweetStore,
                              ),
                            ),
                          );
                        },
                        child: BeverageStoreCard(
                          imageUrl: sweetStore['imageUrl'] ?? '',
                          title: sweetStore['name'] ?? 'اسم غير متوفر',
                          categories:
                              List<String>.from(sweetStore['categories'] ?? []),
                          items: List<Map<String, dynamic>>.from(
                              sweetStore['meals'] ?? []),
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
