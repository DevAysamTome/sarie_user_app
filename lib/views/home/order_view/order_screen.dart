import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/controller/orderController.dart';
import 'package:user_app/res/components/orederList.dart';
import 'package:firebase_auth/firebase_auth.dart'; // استيراد FirebaseAuth

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  String? _userId; // تعريف معرف المستخدم

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // الحصول على userId من FirebaseAuth
    _userId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'طلباتي',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          centerTitle: true,
          automaticallyImplyLeading: false,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.redAccent,
            labelColor: Colors.white,
            tabs: const [
              Tab(text: 'الطلبات الجارية'),
              Tab(text: 'تاريخ الطلبات'),
            ],
          ),
        ),
        body: _userId == null // تحقق من وجود userId
            ? const Center(child: Text('لم يتم تسجيل الدخول'))
            : TabBarView(
                controller: _tabController,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestoreService.getOngoingOrders(_userId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('حدث خطأ في جلب البيانات'));
                      }

                      List<DocumentSnapshot> ongoingOrders =
                          snapshot.data?.docs ?? [];
                      return OrdersList(
                        orders: ongoingOrders,
                        isOngoing: true,
                      );
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestoreService.getOrderHistory(_userId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('حدث خطأ في جلب البيانات'));
                      }

                      List<DocumentSnapshot> orderHistory =
                          snapshot.data?.docs ?? [];
                      return OrdersList(
                        orders: orderHistory,
                        isOngoing: false,
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
