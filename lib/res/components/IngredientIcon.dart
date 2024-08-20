import 'package:flutter/material.dart';

class IngredientIcon extends StatelessWidget {
  final IconData icon;

  const IngredientIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: 32, color: Colors.orange);
  }
}
