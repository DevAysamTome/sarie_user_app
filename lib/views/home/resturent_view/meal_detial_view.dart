import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/models/cartItem.dart';
import 'package:user_app/models/cartProvider.dart';
import 'package:user_app/models/meal.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MealDetailsScreen extends StatefulWidget {
  final Meal meal;
  final Map<String, dynamic> restaurant;

  const MealDetailsScreen(
      {super.key, required this.meal, required this.restaurant});

  @override
  _MealDetailsScreenState createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen> {
  List<String> selectedAddOns = [];
  int quantity = 1;
  double _totalPrice = 0.0;
  LatLng? userLocation;

  @override
  void initState() {
    super.initState();
    _totalPrice = widget.meal.price;
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    final userId = FirebaseAuth
        .instance.currentUser!.uid; // قم بتغيير هذا إلى ID المستخدم الفعلي
    final addressDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .doc();

    final addressSnapshot = await addressDoc.get();

    if (addressSnapshot.exists) {
      setState(() {
        userLocation = LatLng(
          addressSnapshot['location'][0],
          addressSnapshot['location'][1],
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.redAccent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'التفاصيل',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal Image
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.meal.imageUrl,
                        fit: BoxFit.cover,
                        width: 300,
                        height: 200,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Restaurant Name
                Center(
                  child: Chip(
                    avatar: const CircleAvatar(
                      backgroundImage: AssetImage("assets/icons/heart.png"),
                    ),
                    label: Text(
                      widget.restaurant['name'] ?? 'اسم المطعم',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Meal Name
                Center(
                  child: Text(
                    widget.meal.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Meal Description
                Center(
                  child: Text(
                    widget.meal.description,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                // Rating, Delivery, and Time
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.redAccent),
                        SizedBox(width: 4),
                        Text('4.7'),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.delivery_dining, color: Colors.redAccent),
                        SizedBox(width: 4),
                        Text('متوفر'),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.timer, color: Colors.redAccent),
                        SizedBox(width: 4),
                        Text('20 دقيقة'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Ingredients
                const Text(
                  'المكونات',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50, // Adjust the height as needed
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: widget.meal.ingredients.map((ingredient) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(ingredient),
                          selected: false,
                          onSelected: (selected) {
                            // Handle chip selection if needed
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                // Add-ons
                // const Text(
                //   'الإضافات',
                //   style: TextStyle(
                //     fontSize: 16,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // const SizedBox(height: 8),
                // Column(
                //   children: addOnStrings.map((addOn) {
                //     final isSelected = selectedAddOns.contains(addOn);

                //     return ListTile(
                //       title: Text(addOn),
                //       trailing: Checkbox(
                //         value: isSelected,
                //         onChanged: (bool? value) {
                //           setState(() {
                //             if (value == true) {
                //               selectedAddOns.add(addOn);
                //             } else {
                //               selectedAddOns.remove(addOn);
                //             }
                //             _calculateTotalPrice();
                //           });
                //         },
                //       ),
                //     );
                //   }).toList(),
                // ),
                const SizedBox(height: 16),
                // Quantity and Total Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'الكمية',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove,
                          ),
                          splashRadius: 4,
                          color: Colors.white,
                          style: const ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll<Color>(Colors.redAccent),
                          ),
                          onPressed: () {
                            if (quantity > 1) {
                              setState(() {
                                quantity--;
                                _totalPrice -= widget.meal.price;
                              });
                            }
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          '$quantity',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          splashRadius: 4,
                          color: Colors.white,
                          style: const ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll<Color>(Colors.redAccent),
                          ),
                          onPressed: () {
                            setState(() {
                              quantity++;
                              _totalPrice = widget.meal.price * quantity;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'السعر الإجمالي: ${_totalPrice.toStringAsFixed(2)} ₪',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decorationStyle: TextDecorationStyle.solid,
                  ),
                ),
                const SizedBox(height: 16),
                // Add to Cart Button
                Center(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          const WidgetStatePropertyAll<Color>(Colors.redAccent),
                      visualDensity: VisualDensity.standard,
                      padding: WidgetStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 42)), // زيادة الحجم
                    ),
                    onPressed: () {
                      final cartProvider =
                          Provider.of<CartProvider>(context, listen: false);
                      cartProvider.addItem(
                        CartItem(
                          meal: widget.meal,
                          quantity: quantity,
                          placeName: '',
                          userLocation: userLocation ?? const LatLng(0, 0),
                          restaurantLocation: LatLng(
                              widget.restaurant['location']['latitude'],
                              widget.restaurant['location']['longitude']),
                          storeId: widget.restaurant['storeId'],
                        ),
                      );

                      // Reset selected addons and quantity after adding to cart
                      setState(() {
                        selectedAddOns = [];
                        quantity = 1;
                      });
                      // Show snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'تمت الإضافة إلى السلة',
                            style: TextStyle(color: Colors.white),
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text(
                      'إضافة إلى السلة',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
