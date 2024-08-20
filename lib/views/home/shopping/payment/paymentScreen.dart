import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:user_app/models/cartItem.dart';
import 'package:user_app/models/invoice.dart';
import 'package:user_app/views/home/shopping/payment/failed_payment.dart';
import 'package:user_app/views/home/shopping/payment/sendInvoiceEmail.dart';
import 'package:user_app/views/home/shopping/payment/success_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/models/cartProvider.dart';

class PaymentScreen extends StatefulWidget {
  final double totalPrice;
  final String userEmail;
  final double deliveryCost;
  final int deliveryTime;
  final String paymentOption;
  final String deliveryOption;
  final String selectedAddress;
  final List<CartItem> cartItems;
  final LatLng? selectedLocation;
  final LatLng? restaurantLocation;
  final String storeName;

  const PaymentScreen({
    super.key,
    required this.totalPrice,
    required this.userEmail,
    required this.deliveryCost,
    required this.deliveryTime,
    required this.paymentOption,
    required this.selectedAddress,
    required this.cartItems,
    this.selectedLocation,
    this.restaurantLocation,
    required this.deliveryOption,
    required this.storeName,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late WebViewController _controller;
  late Future<String> _authorizationUrlFuture;

  String? _paymentReference;
  late bool _recaptchaVerified = false;
  bool _orderPlaced = false;
  @override
  void initState() {
    super.initState();

    if (widget.paymentOption == 'card') {
      _authorizationUrlFuture = _fetchAuthorizationUrl();
      _authorizationUrlFuture.then((authorizationUrl) {
        // تعيين الURL بعد الحصول عليه
        setState(() {
          _controller = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setNavigationDelegate(
              NavigationDelegate(
                onPageStarted: (String url) {
                  print('Page started loading: $url');
                },
                onPageFinished: (String url) async {
                  if (url.contains('close') && !_orderPlaced) {
                    setState(() {
                      _orderPlaced = true; // تعيين حالة الطلب كتمت
                    });
                    await _handlePaymentSuccess(url);
                  }
                },
                onNavigationRequest: (NavigationRequest request) async {
                  if (request.url.contains('close') && !_orderPlaced) {
                    setState(() {
                      _orderPlaced = true; // تعيين حالة الطلب كتمت
                    });
                    await _handlePaymentSuccess(request.url);
                    return NavigationDecision.prevent;
                  }
                  return NavigationDecision.navigate;
                },
              ),
            );
        });
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        var cartProvider = Provider.of<CartProvider>(context, listen: false);
        if (!_orderPlaced) {
          setState(() {
            _orderPlaced = true; // تعيين حالة الطلب كتمت
          });
          String? orderId = await getNextOrderId();
          await _placeOrder(
            widget.cartItems,
            widget.totalPrice,
            '',
            LatLng(0.0, 0.0),
            widget.restaurantLocation,
            
          ).then((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentSuccessScreen(
                  orderId: orderId,
                ),
              ),
            );
          });
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String> _fetchAuthorizationUrl() async {
    final response = await http.post(
      Uri.parse(
          'https://us-central1-sarie-46b77.cloudfunctions.net/api/start-payment'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'email': widget.userEmail,
        'amount': widget.totalPrice * 100,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print('Response data: $data'); // طباعة البيانات للتحقق
      print(widget.totalPrice);
      if (data['success'] != null && data['success'] == true) {
        if (data['authorizationUrl'] != null && data['reference'] != null) {
          _paymentReference = data['reference'];
          return data['authorizationUrl'];
        } else {
          throw Exception(
              'Authorization URL or reference is missing in response');
        }
      } else {
        throw Exception('Failed to fetch authorization URL');
      }
    } else {
      throw Exception('Failed to load URL');
    }
  }

  Future<void> _handlePaymentSuccess(String url) async {
    print('Payment URL: $url');
    if (_paymentReference != null) {
      try {
        print('Payment Reference: $_paymentReference');

        final response = await http.get(
          Uri.parse(
              'https://us-central1-sarie-46b77.cloudfunctions.net/api/verify-payment/$_paymentReference'),
          headers: {
            'Authorization': 'Bearer sk_test_jOR94pilqqkyQKW6ADBCKIJMwj73zAYQ6',
            'Content-Type': 'application/json',
          },
        );

        print(
            'Verification Response: ${response.body}'); // Log the full response

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['data']['status'] == 'success') {
            if (!_orderPlaced) {
              setState(() {
                _orderPlaced = true; // تعيين حالة الطلب كتمت
              });
            }
            var cartProvider =
                Provider.of<CartProvider>(context, listen: false);
            final String orderId = await getNextOrderId();
            await _placeOrder(
              widget.cartItems,
              widget.totalPrice,
              widget.selectedAddress,
              widget.selectedLocation,
              widget.restaurantLocation,
            ).then((_) async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentSuccessScreen(
                    orderId: orderId,
                  ),
                ),
              );
            });
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PaymentFailedScreen(),
              ),
            );
            throw Exception('Payment verification failed: ${data['message']}');
          }
        } else {
          throw Exception(
              'Failed to verify payment, status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error verifying payment: $e');
      }
    } else {
      print('Payment reference is null');
    }
  }

  Future<Invoice> _generateInvoice(String orderId) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Fetch order details
      DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .get();

      if (!orderSnapshot.exists) {
        throw Exception('Order does not exist');
      }

      Map<String, dynamic> orderData =
          orderSnapshot.data() as Map<String, dynamic>;

      // Create invoice
      Invoice invoice = Invoice(
        invoiceId: 'INV-${DateTime.now().millisecondsSinceEpoch}',
        orderId: orderId,
        userEmail: widget.userEmail,
        items: widget.cartItems,
        totalPrice: widget.totalPrice,
        deliveryCost: widget.deliveryCost,
        timestamp: DateTime.now(),
      );

      // Save invoice to Firestore
      await FirebaseFirestore.instance
          .collection('invoices')
          .doc(invoice.invoiceId)
          .set({
        'invoiceId': invoice.invoiceId,
        'orderId': invoice.orderId,
        'userEmail': invoice.userEmail,
        'items': invoice.items.map((item) => item.toMap()).toList(),
        'totalPrice': invoice.totalPrice,
        'deliveryCost': invoice.deliveryCost,
        'timestamp': invoice.timestamp,
      });

      print('Invoice created successfully');
      return invoice; // Return the created invoice
    } catch (e) {
      print('Error creating invoice: $e');
      rethrow; // Re-throw the exception to handle it in the caller method
    }
  }

  String extractReferenceFromResponse(String url) {
    Uri uri = Uri.parse(url);
    return uri.queryParameters['reference'] ?? '';
  }

  Future<String> getNextOrderId() async {
    try {
      DocumentReference orderCounterRef =
          FirebaseFirestore.instance.doc('order_numbers/current');

      return await FirebaseFirestore.instance.runTransaction(
        (transaction) async {
          DocumentSnapshot snapshot = await transaction.get(orderCounterRef);

          if (!snapshot.exists) {
            transaction.set(orderCounterRef, {'currentNumber': 0});
            return '0';
          }

          if (snapshot.data() != null &&
              snapshot.data() is Map<String, dynamic>) {
            Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
            int currentCount = data['currentNumber'] ?? 0;
            int nextCount = currentCount + 1;

            transaction.update(orderCounterRef, {'currentNumber': nextCount});

            return nextCount.toString();
          } else {
            throw Exception('Failed to find count value in counter document');
          }
        },
      );
    } catch (e) {
      print('Error getting next order ID: $e');
      return '';
    }
  }

  Future<void> _placeOrder(
    List<CartItem> cartItems,
    double totalPrice,
    String? selectedAddress,
    LatLng? selectedLocation,
    LatLng? restaurantLocation,
  ) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    try {
      var cartProvider = Provider.of<CartProvider>(context, listen: false);
      CollectionReference orders =
          FirebaseFirestore.instance.collection('orders');
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      // تقسيم cartItems حسب storeId
      Map<String, List<CartItem>> storeOrders = {};
      for (var item in cartItems) {
        if (storeOrders.containsKey(item.storeId)) {
          storeOrders[item.storeId]!.add(item);
        } else {
          storeOrders[item.storeId] = [item];
        }
      }

      // إنشاء مستند رئيسي للطلب
      String? orderId = await getNextOrderId();
      DocumentReference orderDocRef = orders.doc(orderId);
      await orderDocRef.set({
        'orderId': orderId,
        'userId': user.uid,
        'userEmail': user.phoneNumber,
        'totalPrice': totalPrice,
        'timestamp': FieldValue.serverTimestamp(),
        'paymentOptions': widget.paymentOption,
        'deliveryOption': widget.deliveryOption,
        'orderStatus': 'قيد الانتظار',
        'paymentDetails': {
          'reference': _paymentReference ?? '',
          'status': 'pending', // يمكنك تحديث الحالة بعد التحقق من الدفع
        },
      });
      final invoice = await _generateInvoice(orderId);
      await sendInvoiceByEmail(invoice);
      // حفظ كل طلب مطعم في مجموعة فرعية داخل المستند الرئيسي
      for (var entry in storeOrders.entries) {
        String storeId = entry.key;
        List<CartItem> items = entry.value;

        int points = 1 +
            (9 * (DateTime.now().millisecondsSinceEpoch % 100 / 100)).toInt();

        Map<String, dynamic> orderData = {
          'storeId': storeId,
          'orderId': orderId,
          'orderStatus': 'قيد الانتظار',
          'totalPrice': items.fold(
              0, (sum, item) => sum + item.meal.price.toInt() * item.quantity),
          'items': items.map((item) {
            return {
              'mealName': item.meal.name,
              'imageUrl': item.meal.imageUrl,
              'mealPrice': item.meal.price,
              'quantity': item.quantity,
            };
          }).toList(),
        };

        if (selectedAddress != null) {
          orderData['deliveryDetails'] = {
            'address': widget.selectedAddress,
            'cost': widget.deliveryCost,
            'time': widget.deliveryTime,
          };

          if (selectedLocation != null) {
            orderData['deliveryDetails']['location'] = {
              'latitude': widget.selectedLocation!.latitude,
              'longitude': widget.selectedLocation!.longitude,
            };
          }
        }

        if (restaurantLocation != null) {
          orderData['restaurantLocation'] = {
            'latitude': restaurantLocation.latitude,
            'longitude': restaurantLocation.longitude,
          };
        }

        // حفظ الطلب في مجموعة فرعية داخل المستند الرئيسي
        await orderDocRef.collection('storeOrders').doc(storeId).set(orderData);

        // تحديث نقاط الولاء
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(userRef);

          if (snapshot.exists) {
            if (snapshot.data() is Map<String, dynamic>) {
              Map<String, dynamic> userData =
                  snapshot.data() as Map<String, dynamic>;
              int currentPoints = userData['loyaltyPoints'] ?? 0;
              int updatedPoints = currentPoints + points;

              if (updatedPoints >= 100) {
                // Handle free meal logic here
              }

              transaction.update(userRef, {'loyaltyPoints': updatedPoints});
            } else {
              // Handle unexpected data structure
            }
          } else {
            transaction.set(userRef, {'loyaltyPoints': points});
          }
        });
      }

      cartProvider.clearCart();
    } catch (e) {
      print('Error placing order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'شاشة الدفع',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: Directionality(
                    textDirection: TextDirection.rtl,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'سياسة الدفع',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'نحن في [تطبيق سريع] نحرص على تقديم تجربة تسوق سلسة وموثوقة لعملائنا. يُرجى ملاحظة النقاط التالية بشأن الدفع:',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          ...[
                            '• عدم إمكانية الاسترداد أو الإلغاء: بمجرد إتمام عملية الدفع وتأكيد الطلب، لا يمكن استرداد المبلغ المدفوع أو إلغاء الطلب تحت أي ظرف من الظروف. تأكد من صحة تفاصيل طلبك قبل تأكيد الدفع.',
                            '• الشروط والأحكام: قبولك وإتمامك لعملية الدفع يعني أنك توافق على الشروط والأحكام الخاصة بتطبيقنا، بما في ذلك سياسة الدفع وعدم الاسترداد.',
                            '• التأكيد والمراجعة: يُنصح بمراجعة تفاصيل الطلب بعناية قبل إتمام عملية الدفع. إذا كان لديك أي استفسارات أو تحتاج إلى تعديل، يرجى التواصل معنا قبل إتمام الدفع.',
                          ].map((point) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  point,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              )),
                          const SizedBox(height: 12),
                          Text(
                            'للمزيد من المعلومات أو للاستفسارات، يرجى التواصل معنا عبر [+972597516129 او +970598864153].',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('موافق'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: widget.paymentOption == 'cash'
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 100,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          textDirection: TextDirection.rtl,
                          children: [
                            Text(
                              ' يرجى قراءة سياسة الدفع والارجاع عن طريق النقر على ',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Icon(Icons.info,
                                color: Theme.of(context).iconTheme.color),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Image.asset(
                        'assets/icons/visa.png',
                        width: 75,
                      ),
                      Image.asset(
                        'assets/icons/mastercard.png',
                        width: 75,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<String>(
                    future: _authorizationUrlFuture,
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        return WebViewWidget(
                          controller: _controller
                            ..loadRequest(Uri.parse(snapshot.data!)),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
