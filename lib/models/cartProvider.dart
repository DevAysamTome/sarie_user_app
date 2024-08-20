import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:user_app/models/cartItem.dart';
import 'order.dart' as od;

class CartProvider extends ChangeNotifier {
  final List<od.Order> _orders = [];
  final Map<String, String> _storeNames = {}; // New map to hold store names

  List<od.Order> get orders => _orders;
  int get cartItemCount =>
      _orders.fold(0, (sum, order) => sum + order.items.length);
  Future<void> fetchStoreName(String storeId) async {
    try {
      final collections = [
        'restaurants',
        'pharmacies',
        'beverageStores',
        'sweetStore',
      ];

      for (var collection in collections) {
        final storeDoc = await FirebaseFirestore.instance
            .collection(collection)
            .doc(storeId)
            .get();
        if (storeDoc.exists) {
          _storeNames[storeId] = storeDoc['name']; // Store the store name
          notifyListeners();
          return; // Exit after finding the store
        }
      }
    } catch (e) {
      print('Error fetching store name: $e');
    }
  }

  String getStoreName(String storeId) {
    return _storeNames[storeId] ?? 'اسم المتجر غير معروف';
  }

  void addItem(CartItem item) {
    bool isExistingOrder = false;
    for (var order in _orders) {
      if (order.storeId == item.storeId) {
        order.addItem(item);
        isExistingOrder = true;
        break;
      }
    }

    if (!isExistingOrder) {
      _orders.add(od.Order(
        storeId: item.storeId,
        items: [item],
        orderId: '', // سيتم تعيينه لاحقًا
      ));
    }

    notifyListeners();
  }

  void removeItem(String storeId, int index) {
    for (var order in _orders) {
      if (order.storeId == storeId) {
        order.removeItem(index);
        if (order.items.isEmpty) {
          _orders.remove(order);
        }
        break;
      }
    }
    notifyListeners();
  }

  void updateQuantity(String storeId, int index, int quantity) {
    for (var order in _orders) {
      if (order.storeId == storeId &&
          index >= 0 &&
          index < order.items.length) {
        order.items[index].quantity = quantity;
        notifyListeners();
        break;
      }
    }
  }

  Future<void> placeOrder(String storeId, String placeName, LatLng userLocation,
      LatLng restaurantLocation, String deliveryOption , String paymentOption) async {
    for (var order in _orders) {
      if (order.storeId == storeId) {
        for (var item in order.items) {
          item.placeName = placeName;
          item.userLocation = userLocation;
          item.restaurantLocation = restaurantLocation;
        
        }

        // الحصول على الرقم المتزايد
        final orderNumbersRef = FirebaseFirestore.instance
            .collection('order_numbers')
            .doc('current');
        final orderNumbersDoc = await orderNumbersRef.get();
        final currentNumber = orderNumbersDoc.exists
            ? orderNumbersDoc.data()!['currentNumber'] as int
            : 0;

        // تحديث الرقم المتزايد في Firestore
        await orderNumbersRef.set({'currentNumber': currentNumber + 1});

        // تعيين رقم الطلب
        final orderId = (currentNumber + 1).toString();

        // تحديث الطلب برقم الطلب الجديد
        final updatedOrder = od.Order(
          storeId: order.storeId,
          items: order.items,
          orderId: orderId,
        );

        // إرسال الطلب إلى Firestore
        await FirebaseFirestore.instance
            .collection('orders')
            .add(updatedOrder.toMap());

        // إزالة الطلب بعد تقديمه
        _orders.remove(order);
        break;
      }
    }
    notifyListeners();
  }
  void clearCart() {
    _orders.clear();
    notifyListeners();
  }

  double get totalPrice {
    double total = 0;
    for (var order in _orders) {
      total += order.totalPrice;
    }
    return total;
  }
}
