import 'package:flutter/material.dart';
import 'package:user_app/res/components/reviewItem.dart';

class ReviewsScreen extends StatelessWidget {
  final List<Map<String, String>> reviews = [
    {
      'user': 'محمد أحمد',
      'comment': 'تجربة رائعة! المنتج كان ممتاز وخدمة العملاء كانت ممتازة.',
      'date': '20 يناير 2023',
    },
    {
      'user': 'سارة علي',
      'comment': 'جودة المنتج جيدة لكن واجهت بعض المشاكل في التوصيل.',
      'date': '15 فبراير 2023',
    },
    // أضف المزيد من الآراء هنا
  ];

   ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: const Text(
            'آراء المستخدمين',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: reviews.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد آراء حتى الآن',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    return ReviewItem(
                      user: reviews[index]['user']!,
                      comment: reviews[index]['comment']!,
                      date: reviews[index]['date']!,
                    );
                  },
                ),
        ),
      ),
    );
  }
}
