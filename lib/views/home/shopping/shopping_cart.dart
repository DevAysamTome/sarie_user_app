import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/models/cartProvider.dart';
import 'package:user_app/views/home/shopping/mapScreen.dart';
import 'package:user_app/views/home/shopping/payment/paymentScreen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
// استيراد مكتبة SVG

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String? _selectedAddress;
  LatLng? _selectedLocation;
  String? _deliveryOption = 'delivery'; // default to delivery
  String? _paymentOption = 'cash'; // default to cash
  double _deliveryCost = 0.0;
  int _deliveryTime = 0;
  LatLng? _restaurantLocation;
  String? _userEmail;
  @override
  void initState() {
    super.initState();
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final storeIds = cartProvider.orders.map((order) => order.storeId).toSet();
    _restaurantLocation = cartProvider.orders.isNotEmpty
        ? cartProvider.orders.first.items.first.restaurantLocation
        : null;
    for (var storeId in storeIds) {
      cartProvider.fetchStoreName(storeId);
    }
    _fetchUserEmail();
  }

  Future<void> _fetchUserEmail() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final userId = auth.currentUser!.uid;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        setState(() {
          _userEmail = userDoc.data()?['email'];
        });
      }
    } catch (e) {
      print('Error fetching user email: $e');
    }
  }

  void _selectAddress(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );

    if (result != null && result is LatLng) {
      setState(() {
        _selectedLocation = result;

        _getAddressFromLatLng(result);
        _calculateDeliveryCostAndTime();
      });
    }
  }

  Future<void> _getAddressFromLatLng(LatLng location) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(location.latitude, location.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _selectedAddress =
              '${place.street}, ${place.locality}, ${place.country}';
        });
      } else {
        setState(() {
          _selectedAddress = 'Unknown Address';
        });
      }
    } catch (e) {
      print('Error getting address: $e');
      setState(() {
        _selectedAddress = 'Error getting address';
      });
    }
  }

  Future<void> _calculateDeliveryCostAndTime() async {
    if (_selectedLocation == null || _restaurantLocation == null) {
      return;
    }

    const apiKey = 'AIzaSyBzdajHgG7xEXtoglNS42Jbh8NdMUj2DXk';
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=${_selectedLocation!.latitude},${_selectedLocation!.longitude}&destinations=${_restaurantLocation!.latitude},${_restaurantLocation!.longitude}&key=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      if (data['rows'] != null && data['rows'].isNotEmpty) {
        final elements = data['rows'][0]['elements'];
        if (elements != null && elements.isNotEmpty) {
          var durationValue = elements[0]['duration']['value'];
          var distanceValue = elements[0]['distance']['value'];

          int deliveryTime = (durationValue is String
                  ? int.parse(durationValue)
                  : durationValue.toInt()) ~/
              60; // Convert seconds to minutes

          double distanceInKm = (distanceValue is String
                  ? double.parse(distanceValue)
                  : distanceValue.toDouble()) /
              1000;

          setState(() {
            _deliveryCost = distanceInKm * 2; // Example cost calculation
            _deliveryTime = deliveryTime;
          });
        } else {
          // Handle the case where the elements list is empty
          setState(() {
            _deliveryCost = 0.0;
            _deliveryTime = 0;
          });
          print('No elements found in the API response');
        }
      } else {
        // Handle the case where the rows list is empty
        setState(() {
          _deliveryCost = 0.0;
          _deliveryTime = 0;
        });
        print('No rows found in the API response');
      }
    } else {
      throw Exception('Failed to calculate delivery cost and time');
    }
  }

  @override
  Widget build(BuildContext context) {
    var cartProvider = Provider.of<CartProvider>(context);
    final FirebaseAuth auth = FirebaseAuth.instance;
    String userId = auth.currentUser!.uid;

    bool isCartEmpty = cartProvider.orders.isEmpty;
    double totalAmount = cartProvider.totalPrice + _deliveryCost;
    String totalAmountString =
        totalAmount.toStringAsFixed(2); // Format to 2 decimal places if needed

    print(cartProvider.totalPrice);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF121223),
        appBar: AppBar(
          backgroundColor: const Color(0xFF121223),
          title:
              const Text('عربة التسوق', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: isCartEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/cart_empty.png', // استبدال بمسار صورة SVG
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'سلتك فارغة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'تصفح المتاجر وأضف بعض العناصر إلى السلة لتتمكن من إتمام عملية الشراء.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartProvider.orders.length,
                      itemBuilder: (context, orderIndex) {
                        var order = cartProvider.orders[orderIndex];
                        final storeName =
                            cartProvider.getStoreName(order.storeId);
                        return Card(
                          color: const Color(0xFF1f1f2f),
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    'متجر: $storeName',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'عدد العناصر: ${order.items.length}',
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  ),
                                ),
                                Divider(color: Colors.grey.shade800),
                                ...order.items.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2a2a39),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.network(
                                              item.meal.imageUrl,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.meal.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '\$${item.meal.price}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'الإضافات: ${item.selectedAddOns?.join(', ')}',
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove,
                                                  color: Colors.redAccent),
                                              onPressed: () {
                                                cartProvider.updateQuantity(
                                                  order.storeId,
                                                  order.items.indexOf(item),
                                                  item.quantity - 1,
                                                );
                                              },
                                            ),
                                            Text(
                                              item.quantity.toString(),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add,
                                                  color: Colors.greenAccent),
                                              onPressed: () {
                                                cartProvider.updateQuantity(
                                                  order.storeId,
                                                  order.items.indexOf(item),
                                                  item.quantity + 1,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    color: const Color(0xFF1f1f2f),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Address Section

                        const SizedBox(height: 16),

                        // Delivery Method Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Card(
                                color: _deliveryOption == 'delivery'
                                    ? const Color(0xFFFF5252)
                                    : const Color(0xFF1f1f2f),
                                child: ListTile(
                                  title: const Text(
                                    'توصيل',
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _deliveryOption = 'delivery';
                                      // You can set delivery cost and time here if needed
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Card(
                                color: _deliveryOption == 'pickup'
                                    ? const Color(0xFFFF5252)
                                    : const Color(0xFF1f1f2f),
                                child: ListTile(
                                  title: const Text('استلام من المحل',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white)),
                                  onTap: () {
                                    setState(() {
                                      _deliveryOption = 'pickup';
                                      // Reset delivery cost and time if picking up
                                      _deliveryCost = 0.0;
                                      _deliveryTime = 0;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _deliveryOption == 'delivery'
                            ? (Card(
                                color: const Color(0xFF2a2a39),
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: ListTile(
                                  title: Text(
                                    'العنوان: ${_selectedAddress ?? 'حدد عنواناً'}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () => _selectAddress(context),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: const Color(0xFFFF5252),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 30),
                                    ),
                                    child: const Text('اختر عنوانًا'),
                                  ),
                                ),
                              ))
                            : const SizedBox(height: 16),
                        // Payment Method Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Card(
                                color: _paymentOption == 'cash'
                                    ? const Color(0xFFFF5252)
                                    : const Color(0xFF1f1f2f),
                                child: ListTile(
                                  title: const Text('نقداً عند الاستلام',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white)),
                                  onTap: () {
                                    setState(() {
                                      _paymentOption = 'cash';
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Card(
                                color: _paymentOption == 'card'
                                    ? const Color(0xFFFF5252)
                                    : const Color(0xFF1f1f2f),
                                child: ListTile(
                                  title: const Text('بطاقة ائتمان',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white)),
                                  onTap: () {
                                    setState(() {
                                      _paymentOption = 'card';
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Total Cost Section

                        const SizedBox(height: 8),
                        if (_deliveryOption == 'delivery')
                          Card(
                            color: Colors.redAccent,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const Text(
                                    'تكلفة التوصيل: ',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  Text(
                                    _deliveryCost.toStringAsFixed(2),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),

                        if (_deliveryOption == 'delivery')
                          Card(
                            color: Colors.redAccent,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const Text(
                                    'مدة التوصيل: ',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  Text(
                                    '$_deliveryTime دقيقة',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Card(
                          color: Colors.redAccent,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const Text(
                                    'إجمالي الطلب:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    totalAmountString,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                        // Confirm Order Button
                        const SizedBox(height: 16),

                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              double totalAmount =
                                  cartProvider.totalPrice + _deliveryCost;
                              String totalAmountString =
                                  totalAmount.toStringAsFixed(2);
                              print(_selectedAddress);
                              print(_selectedLocation);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentScreen(
                                    totalPrice:
                                        double.parse(totalAmount.toString()),
                                    selectedAddress: _selectedAddress ?? '',
                                    deliveryCost: _deliveryCost,
                                    deliveryTime: _deliveryTime,
                                    paymentOption: _paymentOption!,
                                    storeName: cartProvider.getStoreName(
                                        cartProvider.orders.first.storeId),
                                    userEmail: _userEmail.toString(),
                                    cartItems: cartProvider.orders
                                        .expand((order) => order.items)
                                        .toList(),
                                    selectedLocation: _selectedLocation,
                                    restaurantLocation: _restaurantLocation,
                                    deliveryOption: _deliveryOption!,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color(0xFF2b2b36),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('إتمام الطلب'),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
