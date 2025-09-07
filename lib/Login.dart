import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ottophix/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = supabase.auth.onAuthStateChange.listen((event){
      final session = event.session;
      if(session != null){
        Navigator.of(context).pushReplacementNamed("/account");
      }
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'),),
      body: ListView(
        children: [
          TextFormField(
            controller: _emailCtrl,
            decoration: InputDecoration(
              label: Text("email")
            ),
          ),
          ElevatedButton(
              onPressed: () async{
                try{
                  final email = _emailCtrl.text.trim();
                  await supabase.auth.signInWithOtp(
                    email: email,
                    emailRedirectTo: 'io.supabase.flutterquickstart://login-callback/',
                  );
                  if(mounted){
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Check your inbox")));
                  }
                }
                catch(e){
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error occurred, please try again")));
                }

              },
              child: const Text("Login")
          )
        ],
      ),
    );
  }
}
