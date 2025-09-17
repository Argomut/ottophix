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
import 'package:app_links/app_links.dart';
import 'package:shared_preferences/shared_preferences.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://sxdkvlxdrzebaaqljart.supabase.co',
    anonKey: 'sb_secret_ybsbpEyZ2lCMZxIR9qwVbA_qZsjfWyR',
  );
  runApp(MyApp());
}

final supabase = Supabase.instance.client;
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget{
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>{
  // String? _deeplink;
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  void _initDeepLinkListener() async {

    // final initialLink = await getInitialLink();
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink);
    }

    // linkStream.listen((link){
    _appLinks.uriLinkStream.listen((Uri? link) async{
      if (link != null) {
        _handleDeepLink(link);
      }
    });
  }

  void _handleDeepLink(Uri link) async {
    final prefs = await SharedPreferences.getInstance();
    bool _hasHandledDeepLink = prefs.getBool('resetLinkValidation') ?? false;

    print("Received deep link: ${link.toString()}");
    if (link.toString().contains('login-callback/')) {
      _navigatorKey.currentState?.pushReplacementNamed("/login");
    } else if (link.toString().contains('reset-callback/') && !_hasHandledDeepLink) {
      _navigatorKey.currentState?.pushNamed('/resetpassword');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Supabase Auth Demo',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true
      ),

      initialRoute: '/search',

      routes: {
        '/': (context) => const SplashPage(),
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