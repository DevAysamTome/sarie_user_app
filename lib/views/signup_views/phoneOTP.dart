// // ignore_for_file: file_names

// import 'package:flutter/material.dart';
// import 'package:country_code_picker/country_code_picker.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
// import 'package:user_app/controller/auth_controller.dart';

// class PhoneOTPVerification extends StatefulWidget {
//   final String fullname;
//   final String email;
//   final String password;
//   final String address;
//   final String dateOfBirth;
//   final String gender;

//   const PhoneOTPVerification({
//     super.key,
//     required this.fullname,
//     required this.email,
//     required this.password,
//     required this.address,
//     required this.dateOfBirth,
//     required this.gender,
//   });

//   @override
//   _PhoneOTPVerificationState createState() => _PhoneOTPVerificationState();
// }

// class _PhoneOTPVerificationState extends State<PhoneOTPVerification> {
//   TextEditingController phoneNumber = TextEditingController();
//   TextEditingController otp = TextEditingController();
//   bool visible = false;
//   String verificationId = "";
//   String countryCode = "+970";

//   void setVerificationId(String id) {
//     setState(() {
//       verificationId = id;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("تحقق من رمز OTP"),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 20),
//                 const Text(
//                   "التحقق من الهاتف",
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   !visible
//                       ? "يجب تسجيل رقم هاتفك قبل البدء!"
//                       : "أدخل رمز التحقق الذي أرسلناه إلى رقم هاتفك ${phoneNumber.text}",
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 20),
//                 if (!visible)
//                   Row(
//                     children: [
//                       CountryCodePicker(
//                         onChanged: (code) {
//                           setState(() {
//                             countryCode = code.dialCode!;
//                           });
//                         },
//                         initialSelection: 'PS',
//                         favorite: const ['+972', 'PS'],
//                       ),
//                       Expanded(
//                         child: inputTextField(
//                           "رقم الهاتف",
//                           phoneNumber,
//                           context,
//                         ),
//                       ),
//                     ],
//                   )
//                 else
//                   PinCodeTextField(
//                     appContext: context,
//                     length: 6,
//                     obscureText: false,
//                     animationType: AnimationType.fade,
//                     pinTheme: PinTheme(
//                       shape: PinCodeFieldShape.box,
//                       borderRadius: BorderRadius.circular(8),
//                       fieldHeight: 50,
//                       fieldWidth: 40,
//                       activeFillColor: Colors.white,
//                     ),
//                     animationDuration: const Duration(milliseconds: 300),
//                     backgroundColor: Colors.transparent,
//                     enableActiveFill: true,
//                     controller: otp,
//                     onCompleted: (v) {},
//                     onChanged: (value) {
//                       setState(() {});
//                     },
//                   ),
//                 const SizedBox(height: 20),
//                 if (!visible)
//                   SendOTPButton("إرسال الرمز")
//                 else
//                   SubmitOTPButton("التحقق من رقم الهاتف"),
//                 if (visible)
//                   TextButton(
//                     onPressed: () {
//                       setState(() {
//                         visible = false;
//                       });
//                     },
//                     child: const Text("تعديل رقم الهاتف؟"),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget SendOTPButton(String text) => ElevatedButton(
//         onPressed: () async {
//           setState(() {
//             visible = !visible;
//           });
//           await AuthController()
//               .sendOTP(phoneNumber.text, setVerificationId, context);
//         },
//         style: ElevatedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//           textStyle: const TextStyle(fontSize: 21, color: Colors.white),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//           backgroundColor: Colors.blueAccent,
//           foregroundColor: Colors.white,
//           fixedSize: const Size(200, 70),
//         ),
//         child: Text(text),
//       );

//   Widget SubmitOTPButton(String text) => ElevatedButton(
//         onPressed: () async {
//           await AuthController().authenticate(
//             widget.email,
//             widget.password,
//             widget.fullname,
//             phoneNumber.text,
//             otp.text,
//             verificationId, // تمرير رمز التحقق هنا
//             widget.address,
//             widget.dateOfBirth,
//             widget.gender,
//             context,
//           );
//         },
//         style: ElevatedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//           textStyle: const TextStyle(fontSize: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//         ),
//         child: Text(text),
//       );

//   Widget inputTextField(String labelText,
//           TextEditingController textEditingController, BuildContext context) =>
//       TextField(
//         obscureText: labelText == "OTP",
//         controller: textEditingController,
//         decoration: InputDecoration(
//           labelText: labelText,
//           filled: true,
//           fillColor: Colors.grey[200],
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8.0),
//             borderSide: BorderSide.none,
//           ),
//         ),
//       );
// }
