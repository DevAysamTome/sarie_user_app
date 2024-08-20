import 'package:flutter/material.dart';
import 'package:user_app/res/components/faqItem.dart';

class FAQScreen extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {
      'question': 'كيف يمكنني الدفع عبر التطبيق؟',
      'answer': 'يمكنك الدفع عبر التطبيق باستخدام فيزا أو ماستركارد أو باي بال.'
    },
    {
      'question': 'هل يمكنني إلغاء طلبي بعد الدفع؟',
      'answer': 'نعم، يمكنك إلغاء طلبك خلال ساعتين من تأكيد الدفع.'
    },
    {
      'question': 'كيف يمكنني تتبع طلبي؟',
      'answer': 'يمكنك تتبع طلبك من خلال صفحة "طلباتي" في التطبيق.'
    },
    // أضف المزيد من الأسئلة والإجابات هنا
  ];

   FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'الأسئلة الشائعة',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // تنفيذ عند الضغط على زر الرجوع
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: faqs.length,
          itemBuilder: (context, index) {
            return FAQItem(
              question: faqs[index]['question']!,
              answer: faqs[index]['answer']!,
            );
          },
        ),
      ),
    );
  }
}

