import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/models/cartItem.dart';
import 'package:user_app/models/cartProvider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:user_app/models/meal.dart';

class SweetItemDetails extends StatefulWidget {
  final Meal sweetItem;
  final Map<String, dynamic> sweetStore;

  const SweetItemDetails({super.key, required this.sweetItem, required this.sweetStore});

  @override
  _SweetItemDetailsState createState() => _SweetItemDetailsState();
}

class _SweetItemDetailsState extends State<SweetItemDetails> {
  List<String> selectedAddOns = [];
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'التفاصيل',
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Navigate to the cart screen or display a dialog showing cart items.
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('العناصر في السلة'),
                    content: Consumer<CartProvider>(
                      builder: (context, cartProvider, _) {
                        return ListView.builder(
                          itemCount: cartProvider.cartItemCount,
                          itemBuilder: (BuildContext context, int index) {
                            final cartItem = cartProvider.orders
                                .expand((order) => order.items)
                                .firstWhere(
                                    (item) =>
                                        item.meal.id == widget.sweetItem.id,
                                    orElse: () => CartItem(
                                          meal: widget.sweetItem,
                                          quantity: 0,
                                          selectedAddOns: [],
                                          placeName: '',
                                          userLocation: const LatLng(
                                              0, 0), // Use actual location
                                          restaurantLocation: LatLng(
                                              widget.sweetStore[
                                                      'location']
                                                  ['latitude'],
                                              widget.sweetStore[
                                                      'location']
                                                  ['longitude']),
                                          storeId:
                                              widget.sweetStore['storeId'],
                                        ));

                            return ListTile(
                              title: Text(cartItem.meal.name),
                              subtitle: Text(
                                  'المتجر: ${widget.sweetStore['name']}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  cartProvider.removeItem(
                                      cartItem.storeId, index);
                                  Navigator.pop(
                                      context); // Close dialog after deleting item
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Beverage Image
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
                      widget.sweetItem.imageUrl,
                      fit: BoxFit.cover,
                      width: 300,
                      height: 200,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Beverage Store Name
              Center(
                child: Chip(
                  avatar: const CircleAvatar(
                    backgroundImage: AssetImage("assets/icons/heart.png"),
                  ),
                  label: Text(
                    widget.sweetStore['name'] ?? 'اسم المتجر',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Beverage Name
              Center(
                child: Text(
                  widget.sweetItem.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Beverage Description
              Center(
                child: Text(
                  widget.sweetItem.description,
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
              // Add-ons
              const Text(
                'الإضافات',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: widget.sweetItem.addOns.map((addOn) {
                  return ChoiceChip(
                    label: Text(addOn),
                    selected: selectedAddOns.contains(addOn),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedAddOns.add(addOn);
                        } else {
                          selectedAddOns.remove(addOn);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Price and Quantity
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.sweetItem.price} ₪',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (quantity > 1) {
                              quantity--;
                            }
                          });
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      Text(
                        '$quantity',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Add to Cart Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    final cartProvider =
                        Provider.of<CartProvider>(context, listen: false);
                    cartProvider.addItem(
                      CartItem(
                        meal: widget.sweetItem,
                        quantity: quantity,
                        selectedAddOns: selectedAddOns,
                        placeName: '',
                        userLocation: const LatLng(0, 0), // Use actual location
                        restaurantLocation: LatLng(
                            double.parse(
                                widget.sweetStore['location']
                                    ['latitude']),
                            double.parse(
                                widget.sweetStore['location']
                                    ['longitude'])),
                        storeId: widget.sweetStore['storeId'],
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
                        content: Text('تمت الإضافة إلى السلة'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('إضافة إلى السلة'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
