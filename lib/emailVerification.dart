// import 'package:flutter/material.dart';
// import 'package:uni_links/uni_links.dart';  // To handle deep links
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// class EmailVerificationPage extends StatefulWidget {
//   @override
//   _EmailVerificationPageState createState() => _EmailVerificationPageState();
// }
//
// class _EmailVerificationPageState extends State<EmailVerificationPage> {
//   String statusMessage = 'Please wait while we verify your email...';
//
//   @override
//   void initState() {
//     super.initState();
//     _handleDeepLink();
//   }
//
//   // Handle deep link after email verification
//   Future<void> _handleDeepLink() async {
//     final uri = await getInitialLink();  // Get the deep link
//     if (uri != null) {
//       // Extract the information (email verification status or error)
//       final isVerified = uri.contains('success');
//       setState(() {
//         statusMessage = isVerified
//             ? '✅ Email verification successful!'
//             : '❌ Email verification failed or expired.';
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Email Verification')),
//       body: Center(child: Text(statusMessage)),
//     );
//   }
// }
