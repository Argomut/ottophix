import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ottophix/DatabaseService.dart';

import 'main.dart';

class AddServicePage extends StatefulWidget {
  const AddServicePage({super.key});

  @override
  State<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  bool _isLoading = false;
  final TextEditingController _carIdCtrl = TextEditingController();
  final TextEditingController _serviceTypeCtrl = TextEditingController();
  final TextEditingController _serviceDescriptionCtrl = TextEditingController();
  final TextEditingController _serviceCostCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> mechanics = [];
  Set<String> selectedMechanicIds = {};

  @override
  void initState() {
    _loadDraft();
    _loadMechanics();
    super.initState();
  }

  @override
  void dispose() {
    _carIdCtrl.dispose();
    _serviceTypeCtrl.dispose();
    _serviceDescriptionCtrl.dispose();
    _serviceCostCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDraft() async {
    _isLoading = true;
    final draft = await DatabaseService.getDraft();
    if (draft != null) {
      _carIdCtrl.text = draft['car_id'] ?? '';
      _serviceTypeCtrl.text = draft['service_type'] ?? '';
      _serviceDescriptionCtrl.text = draft['service_description'] ?? '';
      _serviceCostCtrl.text = draft['service_cost'] ?? '';
      selectedMechanicIds = Set<String>.from(
        (draft['mechanic_ids'] as String?)?.split(',') ?? [],
      );
    }
    _isLoading = false;
  }

  Future<void> _loadMechanics() async {
    _isLoading = true;
    final response = await Supabase.instance.client
        .from('account')
        .select('id, username')
        .eq('account_type', 'MECHANIC');

    setState(() {
      mechanics = List<Map<String, dynamic>>.from(response);
    });
    _isLoading = false;
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final carId = int.tryParse(_carIdCtrl.text.trim());
    final serviceType = _serviceTypeCtrl.text.trim();
    final serviceDescription = _serviceDescriptionCtrl.text.trim();
    final serviceCost = double.tryParse(_serviceCostCtrl.text.trim());

    _isLoading = true;
    try {
      final insertResponse = await Supabase.instance.client
          .from('service')
          .insert({
            'car_id': carId,
            'service_type': serviceType,
            'service_description': serviceDescription,
            'service_cost': serviceCost,
            'manager_id': supabase.auth.currentUser!.id
          })
          .select()
          .single();

      final int serviceId = insertResponse['service_id'];

      final validMechanicIds = selectedMechanicIds.where((id) => id.isNotEmpty).toList();

      final assignments = validMechanicIds.map((id) => {
        'mechanic_id': id,
        'service_id': serviceId,
      }).toList();

      await Supabase.instance.client
          .from('serviceassignment')
          .insert(assignments);

      await DatabaseService.clearDraft();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Service created successfully.")),
      );
      _isLoading = false;
      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error occurred: $e")),
      );
      print(e);
    }
  }

  Future<bool> _saveDraft() async {
    _isLoading = true;
    final draftData = {
      'car_id': _carIdCtrl.text.trim(),
      'service_type': _serviceTypeCtrl.text.trim(),
      'service_description': _serviceDescriptionCtrl.text.trim(),
      'service_cost': _serviceCostCtrl.text.trim(),
      'mechanic_ids': selectedMechanicIds.join(','),
    };

    await DatabaseService.saveDraft(draftData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Draft saved locally.")),
    );
    _isLoading = false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Service"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            await _saveDraft();
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("Car ID:"),
              const SizedBox(height: 6),
              TextFormField(
                controller: _carIdCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: "e.g. 1",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Please enter car ID" : null,
              ),
              const SizedBox(height: 12),

              const Text("Service Type:"),
              const SizedBox(height: 6),
              TextFormField(
                controller: _serviceTypeCtrl,
                decoration: InputDecoration(
                  labelText: "e.g. Oil Change",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Please enter service type" : null,
              ),
              const SizedBox(height: 12),

              const Text("Service Description:"),
              const SizedBox(height: 6),
              TextFormField(
                controller: _serviceDescriptionCtrl,
                decoration: InputDecoration(
                  labelText: "e.g. Replace the oil",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Please enter description" : null,
              ),
              const SizedBox(height: 12),

              const Text("Service Cost:"),
              const SizedBox(height: 6),
              TextFormField(
                controller: _serviceCostCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: InputDecoration(
                  labelText: "e.g. 200",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Please enter cost" : null,
              ),

              const SizedBox(height: 20),
              const Divider(),
              const Text("Assign Mechanics:"),
              const SizedBox(height: 6),

              if (_isLoading)
                Center(child: CircularProgressIndicator())
              else if (mechanics.isEmpty && !_isLoading)
                Center(child: Text("No mechanics available"))
              else
                ...mechanics.map((mech) {
                  final String id = mech['id'];
                  final String name = mech['username'] ?? 'Unknown';
                  return CheckboxListTile(
                    value: selectedMechanicIds.contains(id),
                    title: Text(name),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          selectedMechanicIds.add(id);
                        } else {
                          selectedMechanicIds.remove(id);
                        }
                      });
                    },
                  );
                }).toList(),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text("Add Service"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


