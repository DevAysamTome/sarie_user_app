import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/views/home/drink_view/drink_details.dart';
import 'package:user_app/views/home/resturent_view/resturent_details.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  void _performSearch(String query) async {
    setState(() {
      _isSearching = true;
    });

    List<Map<String, dynamic>> results = [];

    // Perform search in restaurants collection
    QuerySnapshot restaurantSnapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .where('name', isGreaterThanOrEqualTo: query)
        .get();

    results.addAll(restaurantSnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['collection'] = 'restaurants';
      data['id'] = doc.id;
      return data;
    }).toList());

    // Perform search in pharmacies collection
    QuerySnapshot pharmacySnapshot = await FirebaseFirestore.instance
        .collection('pharmacies')
        .where('name', isGreaterThanOrEqualTo: query)
        .get();

    results.addAll(pharmacySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['collection'] = 'pharmacies';
      data['id'] = doc.id;
      return data;
    }).toList());

    // Perform search in beverage stores collection
    QuerySnapshot beverageStoreSnapshot = await FirebaseFirestore.instance
        .collection('beverageStores')
        .where('name', isGreaterThanOrEqualTo: query)
        .get();

    results.addAll(beverageStoreSnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['collection'] = 'beverageStores';
      data['id'] = doc.id;
      return data;
    }).toList());

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _navigateToDetails(Map<String, dynamic> item) async {
    String collection = item['collection'];
    String id = item['id'];

    // Fetch sub-collection data
    List<Map<String, dynamic>> subCollectionData = [];
    if (collection == 'restaurants' || collection == 'beverageStores') {
      QuerySnapshot subCollectionSnapshot = await FirebaseFirestore.instance
          .collection(collection)
          .doc(id)
          .collection('meals')
          .get();
      subCollectionData = subCollectionSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    }

    item['meals'] = subCollectionData;

    if (collection == 'restaurants') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RestaurantDetailsScreen(
            restaurant: item,
          ),
        ),
      );
    
    } else if (collection == 'beverageStores') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BeverageStoreDetailsScreen(
            beverageStore: item,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ابحث عن الأطباق والمطاعم',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onChanged: (value) {
              _performSearch(value);
            },
          ),
        ),
        _isSearching
            ? const Center(child: CircularProgressIndicator())
            : _searchResults.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      spacing: 8.0,
                      children: _searchResults.map((item) {
                        return ChoiceChip(
                          label: Text(item['name']),
                          selected: false,
                          onSelected: (selected) {
                            _navigateToDetails(item);
                          },
                        );
                      }).toList(),
                    ),
                  )
                : const Center(child: null),
      ],
    );
  }
}
