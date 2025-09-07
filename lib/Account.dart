import 'package:flutter/material.dart';
import 'package:ottophix/main.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final _usernameCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getInitialProfile();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  Future<void> _getInitialProfile() async{
    final userId = supabase.auth.currentUser!.id;
    final data = await supabase.from('profiles').select().eq('id', userId).single();
    setState(() {
      _usernameCtrl.text = data["username"];
      _websiteCtrl.text = data["website"];
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Account"),),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          TextFormField(
            controller: _usernameCtrl,
            decoration: const InputDecoration(
              label: Text("Username")
            ),
          ),
          const SizedBox(height: 12,),
          TextFormField(
            controller: _websiteCtrl,
            decoration: const InputDecoration(
                label: Text("Website")
            ),
          ),
          const SizedBox(height: 12,),
          ElevatedButton(
              onPressed: () async {
                final username = _usernameCtrl.text.trim();
                final website = _websiteCtrl.text.trim();
                final userId = supabase.auth.currentUser!.id;

                await supabase.from('profiles').update({
                  'username': username,
                  'website': website,
                }).eq('id', userId);
                if(mounted){
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account Updated")));
                }
                else{
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed")));
                }
              },
              child: Text("Save")
          ),
          ElevatedButton(
              onPressed: () async {
                await supabase.auth.signOut();
                if(mounted){
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Logged out")));
                  Navigator.of(context).pushReplacementNamed("/");
                }
              },
              child: Text("Log out")
          ),
        ],
      ),
    );
  }
}
