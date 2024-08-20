import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/models/cartProvider.dart';
import 'package:user_app/res/components/orderCard.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrdersList extends StatelessWidget {
  final List<DocumentSnapshot> orders;
  final bool isOngoing;

  const OrdersList({super.key, required this.orders, required this.isOngoing});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final orderData = orders[index].data();
        if (orderData == null) {
          return const SizedBox.shrink();
        }

        final order = orderData as Map<String, dynamic>;
        final storeOrdersCollection =
            orders[index].reference.collection('storeOrders');

        return FutureBuilder<QuerySnapshot>(
          future: storeOrdersCollection.get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.docs.isEmpty) {
              return const SizedBox.shrink();
            }

            final storeOrders = snapshot.data!.docs;

            // Handle deliveryDetails and location

            return Card(
              margin: const EdgeInsets.all(8.0),
              color: Colors.white,
              elevation: 10,
              borderOnForeground: true,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'رقم الطلب #${order['orderId']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'المبلغ الكلي: ${order['totalPrice']} شيكل',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'نوع الطلب: ${order['deliveryOption'] == 'pickup' ? 'استلام من المحل' : 'توصيل'}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: storeOrders.map((storeOrder) {
                        final storeOrderData =
                            storeOrder.data() as Map<String, dynamic>;
                        var cartProvider =
                            Provider.of<CartProvider>(context, listen: false);

                        // Handle items
                        final items =
                            storeOrderData['items'] as List<dynamic>? ?? [];
                        final orderLocationData =
                            storeOrderData['deliveryDetails']?['location']
                                    as Map<String, dynamic>? ??
                                {};
                        final orderLatitude =
                            orderLocationData['latitude'] as double?;
                        final orderLongitude =
                            orderLocationData['longitude'] as double?;

                        final orderLocation =
                            orderLatitude != null && orderLongitude != null
                                ? LatLng(orderLatitude, orderLongitude)
                                : LatLng(0.0, 0.0);
                        // Handle restaurantLocation
                        final restaurantLocationData =
                            storeOrderData['restaurantLocation']
                                    as Map<String, dynamic>? ??
                                {};

                        final restaurantLatitude =
                            restaurantLocationData['latitude'] as double?;
                        final restaurantLongitude =
                            restaurantLocationData['longitude'] as double?;

                        final restaurantLocation = restaurantLatitude != null &&
                                restaurantLongitude != null
                            ? LatLng(restaurantLatitude, restaurantLongitude)
                            : LatLng(0.0, 0.0); // Default value if null

                        // Handle orderEndTime
                        final orderEndTimeTimestamp =
                            storeOrderData['orderEndTime'] as Timestamp?;
                        final orderEndTime = orderEndTimeTimestamp?.toDate();

                        return OrderCard(
                          imageUrl:
                              items.isNotEmpty ? items[0]['imageUrl'] : '',
                          title: cartProvider
                                  .getStoreName(storeOrderData['storeId']) ??
                              '',
                          price: '${storeOrderData['totalPrice']} شيكل',
                          itemsList: items.map((item) {
                            final itemData = item as Map<String, dynamic>;
                            return {
                              'mealName': itemData['mealName'],
                              'imageUrl': itemData['imageUrl'],
                              'mealPrice': itemData['mealPrice'],
                              'quantity': itemData['quantity'] as int? ?? 0,
                            };
                          }).toList(),
                          orderNumber: storeOrderData['orderId'],
                          status: storeOrderData['orderStatus'],
                          date: storeOrderData['timestamp'] != null
                              ? (storeOrderData['timestamp'] as Timestamp)
                                  .toDate()
                                  .toString()
                              : null,
                          isOngoing: isOngoing,
                          orderLocation: orderLocation,
                          restaurantLocation: restaurantLocation,
                          orderEndTime: orderEndTime,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
