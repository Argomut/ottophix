import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ottophix/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordCtrl = TextEditingController();
  final _myFocus = FocusNode();
  final _myForm = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _invalidateResetLink();
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _myFocus.dispose();
    _signOutUser();
    super.dispose();
  }

  void _invalidateResetLink() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('resetLinkValidation', true);
  }
  void _signOutUser() async{
    await supabase.auth.signOut();
  }

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
              child: Text(
                "Enter Your New Password",
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
                    const Text(" Password:"),
                    const SizedBox(height: 6),
                    TextFormField(
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      focusNode: _myFocus,
                      inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
                      controller: _passwordCtrl,
                      decoration: const InputDecoration(
                        labelText: "Include at least 6 characters",
                        labelStyle: TextStyle(color: Colors.grey),
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
                        labelText: "Confirm your password",
                        labelStyle: TextStyle(color: Colors.grey),
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
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_myForm.currentState!.validate()) {
                    try{
                      final password = _passwordCtrl.text.trim();
                      await supabase.auth.updateUser(UserAttributes(password: password));
                      if(mounted){
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        Navigator.of(context).pushReplacementNamed('/login');

                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password Changed Successfully")));
                      }
                    }
                    catch(e){
                      print(e);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error occured, please try again. $e")));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Reset Password"),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
