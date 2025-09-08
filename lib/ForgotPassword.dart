import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ottophix/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailCtrl = TextEditingController();
  final _myFocus = FocusNode();
  final _myForm = GlobalKey<FormState>();
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    // handleIncomingLinks(context);
    super.initState();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _myFocus.dispose();
    _authSubscription.cancel();
    super.dispose();
  }

  // void handleIncomingLinks(BuildContext context) {
  //   uriLinkStream.listen((Uri? uri) {
  //     if (uri != null &&
  //         uri.scheme == 'io.supabase.flutterquickstart' &&
  //         uri.host == 'login-callback' &&
  //         uri.path == '/reset') {
  //       Navigator.of(context).pushNamed('/resetpassword');
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const Center(
              child: Column(
                children: [
                  Text(
                    "Forgot Password?",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Please enter your email to receive a link to reset your password",
                  ),
                ]
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Form(
                key: _myForm,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(" Email:"),
                    const SizedBox(height: 6),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
                      controller: _emailCtrl,
                      focusNode: _myFocus,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length < 2) {
                          return "Please enter username";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_myForm.currentState!.validate()) {
                    try{
                      final email = _emailCtrl.text.trim();
                      await supabase.auth.resetPasswordForEmail(
                        email,
                        redirectTo: 'io.supabase.flutterquickstart://login-callback/reset',
                      );
                      if(mounted){
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Check your inbox")));
                      }
                    }
                    catch(e){
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error occured, please try again.")));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Send Link"),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}



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
