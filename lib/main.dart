import 'package:flutter/material.dart';
import 'package:ottophix/Account.dart';
import 'package:ottophix/ForgotPassword.dart';
import 'package:ottophix/Login.dart';
import 'package:ottophix/ResetPassword.dart';
import 'package:ottophix/SignUp.dart';
import 'package:ottophix/splash_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'AuthPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://sxdkvlxdrzebaaqljart.supabase.co',      // Replace with your Supabase URL
    anonKey: 'sb_secret_ybsbpEyZ2lCMZxIR9qwVbA_qZsjfWyR',                     // Replace with your public anon key
  );
  runApp(MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Auth Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/account': (context) => const Account(),
        '/forgotpassword': (context) => const ForgotPasswordPage(),
        '/resetpassword': (context) => const ResetPasswordPage(),
      },
      // home: AuthPage(),
    );
    
  }
}