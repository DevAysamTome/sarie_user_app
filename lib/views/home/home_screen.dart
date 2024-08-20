import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:user_app/models/cartProvider.dart';
import 'package:user_app/res/components/buildCategoryCard.dart';
import 'package:user_app/res/components/buildDetailsStoreCategory.dart';
import 'package:user_app/res/components/carouselOffer.dart';
import 'package:user_app/res/components/menu_drawer.dart';
import 'package:user_app/res/components/popDialogName.dart';
import 'package:user_app/views/home/drink_view/drink_details.dart';
import 'package:user_app/views/home/drink_view/drink_screen.dart';
import 'package:user_app/views/home/hospital_view/pharmasy_details_view.dart';
import 'package:user_app/views/home/hospital_view/pharmasy_screen.dart';
import 'package:user_app/views/home/resturent_view/resturent_details.dart';
import 'package:user_app/views/home/resturent_view/resturent_screen.dart';
import 'package:user_app/views/home/search_view/search_view.dart';
import 'package:user_app/views/home/shopping/shopping_cart.dart';
import 'package:user_app/views/home/sweet_view/sweet_store_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<List<Map<String, dynamic>>> restaurantsFuture;
  late Future<List<Map<String, dynamic>>> pharmaciesFuture;
  late Future<List<Map<String, dynamic>>> beverageStoresFuture;

  @override
  void initState() {
    super.initState();
    // checkLocationAndFetchData();
    restaurantsFuture = fetchCollectionData('restaurants');
    pharmaciesFuture = fetchCollectionData('pharmacies');
    beverageStoresFuture = fetchCollectionData('beverageStores');
  }

  // void checkLocationAndFetchData() async {
  //   bool isInJenin = await isUserInJeninArea();
  //   if (isInJenin) {
  //     restaurantsFuture = fetchCollectionData('restaurants');
  //     pharmaciesFuture = fetchCollectionData('pharmacies');
  //     beverageStoresFuture = fetchCollectionData('beverageStores');
  //   } else {
  //     setState(() {
  //       restaurantsFuture = Future.value([]);
  //       pharmaciesFuture = Future.value([]);
  //       beverageStoresFuture = Future.value([]);
  //     });
  //   }
  // }

  // void _showWelcomeDialog() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) return;

  //   // Fetch user document from Firestore
  //   DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(user.uid)
  //       .get();

  //   if (userDoc.exists) {
  //     final userData = userDoc.data() as Map<String, dynamic>;
  //     final userName = userData['fullName'] as String?;

  //     // Show dialog only if the user has no name
  //     if (userName == null || userName.isEmpty) {
  //       showDialog(
  //         context: context,
  //         builder: (context) => NameInputDialog(user: user),
  //       );
  //     }
  //   }
  // }

  Future<bool> isUserInJeninArea() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // تحديد حدود نطاق جنين وقراها
    double minLatitude = 32.4316;
    double maxLatitude = 32.44459440814351;
    double minLongitude = 35.08425716349074;
    double maxLongitude = 35.2644;

    if (position.latitude >= minLatitude &&
        position.latitude <= maxLatitude &&
        position.longitude >= minLongitude &&
        position.longitude <= maxLongitude) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchCollectionData(
      String collectionName) async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection(collectionName).get();

    List<Map<String, dynamic>> dataList = [];

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Fetch sub-collection 'meals' for each document
      QuerySnapshot mealsSnapshot =
          await doc.reference.collection('meals').get();

      List<Map<String, dynamic>>? mealsList = [];
      if (mealsSnapshot.docs.isNotEmpty) {
        mealsList = mealsSnapshot.docs
            .map((mealDoc) => mealDoc.data())
            .cast<Map<String, dynamic>>()
            .toList();
      }

      // Add meals list to the data map
      data['meals'] = mealsList;

      // Add the combined data to the dataList
      dataList.add(data);
    }

    return dataList;
  }

  String getGreetingText() {
    var now = DateTime.now();
    var hour = now.hour;
    var greetingText = '';

    if (hour < 12) {
      greetingText = 'صباحك عربي بالصلاة عالنبي، شو حابب تفطر اليوم؟';
    } else if (hour >= 12 && hour < 17) {
      greetingText = 'شو حابب تتغدا معنا اليوم؟';
    } else {
      greetingText = 'شو حابب تتعشى معنا اليوم؟';
    }

    return greetingText;
  }

  @override
  Widget build(BuildContext context) {
    var cartProvider = Provider.of<CartProvider>(context);
    var greetingText = getGreetingText();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            widget.title,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.menu, size: 40, color: Colors.white),
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer();
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag,
                        size: 40, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CartScreen()),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 30,
                    left: 2,
                    child: CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 10,
                      child: Center(
                        child: Text(
                          '${cartProvider.cartItemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        drawer: AppDrawer(),
        body: FutureBuilder<bool>(
          future: isUserInJeninArea(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData && !snapshot.data!) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "ستتوفر قريباً في منطقتك",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      width: double.infinity,
                      height: 130,
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 5,
                              offset: Offset(0.1, 0.1),
                            )
                          ],
                          image: const DecorationImage(
                              image: AssetImage("assets/icons/logo_f.png"),
                              fit: BoxFit.cover,
                              alignment: Alignment.center)),
                    ),
                  ],
                ),
              );
            } else {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      width: double.infinity,
                      height: 130,
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 5,
                              offset: Offset(0.1, 0.1),
                            )
                          ],
                          image: const DecorationImage(
                              image: AssetImage("assets/icons/logo_f.png"),
                              fit: BoxFit.cover,
                              alignment: Alignment.center)),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        greetingText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),

                    const SearchWidget(),
                    const SizedBox(
                      height: 10,
                    ),
                    OffersCarousel(),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            CategoryCard(
                              icon: "assets/icons/burger.png",
                              title: "المطاعم",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RestaurantsScreen()),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            CategoryCard(
                              icon: "assets/icons/drink-logo.png",
                              title: "المشروبات",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const BeverageStoresScreen()),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            CategoryCard(
                              icon: "assets/icons/sweet.png",
                              title: "الحلويات",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SweetStoreScreen()),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            CategoryCard(
                              icon: "assets/icons/pharmacy.png",
                              title: "العناية بالبشرة",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PharmacyScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    CategoryCards(
                      title: ' المطاعم المتاحة حاليا',
                      futureData: restaurantsFuture,
                      onTap: (restaurant) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RestaurantDetailsScreen(
                              restaurant: restaurant,
                            ),
                          ),
                        );
                      },
                    ),
                    CategoryCards(
                      title: 'محلات العناية بالبشرة المتاحة حاليا',
                      futureData: pharmaciesFuture,
                      onTap: (pharmacy) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PharmasyDetailsScreen(
                              pharmacy: pharmacy,
                            ),
                          ),
                        );
                      },
                    ),
                    CategoryCards(
                      title: 'محلات المشروبات المتاحة حاليا',
                      futureData: beverageStoresFuture,
                      onTap: (beverageStore) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BeverageStoreDetailsScreen(
                              beverageStore: beverageStore,
                            ),
                          ),
                        );
                      },
                    ), // CategoryCards widgets and other content
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
