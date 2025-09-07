// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';  // Make sure to import Supabase
// import 'package:uni_links/uni_links.dart';
//
// class ForgotPasswordPage extends StatefulWidget {
//   late final String? token;  // Token from the reset URL
//
//   ForgotPasswordPage({this.token});
//
//   @override
//   _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
// }
//
// class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
//   final newPasswordController = TextEditingController();
//   String statusMessage = '';
//   bool isLoading = false;
//
//   final supabase = Supabase.instance.client;
//
//   // Inside your ForgotPasswordPage, listen to deep links and extract the token
//   @override
//   void initState() {
//     super.initState();
//     _handleDeepLink(); // Call the deep link handler when the page loads
//   }
//
//   // Handle deep link to extract token
//   void _handleDeepLink() async {
//     final Uri? initialUri = (await getInitialLink()) as Uri?;  // Get the deep link
//     if (initialUri != null) {
//       final token = initialUri.queryParameters['token']; // Extract token from the URL
//       if (token != null && widget.token == null) {
//         // If token is passed through the URL and widget.token is null, update the state
//         setState(() {
//           widget.token = token;
//         });
//       }
//     }
//   }
//
//   // Reset password function using the token
//   Future<void> resetPassword() async {
//     if (newPasswordController.text.isEmpty) {
//       setState(() {
//         statusMessage = '❌ Please enter a new password.';
//       });
//       return;
//     }
//
//     setState(() {
//       isLoading = true;
//     });
//
//     try {
//       // Use the token to reset the password
//       final response = await supabase.auth.resetPasswordForEmail(
//         UserAttributes(password: newPasswordController.text) as String
//       );
//
//       setState(() {
//         statusMessage = '✅ Password reset successful!';
//       });
//     } catch (error) {
//       setState(() {
//         statusMessage = '❌ Password reset failed: $error';
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Reset Password')),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             TextField(
//               controller: newPasswordController,
//               decoration: InputDecoration(labelText: 'New Password'),
//               obscureText: true,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: isLoading ? null : resetPassword,
//               child: isLoading
//                   ? CircularProgressIndicator()
//                   : Text('Reset Password'),
//             ),
//             SizedBox(height: 20),
//             Text(statusMessage),
//           ],
//         ),
//       ),
//     );
//   }
// }
