// lib/res/components/beverageStoreCard.dart
import 'package:flutter/material.dart';

class BeverageStoreCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final List<String> categories;
  final List<Map<String, dynamic>> items;

  const BeverageStoreCard({super.key, 
    required this.imageUrl,
    required this.title,
    required this.categories,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(imageUrl, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(categories.join(', ')),
          ),
        ],
      ),
    );
  }
}

