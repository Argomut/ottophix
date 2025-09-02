import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final supabase = Supabase.instance.client;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String statusMessage = '';

  Future<void> signUp() async {
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      setState(() {
        statusMessage = '✅ Signed up! Please check your email.';
      });
    } catch (error) {
      setState(() {
        statusMessage = '❌ Sign up failed: $error';
      });
    }
  }

  Future<void> signIn() async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      setState(() {
        statusMessage = '✅ Signed in as ${response.user?.email}';
      });
    } catch (error) {
      setState(() {
        statusMessage = '❌ Sign in failed: $error';
      });
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    setState(() {
      statusMessage = '👋 Signed out';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Supabase Auth')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: signUp, child: Text('Sign Up')),
            ElevatedButton(onPressed: signIn, child: Text('Sign In')),
            ElevatedButton(onPressed: signOut, child: Text('Sign Out')),
            SizedBox(height: 20),
            Text(statusMessage),
          ],
        ),
      ),
    );
  }
}