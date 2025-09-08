import 'package:flutter/material.dart';
import 'package:ottophix/main.dart';

import 'Avatar.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final _usernameCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();

  String? _avatarUrl;


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
      _avatarUrl = data["avatar_url"];
    });
  }

  Future<void> _onUpload(String imageUrl) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('profiles').upsert({
        'id': userId,
        'avatar_url': imageUrl,
      });
      if (mounted) {
        const SnackBar(
          content: Text('Updated your profile image!'),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Unexpected error occurred")));
      }
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _avatarUrl = imageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account"),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          Avatar(
            imageUrl: _avatarUrl,
            onUpload: _onUpload,
          ),
          const SizedBox(height: 18),
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
