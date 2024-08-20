import 'package:flutter/material.dart';

class OrderRatingService {
  void rateOrder(BuildContext context, String orderId) {
    // هنا يمكنك وضع الكود الفعلي لتقييم الطلب
    // مثلا يمكنك عرض حوار للتقييم
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تقييم الطلب'),
          content: Text('رجاءً قيم الطلب $orderId'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // كود التقييم هنا
                Navigator.of(context).pop();
              },
              child: const Text('إرسال'),
            ),
          ],
        );
      },
    );
  }
}
