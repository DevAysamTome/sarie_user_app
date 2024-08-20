import 'package:flutter/material.dart';

class PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const PaymentOption(
      {super.key, required this.icon, required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 30,
          color: selected ? Colors.orange : Colors.grey,
        ),
        Text(
          label,
          style: TextStyle(
            color: selected ? Colors.orange : Colors.grey,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
