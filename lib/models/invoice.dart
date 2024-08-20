import 'package:user_app/models/cartItem.dart';

class Invoice {
  final String invoiceId;
  final String orderId;
  final String userEmail;
  final List<CartItem> items;
  final double totalPrice;
  final double deliveryCost;
  final DateTime timestamp;

  Invoice({
    required this.invoiceId,
    required this.orderId,
    required this.userEmail,
    required this.items,
    required this.totalPrice,
    required this.deliveryCost,
    required this.timestamp,
  });
}
