// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// import 'ForgotPassword.dart';
//
// class AuthPage extends StatefulWidget {
//   @override
//   _AuthPageState createState() => _AuthPageState();
// }
//
// class _AuthPageState extends State<AuthPage> {
//   final supabase = Supabase.instance.client;
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   String statusMessage = '';
//   bool isLoading = false;
//
//   // Sign up function
//   Future<void> signUp() async {
//     if (emailController.text.isEmpty || passwordController.text.isEmpty) {
//       setState(() {
//         statusMessage = '❌ Please fill in all fields.';
//       });
//       return;
//     }
//     setState(() {
//       isLoading = true;
//     });
//
//     try {
//       final email = emailController.text.trim();
//       final password = passwordController.text.trim();
//
//       final response = await supabase.auth.signUp(
//         email: email,
//         password: password,
//         emailRedirectTo: 'io.supabase.flutterquickstart://login-callback/', // This is the URL that will be handled by your app
//       );
//
//       setState(() {
//         statusMessage = '✅ Signed up! Please check your email for verification.';
//       });
//     } catch (error) {
//       setState(() {
//         statusMessage = '❌ Sign up failed: $error';
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//
//   // Sign in function
//   Future<void> signIn() async {
//     if (emailController.text.isEmpty || passwordController.text.isEmpty) {
//       setState(() {
//         statusMessage = '❌ Please fill in all fields.';
//       });
//       return;
//     }
//     setState(() {
//       isLoading = true;
//     });
//
//     try {
//       final response = await supabase.auth.signInWithPassword(
//         email: emailController.text.trim(),
//         password: passwordController.text.trim(),
//       );
//
//       setState(() {
//         statusMessage = '✅ Signed in as ${response.user?.email}';
//       });
//     } catch (error) {
//       setState(() {
//         statusMessage = '❌ Sign in failed: $error';
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   // Sign out function
//   Future<void> signOut() async {
//     await supabase.auth.signOut();
//     setState(() {
//       statusMessage = '👋 Signed out';
//     });
//   }
//
//   // Forgot password function
//   Future<void> forgotPassword() async {
//     if (emailController.text.isEmpty) {
//       setState(() {
//         statusMessage = '❌ Please enter your email address.';
//       });
//       return;
//     }
//
//     setState(() {
//       isLoading = true;
//     });
//
//     try {
//       final response = await supabase.auth.resetPasswordForEmail(emailController.text.trim());
//       setState(() {
//         statusMessage = '✅ Password reset email sent!';
//       });
//
//       // Assuming the link in the reset email contains the token
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ForgotPasswordPage(),
//         ),
//       );
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
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Supabase Auth')),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             TextField(
//               controller: emailController,
//               decoration: InputDecoration(labelText: 'Email'),
//               keyboardType: TextInputType.emailAddress,
//             ),
//             TextField(
//               controller: passwordController,
//               decoration: InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: isLoading ? null : signUp,
//               child: isLoading
//                   ? CircularProgressIndicator()
//                   : Text('Sign Up'),
//             ),
//             ElevatedButton(
//               onPressed: isLoading ? null : signIn,
//               child: isLoading
//                   ? CircularProgressIndicator()
//                   : Text('Sign In'),
//             ),
//             ElevatedButton(
//               onPressed: isLoading ? null : signOut,
//               child: isLoading
//                   ? CircularProgressIndicator()
//                   : Text('Sign Out'),
//             ),
//             SizedBox(height: 20),
//             TextButton(
//               onPressed: isLoading ? null : forgotPassword,
//               child: Text('Forgot Password?'),
//             ),
//             SizedBox(height: 20),
//             Text(statusMessage),
//           ],
//         ),
//       ),
//     );
//   }
// }
