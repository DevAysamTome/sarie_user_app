import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
 final TextEditingController addressController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController postCodeController = TextEditingController();
  final TextEditingController apartmentController = TextEditingController();
  String label = 'Home';
  LatLng selectedLocation = const LatLng(31.7683, 35.2137);
void addAddressToFirestore(BuildContext context) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String address = addressController.text.trim();
    String street = streetController.text.trim();
    String postCode = postCodeController.text.trim();
    String apartment = apartmentController.text.trim();

    if (address.isNotEmpty &&
        street.isNotEmpty &&
        postCode.isNotEmpty &&
        apartment.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .add({
          'address': address,
          'street': street,
          'postCode': postCode,
          'apartment': apartment,
          'location': {
            'lat': selectedLocation.latitude,
            'lng': selectedLocation.longitude,
          },
          'label': label,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت إضافة العنوان بنجاح'),
          ),
        );

        // ignore: use_build_context_synchronously
        Navigator.pop(context); // العودة إلى الشاشة السابقة بعد الحفظ
      } catch (e) {
        // ignore: avoid_print
        print('حدث خطأ أثناء إضافة العنوان: $e');
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء إضافة العنوان'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى ملء جميع الحقول'),
        ),
      );
    }
  }

