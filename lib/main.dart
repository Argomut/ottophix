import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'SignUp.dart';
import 'Login.dart';
import 'Account.dart';
import 'ForgotPassword.dart';
import 'ResetPassword.dart';
import 'AuthPage.dart';

import 'searchPage.dart';
import 'detailPage.dart';
import 'cartPage.dart';
import 'models/item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ksmbdudooaanksgyuljg.supabase.co',
    anonKey: 'sb_secret_xDmSdbqFMCC5lrdXfDwoIA_qBFmqDr6',
  );
  runApp(MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ottophix Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),

      initialRoute: '/search',

      routes: {
        '/': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/account': (context) => const Account(),
        '/forgotpassword': (context) => const ForgotPasswordPage(),
        '/resetpassword': (context) => const ResetPasswordPage(),

        '/search': (context) => const SearchPage(),
        '/cart': (context) => const CartPage(),
      },
    );
  }
}