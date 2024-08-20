import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:user_app/res/components/profileMenuItem.dart';
import 'package:user_app/views/home/profile_screen/faqs_view/faqs_screen.dart';
import 'package:user_app/views/home/profile_screen/faviroute_view/faviroute_Screen.dart';
import 'package:user_app/views/home/profile_screen/loyaltePoint/loyaltyPointScreen.dart';
import 'package:user_app/views/home/profile_screen/personal_details/address_delivery/address_screen.dart';
import 'package:user_app/views/home/profile_screen/personal_details/basic_information/basic_info.dart';
import 'package:user_app/views/home/profile_screen/users_review_view/users_review_screen.dart';
import 'package:user_app/views/home/shopping/shopping_cart.dart';
import 'package:user_app/views/login_views/login_view.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return doc.data() as Map<String, dynamic>? ?? {};
    }
    return {}; // Return an empty map if user is not authenticated
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text(
          'صفحتي',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 3,
        automaticallyImplyLeading: false,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching user data'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No user data found'));
            }

            final userData = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.redAccent,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            userData['fullName'] ?? 'اسم غير معروف',
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            userData['bio'] ?? 'معلومات غير متوفرة',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'نقاطك في تطبيق سريع: ${userData['loyaltyPoints'] ?? 0}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(255, 241, 239, 239),
                        offset: Offset(0.1, 0.1),
                      ),
                    ], borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      children: [
                        ProfileMenuItem(
                          icon: Icons.person_outline,
                          text: 'المعلومات الشخصية',
                          iconColor: Colors.deepOrange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditProfileScreen(
                                        userId: FirebaseAuth
                                            .instance.currentUser!.uid,
                                      )),
                            );
                          },
                        ),
                        ProfileMenuItem(
                          icon: Icons.location_on_outlined,
                          text: 'العناوين',
                          iconColor: Colors.green,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AddressScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(255, 241, 239, 239),
                        offset: Offset(0.1, 0.1),
                      ),
                    ], borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      children: [
                        ProfileMenuItem(
                          icon: Icons.shopping_cart_outlined,
                          text: 'السلة',
                          iconColor: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CartScreen()),
                            );
                          },
                        ),
                        ProfileMenuItem(
                          icon: Icons.favorite_outline,
                          text: 'المفضلة',
                          iconColor: Colors.pink,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const FavoritesScreen()),
                            );
                          },
                        ),
                        ProfileMenuItem(
                          icon: Icons.redeem,
                          text: 'نقاط الولاء',
                          iconColor: Colors.orange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoyaltyRewardsScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(255, 241, 239, 239),
                        offset: Offset(0.1, 0.1),
                      ),
                    ], borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      children: [
                        ProfileMenuItem(
                          icon: Icons.help_outline,
                          text: 'الأسئلة الشائعة',
                          iconColor: Colors.teal,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>  FAQScreen()),
                            );
                          },
                        ),
                        ProfileMenuItem(
                          icon: Icons.message_outlined,
                          text: 'اراء المستخدمين',
                          iconColor: Colors.blueAccent,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>  ReviewsScreen()),
                            );
                          },
                        ),
                        ProfileMenuItem(
                          icon: Icons.logout,
                          text: 'تسجيل الخروج',
                          iconColor: Colors.red,
                          onTap: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                       LoginScreen()), // استبدل بالشاشة التي ترغب في عرضها بعد تسجيل الخروج
                              (route) =>
                                  false, // يزيل كافة الشاشات السابقة من الستاك
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
