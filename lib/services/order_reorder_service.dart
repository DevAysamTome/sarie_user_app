import 'package:flutter/material.dart';

class OrderReorderService {
  void reorder(BuildContext context, String orderId) {
    // هنا يمكنك وضع الكود الفعلي لإعادة الطلب
    // مثلا يمكنك توجيه المستخدم لشاشة السلة مع المنتجات القديمة
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReorderScreen(orderId: orderId)),
    );
  }
}

class ReorderScreen extends StatelessWidget {
  final String orderId;

  const ReorderScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إعادة الطلب $orderId'),
      ),
      body: const Center(
        child: Text('تفاصيل إعادة الطلب هنا...'),
      ),
    );
  }
}
