import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 你们原本的页面
import 'SignUp.dart';
import 'Login.dart';
import 'Account.dart';
import 'ForgotPassword.dart';
import 'ResetPassword.dart';
import 'AuthPage.dart';

// 你写的新页面
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

      // 🔹 临时测试你的模块，直接进入 SearchPage
      initialRoute: '/search',

      routes: {
        // 原有的路由
        '/': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/account': (context) => const Account(),
        '/forgotpassword': (context) => const ForgotPasswordPage(),
        '/resetpassword': (context) => const ResetPasswordPage(),

        // 你的新页面路由
        '/search': (context) => const SearchPage(),
        // 这里 /detail 不放默认 Item，等你在代码里用 Navigator.push 传参数
        '/cart': (context) => const CartPage(),
      },
    );
  }
}