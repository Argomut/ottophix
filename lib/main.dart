import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'SignUpPage.dart';
import 'LoginPage.dart';
import 'AccountPage.dart';
import 'ForgotPasswordPage.dart';
import 'ResetPasswordPage.dart';
import 'NavigationPage.dart';
import 'searchPage.dart';
import 'detailPage.dart';
import 'cartPage.dart';
import 'SplashPage.dart';
import 'models/item.dart';
import 'package:app_links/app_links.dart';
import 'package:shared_preferences/shared_preferences.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://uldfsedlhouyilbofeqv.supabase.co',      // Replace with your Supabase URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVsZGZzZWRsaG91eWlsYm9mZXF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgyMjQwMjksImV4cCI6MjA3MzgwMDAyOX0.8mIxMnkzh2rZu0r9e-M-TvuEZihVVJ2tHA83TNhGN0o',                     // Replace with your public anon key
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
    bool _hasHandledLoginLink = prefs.getBool('loginLinkValidation') ?? false;
    bool _hasHandledResetLink = prefs.getBool('resetLinkValidation') ?? false;



    print("Received deep link: ${link.toString()}");
    if (link.toString().contains('login-callback/') && !_hasHandledLoginLink) {
      _navigatorKey.currentState?.pushReplacementNamed("/login");
    } else if (link.toString().contains('reset-callback/') && !_hasHandledResetLink) {
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

      initialRoute: '/',

      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/account': (context) => const AccountPage(),
        '/forgotpassword': (context) => const ForgotPasswordPage(),
        '/resetpassword': (context) => const ResetPasswordPage(),
        '/navigation': (context) => const NavigationPage(),
        '/search': (context) => const SearchPage(),
        '/cart': (context) => const CartPage(),
      },
    );
  }
}
