import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // تسجيل الدخول أو إنشاء حساب باستخدام رقم الهاتف
  Future<void> signInWithPhone(String phoneNumber, Function(String) codeSentCallback) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Error verifying phone number: $e');
      },
      codeSent: (String verificationId, int? resendToken) {
        codeSentCallback(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // التحقق من الرمز وتسجيل الدخول
  Future<String> verifyCode(String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // التحقق إذا كان المستخدم جديدًا
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        // إنشاء مستند جديد للمستخدم في Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'phoneNumber': userCredential.user!.phoneNumber,
          'role': 'user', // يمكنك تحديد الدور الافتراضي هنا
        });
      }

      return 'user';
    } catch (e) {
      print('Error verifying code: $e');
      return 'error';
    }
  }
}
