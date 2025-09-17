import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ottophix/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailCtrl = TextEditingController();
  final _myFocus = FocusNode();
  final _myForm = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _myFocus.dispose();
    super.dispose();
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
                          return "Please enter email";
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
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('resetLinkValidation', false);
                      await supabase.auth.resetPasswordForEmail(
                        email,
                        redirectTo: 'io.supabase.flutterquickstart://reset-callback/',
                      );
                      if(mounted){
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Check your inbox")));
                      }
                    }
                    catch(e){
                      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("Error occured, please try again. $e")));
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