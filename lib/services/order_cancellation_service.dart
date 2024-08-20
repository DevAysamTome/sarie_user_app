import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderCancellationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> cancelOrder(BuildContext context, String orderId) async {
    // عرض حوار تأكيد للإلغاء
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('إلغاء الطلب'),
          content: Text('هل أنت متأكد من أنك تريد إلغاء الطلب $orderId؟'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                // البحث عن الطلب بناءً على orderId
                try {
                  // العثور على الطلب المناسب بناءً على orderId
                  QuerySnapshot querySnapshot = await _firestore
                      .collection('orders')
                      .where('orderId', isEqualTo: orderId)
                      .get();

                  if (querySnapshot.docs.isEmpty) {
                    throw Exception('طلب غير موجود');
                  }

                  // الحصول على docId من الوثيقة التي تطابق orderId
                  String docId = querySnapshot.docs.first.id;

                  // قم بتحديث حالة الطلب في قاعدة البيانات
                  await _firestore.collection('orders').doc(docId).update({
                    'orderStatus': 'ملغي', // افترض أن لديك حقل الحالة
                  });

                  // عرض رسالة تأكيد
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم إلغاء الطلب بنجاح')),
                  );
                } catch (e) {
                  print('Error canceling order: $e');
                  // عرض رسالة خطأ إذا فشل الإلغاء
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('فشل إلغاء الطلب')),
                  );
                }

                Navigator.of(context).pop();
              },
              child: const Text('نعم'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('لا'),
            ),
          ],
        );
      },
    );
  }
}
