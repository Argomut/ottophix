import 'package:flutter/material.dart';
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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Auth Demo',
      home: AuthPage(),
    );
  }
}