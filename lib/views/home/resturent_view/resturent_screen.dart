import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:user_app/res/components/resturentCard.dart';
import 'package:user_app/views/home/resturent_view/resturent_details.dart';

class RestaurantsScreen extends StatefulWidget {
  const RestaurantsScreen({super.key});

  @override
  _RestaurantsScreenState createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  late Future<List<Map<String, dynamic>>> restaurantsFuture;
  List<String> categories = [];
  String selectedCategory = 'All';
  bool isWithinJenineRange = false;

  @override
  void initState() {
    super.initState();
    checkLocation();
  }

  Future<void> checkLocation() async {
    try {
      Position position = await _determinePosition();
      const double jenineLat = 32.4630;
      const double jenineLng = 35.2930;
      const double radius = 1000.0;

      double distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            jenineLat,
            jenineLng,
          ) /
          1000;

      if (mounted) {
        setState(() {
          isWithinJenineRange = distance <= radius;
          if (isWithinJenineRange) {
            restaurantsFuture = fetchRestaurantsData();
            fetchCategories();
          }
        });
      }
    } catch (e) {
      // Handle errors, e.g., location services disabled
      print('Error checking location: $e');
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> fetchCategories() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('restaurants').get();

      Set<String> categorySet = {};
      for (var doc in querySnapshot.docs) {
        List<String> restaurantCategories =
            List<String>.from(doc['categories'] ?? []);
        categorySet.addAll(restaurantCategories);
      }

      if (mounted) {
        setState(() {
          categories = ['All', ...categorySet];
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchRestaurantsData() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('restaurants').get();
      return Future.wait(querySnapshot.docs.map((doc) async {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        QuerySnapshot mealsSnapshot =
            await doc.reference.collection('meals').get();
        if (mealsSnapshot.docs.isNotEmpty) {
          data['meals'] = mealsSnapshot.docs.map((doc) => doc.data()).toList();
        }
        return data;
      }).toList());
    } catch (e) {
      print('Error fetching restaurants data: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: const Text(
            'المطاعم',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: isWithinJenineRange
            ? Column(
                children: [
                  Container(
                    height: 50,
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
                      future: restaurantsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        final restaurants = snapshot.data ?? [];
                        final filteredRestaurants = selectedCategory == 'All'
                            ? restaurants
                            : restaurants.where((restaurant) {
                                List<String> restaurantCategories =
                                    List<String>.from(
                                        restaurant['categories'] ?? []);
                                return restaurantCategories
                                    .contains(selectedCategory);
                              }).toList();
                        return ListView.builder(
                          itemCount: filteredRestaurants.length,
                          itemBuilder: (BuildContext context, int index) {
                            Map<String, dynamic> restaurant =
                                filteredRestaurants[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RestaurantDetailsScreen(
                                      restaurant: restaurant,
                                    ),
                                  ),
                                );
                              },
                              child: RestaurantCard(
                                imageUrl: restaurant['imageUrl'] ?? '',
                                title: restaurant['name'] ?? 'اسم غير متوفر',
                                address: restaurant['address'] ?? 'غير متوفر',
                                categories: List<String>.from(
                                    restaurant['categories'] ?? []),
                                meals: List<Map<String, dynamic>>.from(
                                    restaurant['meals'] ?? []),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              )
            : Center(
                child: Text('هذه الخدمة متاحة فقط داخل نطاق مدينة جنين.'),
              ),
      ),
    );
  }
}
