import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart'; // استيراد الحزمة للمشاركة
import 'package:url_launcher/url_launcher.dart';
import 'package:user_app/views/login_views/login_view.dart'; // استيراد الحزمة لإطلاق الروابط

class AppDrawer extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AppDrawer({super.key});

  Future<Map<String, dynamic>> _getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();
      return doc.data() as Map<String, dynamic>? ?? {};
    }
    return {}; // Return an empty map if user is not authenticated
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Drawer(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Drawer(
            child: Center(child: Text('Error fetching user data')),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Drawer(
            child: Center(child: Text('No user data found')),
          );
        }

        final userData = snapshot.data!;

        return Drawer(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _createHeader(userData),
                    _createActionsCard(context),
                    _createWorkHoursCard(), // Adding the work hours card
                  ],
                ),
              ),
              // Add the version info at the bottom
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    'Version 1.0.0', // Replace with your app version
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _createHeader(Map<String, dynamic> userData) {
    final accountName = userData['fullName'] ?? 'اسم غير معروف';
    final accountEmail = userData['email'] ?? 'بريد إلكتروني غير معروف';

    return UserAccountsDrawerHeader(
      accountName: Text(accountName, style: const TextStyle(fontSize: 20)),
      accountEmail: Text(accountEmail, style: const TextStyle(fontSize: 16)),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: const Icon(Icons.person, size: 50, color: Colors.grey),
      ),
      decoration: const BoxDecoration(
        color: Colors.redAccent,
      ),
    );
  }

  Widget _createActionsCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(boxShadow: const [
        BoxShadow(
          color: Color.fromARGB(255, 241, 239, 239),
          offset: Offset(0.1, 0.1),
        ),
      ], borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.blue),
            title: const Text('تواصل مع سريع'),
            onTap: () => _onSelectItem(context, 3),
          ),
          const SizedBox(
            height: 10,
          ),
          ListTile(
            leading: const Icon(Icons.share, color: Colors.green),
            title: const Text('شارك'),
            onTap: () => _onSelectItem(context, 4),
          ),
          const SizedBox(
            height: 10,
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('تسجيل الخروج'),
            onTap: () => _onSelectItem(context, 5),
          ),
        ],
      ),
    );
  }

  Widget _createWorkHoursCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'ساعات العمل\n8:00 - 1:00',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }

  void _onSelectItem(BuildContext context, int index) async {
    switch (index) {
      case 3:
        _showContactOptions(context);
        break;
      case 4:
        _shareApp();
        break;
      case 5:
        await FirebaseAuth.instance.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  LoginScreen()), // استبدل بالشاشة التي ترغب في عرضها بعد تسجيل الخروج
          (route) => false, // يزيل كافة الشاشات السابقة من الستاك
        );
        break;
      default:
        Navigator.pop(context); // Close the drawer
        break;
    }
  }

  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('+972 59-751-6129'),
                onTap: () => _launchPhoneNumber('+972597516129'),
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('+970 598-864-153'),
                onTap: () => _launchPhoneNumber('+970598864153'),
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('إغلاق'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _launchPhoneNumber(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _shareApp() {
    const text = 'Check out this amazing app!';
    Share.share(text);
  }
}
