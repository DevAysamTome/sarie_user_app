import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'meal.dart';

class CartItem {
  final String storeId;
  final Meal meal;
  int quantity;
  List<dynamic>? selectedAddOns;  // تأكد من إضافة هذا المعامل
  String? placeName;
  LatLng? userLocation;
  LatLng? restaurantLocation;
  final String? prescriptionImageUrl; // إضافة هذا الحقل

  CartItem({
    required this.storeId,
    required this.meal,
    this.quantity = 1,
    this.selectedAddOns,
    this.placeName,
    this.userLocation,
    this.restaurantLocation,
        this.prescriptionImageUrl,

  });

  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'meal': meal.toMap(),
      'quantity': quantity,
      'selectedAddOns': selectedAddOns, // تأكد من إضافة هذا المعامل
      'placeName': placeName,
      'userLocation': userLocation?.toJson(),
      'restaurantLocation': restaurantLocation?.toJson(),
    };
  }
}

extension LatLngExtension on LatLng {
  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}
