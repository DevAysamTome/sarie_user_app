import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:user_app/models/cartItem.dart';
import 'package:user_app/models/cartProvider.dart';
import 'package:user_app/models/meal.dart';

class PharmasyDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> pharmacy;

  const PharmasyDetailsScreen({super.key, required this.pharmacy});

  @override
  _PharmasyDetailsScreenState createState() => _PharmasyDetailsScreenState();
}

class _PharmasyDetailsScreenState extends State<PharmasyDetailsScreen> {
  final TextEditingController _medicineNameController = TextEditingController();
  bool _uploadPrescription = false;
  File? _prescriptionImage;
  String? _requestId; // Store the request ID

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _medicineNameController.dispose();
    super.dispose();
  }

  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _prescriptionImage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String?> _uploadPrescriptionImage() async {
    if (_prescriptionImage == null) return null;

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('prescriptions/$fileName');
      UploadTask uploadTask = ref.putFile(_prescriptionImage!);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void _sendRequestToPharmacy() async {
    String medicineName = _medicineNameController.text.trim();
    String? prescriptionImageUrl = await _uploadPrescriptionImage();
    final requestDoc = _firestore.collection('pharmacy_requests').doc();

    await requestDoc.set({
      'medicineName': medicineName,
      'prescriptionImageUrl': prescriptionImageUrl,
      'pharmacyId': widget.pharmacy['storeId'] ?? 'unknown',
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });

    setState(() {
      _requestId = requestDoc.id;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال الطلب إلى الصيدلية')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.pharmacy['name'] ?? 'اسم غير متوفر'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Pharmacy Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.pharmacy['imageUrl'] ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pharmacy Name
            Text(
              widget.pharmacy['name'] ?? 'اسم غير متوفر',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),

            // Pharmacy Description
            Text(
              widget.pharmacy['description'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Delivery Info and Options
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 24),
                    SizedBox(width: 4),
                    Text(
                      '0',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.delivery_dining, color: Colors.green, size: 24),
                    SizedBox(width: 4),
                    Text(
                      'توصيل',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.timer, color: Colors.redAccent, size: 24),
                    SizedBox(width: 4),
                    Text(
                      '20 دقيقة',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Option 1: Enter Medicine Name
            TextFormField(
              controller: _medicineNameController,
              decoration: const InputDecoration(
                labelText: 'اسم الدواء أو المنتج المطلوب',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Option 2: Upload Prescription
            Row(
              children: [
                Checkbox(
                  value: _uploadPrescription,
                  onChanged: (value) {
                    setState(() {
                      _uploadPrescription = value!;
                      if (_uploadPrescription) {
                        _getImageFromGallery();
                      } else {
                        _prescriptionImage = null;
                      }
                    });
                  },
                ),
                const Text('رفع صورة روشتة طبية'),
              ],
            ),
            const SizedBox(height: 16),

            // Display Uploaded Prescription Image
            if (_prescriptionImage != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(_prescriptionImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Button to Send Request
            ElevatedButton(
              onPressed: _sendRequestToPharmacy,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'أرسل طلب إلى الصيدلية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // StreamBuilder to listen for status changes
            if (_requestId != null)
              StreamBuilder<DocumentSnapshot>(
                stream: _firestore
                    .collection('pharmacy_requests')
                    .doc(_requestId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text('الطلب غير موجود.'));
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final status = data['status'] as String?;
                  final price = data['price'];

                  if (status == 'Price Provided' && price != null) {
                    return ElevatedButton(
                      onPressed: () {
                        final cartProvider =
                            Provider.of<CartProvider>(context, listen: false);
                        cartProvider.addItem(
                          CartItem(
                            meal: Meal(
                                id: _requestId.toString(),
                                name: _medicineNameController.text,
                                description: '',
                                price: double.parse(price),
                                imageUrl: widget.pharmacy['imageUrl'],
                                ingredients: [],
                                addOns: [],
                                category: ''),
                            quantity: 1,
                            placeName: '',
                            userLocation:
                                const LatLng(0, 0), // Use actual location
                            restaurantLocation: LatLng(
                                double.parse(
                                    widget.pharmacy['pharmacies_location']
                                        ['latitude']),
                                double.parse(
                                    widget.pharmacy['pharmacies_location']
                                        ['longitude'])),
                            storeId: widget.pharmacy['storeId'],
                          ),
                        );

                        // Reset selected addons and quantity after adding to cart

                        // Show snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تمت الإضافة إلى السلة'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تمت إضافة ${_medicineNameController.text} إلى السلة بسعر $price',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 16),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'أضف إلى السلة بسعر $price',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }

                  return const SizedBox
                      .shrink(); // No button if price is not provided
                },
              ),
          ],
        ),
      ),
    );
  }
}
