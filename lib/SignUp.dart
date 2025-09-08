import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ottophix/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _myFocus = FocusNode();
  final _myForm = GlobalKey<FormState>();
  
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _authSubscription.cancel();
    _myFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const Center(
              child: Column(
                children: [
                  Text(
                    "Create Your Account",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Welcome to OttoPhix",
                  ),
                ],
              )
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _myForm,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(" Username:"),
                      const SizedBox(height: 6),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
                        controller: _usernameCtrl,
                        focusNode: _myFocus,
                        decoration: const InputDecoration(
                          labelText: "Username",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter username";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      const Text(" Email:"),
                      const SizedBox(height: 6),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
                        controller: _emailCtrl,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      const Text(" Phone No.:"),
                      const SizedBox(height: 6),
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-]')),],
                        controller: _phoneCtrl,
                        decoration: const InputDecoration(
                          labelText: "Phone No.",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your phone number";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      const Text(" Password:"),
                      const SizedBox(height: 6),
                      TextFormField(
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
                        controller: _passwordCtrl,
                        decoration: const InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter password";
                          }
                          else if(value.length < 6){
                            return "Please enter password with at least 6 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      const Text(" Confirm Password:"),
                      const SizedBox(height: 6),
                      TextFormField(
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
                        decoration: const InputDecoration(
                          labelText: "Confirm Password",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please confirm your password";
                          } else if (value != _passwordCtrl.text) {
                            return "Passwords don't match";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              )
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_myForm.currentState!.validate()) {
                    try{
                      final email = _emailCtrl.text.trim();
                      final phone = _phoneCtrl.text.trim();
                      final password = _passwordCtrl.text.trim();
                      final username = _usernameCtrl.text.trim();

                      await supabase.auth.signUp(
                        email: email,
                        password: password,
                        // phone: phone,
                        data: {
                          'username': username, // custom metadata field
                        },
                        emailRedirectTo:'io.supabase.flutterquickstart://login-callback/',
                      );
                      if(mounted){
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Check your inbox")));
                        Navigator.of(context).pushReplacementNamed('/login');
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
                child: const Text("Sign Up"),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: const Text(
                    "Sign in",
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
