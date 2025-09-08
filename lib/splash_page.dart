import 'package:flutter/material.dart';
import 'package:ottophix/main.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async{
    await Future.delayed(Duration.zero);
    final session = supabase.auth.currentSession;

    if(!mounted){
      return;
    }
    if(session != null){
      Navigator.of(context).pushNamed("/account");
    }
    else{
      Navigator.of(context).pushNamed("/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
