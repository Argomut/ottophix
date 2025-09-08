import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ottophix/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _myFocus = FocusNode();
  final _myForm = GlobalKey<FormState>();
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = supabase.auth.onAuthStateChange.listen((event){
      final session = event.session;
      if(session != null){
        Navigator.of(context).pushNamed("/account");
      }
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _myFocus.dispose();
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const Center(
                child: Text(
                  "Welcome Back!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                        if (value == null || value.isEmpty || value.length < 2) {
                          return "Please enter password";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed('/forgotpassword');
                          },
                          child: const Text(
                            "Forgot password? ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold
                            ),
                          ),
                      ),
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
                      final password = _passwordCtrl.text.trim();
                      await supabase.auth.signInWithPassword(
                          email: email,
                          password: password
                      );
                      if(mounted){
                        Navigator.of(context).pushNamed('/account');
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
                child: const Text("Sign In"),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/signup');
                  },
                  child: const Text(
                    "Sign up",
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

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Login'),
  //       automaticallyImplyLeading: false,
  //     ),
  //     body: ListView(
  //       children: [
  //         TextFormField(
  //           controller: _emailCtrl,
  //           decoration: InputDecoration(
  //             label: Text("email")
  //           ),
  //         ),
  //         ElevatedButton(
  //             onPressed: () async{
  //               try{
  //                 final email = _emailCtrl.text.trim();
  //                 await supabase.auth.signInWithOtp(
  //                   email: email,
  //                   emailRedirectTo: 'io.supabase.flutterquickstart://login-callback/',
  //                 );
  //                 if(mounted){
  //                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Check your inbox")));
  //                 }
  //               }
  //               catch(e){
  //                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error occurred, please try again")));
  //               }
  //
  //             },
  //             child: const Text("Login")
  //         )
  //       ],
  //     ),
  //   );
  // }
}
