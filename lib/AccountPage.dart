import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ottophix/main.dart';

import 'Avatar.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _userIdCtrl = TextEditingController();
  final _userEmailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  final _myForm = GlobalKey<FormState>();

  final _userId = supabase.auth.currentUser!.id;
  final _userEmail = supabase.auth.currentUser!.email;
  final _createdAt = supabase.auth.currentUser!.createdAt;

  String _initialUsername = '';
  String _initialPhone = '';
  String? _accountType;
  String? _avatarUrl;

  bool _isUsernameEdited = false;
  bool _isPhoneEdited = false;
  @override
  void initState() {
    super.initState();
    _getInitialProfile();
  }

  @override
  void dispose() {
    _userIdCtrl.dispose();
    _userEmailCtrl.dispose();
    _usernameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _getInitialProfile() async{
    _userIdCtrl.text = _userId.toString();
    _userEmailCtrl.text = _userEmail.toString();
    final data = await supabase.from('account').select().eq('id', _userId).single();
    setState(() {
      _usernameCtrl.text = data["username"];
      _initialUsername = data["username"];
      _phoneCtrl.text = data["phone_number"];
      _initialPhone = data["phone_number"];
      _avatarUrl = data["profile_picture_url"];
      _accountType = data["account_type"];
    });
    _usernameCtrl.addListener(() {
      setState(() {
        _isUsernameEdited = _usernameCtrl.text != _initialUsername;
      });
    });
    _phoneCtrl.addListener(() {
      setState(() {
        _isPhoneEdited = _phoneCtrl.text != _initialPhone;
      });
    });
  }

  Future<void> _onUpload(String imageUrl) async {
    try {
      await supabase.from('account').upsert({
        'id': _userId,
        'profile_picture_url': imageUrl,
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
        title: Text("$_accountType ACCOUNT"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
            children: [
            Avatar(
              imageUrl: _avatarUrl,
              onUpload: _onUpload,
            ),
            const SizedBox(height: 18),

            Expanded(
                child: SingleChildScrollView(
                    child: Form(
                        key: _myForm,
                        child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 32,
                                child: Text("User ID: $_userId", textAlign: TextAlign.left, ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 32,
                                child: Text("Email: $_userEmail", textAlign: TextAlign.left,),
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 32,
                                child: Text("Account Created at: $_createdAt", textAlign: TextAlign.left,),
                              ),
                              TextFormField(
                                controller: _usernameCtrl,
                                keyboardType: TextInputType.text,
                                inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
                                decoration: const InputDecoration(
                                  label: Text("Username"),
                                  labelStyle: TextStyle(color: Colors.black87),
                                  fillColor: Colors.black12,
                                  filled: true,
                                ),
                                style: TextStyle(color: Colors.black87),
                              ),
                              const SizedBox(height: 12,),

                              TextFormField(
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\+?[0-9 ]*$')),],
                                decoration: const InputDecoration(
                                  label: Text("Phone No."),
                                  labelStyle: TextStyle(color: Colors.black87),
                                  fillColor: Colors.black12,
                                  filled: true,
                                ),
                                style: TextStyle(color: Colors.black87),
                              ),
                            ]
                        )
                    )
                )
            ),
            const SizedBox(height: 16),
              if (_isUsernameEdited || _isPhoneEdited) SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () async {
                    final username = _usernameCtrl.text.trim();
                    final phone = _phoneCtrl.text.trim();

                    //And the current text is not equal to initial value
                    if(username != "" && username.isNotEmpty && phone != "" && phone.isNotEmpty){
                      await supabase.from('account').update({
                        'username': username,
                        'phone_number': phone,
                      }).eq('id', _userId);
                    }

                    else if(username != "" && username.isNotEmpty){
                      await supabase.from('account').update({
                        'username': username,
                      }).eq('id', _userId);
                    }

                    else if (phone != "" && phone.isNotEmpty){
                      await supabase.from('account').update({
                        'phone_number': phone,
                      }).eq('id', _userId);
                    }
                    setState(() {
                      _getInitialProfile();
                    });
                    _isUsernameEdited = false;
                    _isPhoneEdited = false;
                    _initialUsername = _usernameCtrl.text.trim();
                    _initialPhone = _phoneCtrl.text.trim();
                    if(mounted){
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account Updated")));
                    }
                    else{
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed")));
                    }
                  },
                  child: Text("Save")
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () async {
                    await supabase.auth.signOut();
                    if(mounted){
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Logged out")));
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  },
                  child: Text("Log out")
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
