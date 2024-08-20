import 'package:flutter/material.dart';
import 'package:user_app/services/order_cancellation_service.dart';
import 'package:user_app/services/order_reorder_service.dart';
import 'package:user_app/services/order_rating_service.dart';
import 'package:user_app/views/order_tracking_screen/order_tracking_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final List<Map<String, dynamic>> itemsList;
  final String orderNumber;
  final String status;
  final String? date;
  final bool isOngoing;
  final LatLng orderLocation; // إضافة موقع الطلب
  final LatLng restaurantLocation; // إضافة موقع المطعم
  final DateTime? orderEndTime; // إضافة orderEndTime

  const OrderCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.itemsList,
    required this.orderNumber,
    required this.status,
    this.date,
    required this.isOngoing,
    required this.orderLocation, // إضافة موقع الطلب
    required this.restaurantLocation, // إضافة موقع المطعم
    this.orderEndTime, // إضافة orderEndTime
  });

  @override
  Widget build(BuildContext context) {
    final orderCancellationService = OrderCancellationService();
    final orderReorderService = OrderReorderService();
    final orderRatingService = OrderRatingService();

    final bool canCancelOrder = isOngoing &&
        (orderEndTime == null || DateTime.now().isBefore(orderEndTime!));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Card(
        color: Colors.white,
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.network(
                    imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('#$orderNumber'),
                        if (date != null) Text(date!),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: itemsList.length,
                          itemBuilder: (context, index) {
                            final item = itemsList[index];
                            return Text(
                              '${item['quantity']} x ${item['mealName']}',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isOngoing)
                        Text(
                          'حالة الطلب: $status',
                          style: TextStyle(
                            color: status == 'مكتمل'
                                ? Colors.green
                                : status == 'قيد التنفيذ'
                                    ? Colors.orange
                                    : status == 'ملغي'
                                        ? Colors.red
                                        : Colors.black,
                          ),
                        ),
                      if (!isOngoing)
                        Text(
                          'حالة الطلب: $status',
                          style: TextStyle(
                            color: status == 'مكتمل'
                                ? Colors.green
                                : status == 'قيد التنفيذ'
                                    ? Colors.orange
                                    : status == 'ملغي'
                                        ? Colors.red
                                        : Colors.black,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isOngoing)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderTrackingPage(
                              orderLocation: orderLocation,
                              restaurantLocation: restaurantLocation,
                              deliveryWorkerId: '8sRQfFGoyNfygABckYty4dVbx7O2',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                      child: const Text(
                        'تتبع الطلب',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  else ...[
                    OutlinedButton(
                      onPressed: () {
                        orderRatingService.rateOrder(context, orderNumber);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                      child: const Text(
                        'تقييم',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        orderReorderService.reorder(context, orderNumber);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                      child: const Text(
                        'إعادة الطلب',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                  if (canCancelOrder)
                    OutlinedButton(
                      onPressed: () {
                        orderCancellationService.cancelOrder(
                            context, orderNumber);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                      child: const Text('إلغاء'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
