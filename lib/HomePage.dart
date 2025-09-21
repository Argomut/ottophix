import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:ottophix/Account.dart';
import 'package:ottophix/Car.dart';
import 'package:ottophix/Service.dart';
import 'package:ottophix/ServicePage.dart';
import 'package:ottophix/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import 'ServiceAssignment.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;
  final searchCtrl = TextEditingController();

  List<Service> services = [];
  List<Service> filteredServices = [];
  List<Account> customers = [];
  List<Car> cars = [];

  final List<String> statuses = ['PENDING', 'IN_PROGRESS', 'ON_HOLD', 'REVIEWING'];
  List<String> selectedStatuses = ['PENDING', 'IN_PROGRESS', 'ON_HOLD', 'REVIEWING'];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    isLoading = true;
    final serviceAssignment = await supabase
        .from('serviceassignment')
        .select().eq('mechanic_id', supabase.auth.currentUser!.id);

    List<int> serviceIds = (serviceAssignment as List)
        .map((serviceAssignmentData) => serviceAssignmentData['service_id'] as int)
        .toList();

    List<Service> tempServiceList = [];

    for (var serviceId in serviceIds) {
      try {
        final response = await supabase
            .from('service')
            .select()
            .ilike('service_type','%${searchCtrl.text}%')
            .neq('service_status', 'COMPLETED')
            .eq('service_id', serviceId)
            .order('service_datetime', ascending: true)
            .order('service_id', ascending: true)
            .single();

          tempServiceList.add(Service.fromJson(response));
      }
      catch (e) {}
    }

    for (var service in tempServiceList) {
      final carResponse = await supabase
          .from('cars')
          .select()
          .eq('car_id', service.carId!)
          .single();
      Car car = Car.fromJson(carResponse);

      final customerResponse = await supabase
          .from('account')
          .select()
          .eq('id', car.customerId)
          .single();
      Account customer = Account.fromJson(customerResponse);


      setState(() {
        customers.add(customer);
        cars.add(car);
      });
    }

    setState(() {
      services = tempServiceList;
      filteredServices = services;
    });
    isLoading = false;
  }

  void _updateStatus(int index, String serviceStatus) async{
    setState(() {
      services[index].serviceStatus = serviceStatus;
    });

    await supabase.from('service')
        .update({'service_status': serviceStatus})
        .eq('service_id', services[index].serviceId.toString());
  }

  Future<void> _showConfirmDialog(int index, String serviceStatus) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Status Change'),
          content: Text('Are you sure you want to change the status to "$serviceStatus"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateStatus(index, serviceStatus);
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Filter Options"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: statuses.map((String status) {
                  return CheckboxListTile(
                    title: Text(status),
                    value: selectedStatuses.contains(status),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedStatuses.add(status);
                        } else {
                          selectedStatuses.remove(status);
                        }
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Apply"),
              onPressed: () {
                _applyFilters();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// Method to apply the filter logic
  void _applyFilters() {
    // Filter services based on selectedStatuses
    setState(() {
      filteredServices = services.where((service) {
        return selectedStatuses.contains(service.serviceStatus);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SliverList Example"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            floating: true,
            pinned: true,
            collapsedHeight: 80,
            expandedHeight: 80,
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchCtrl,
                        onSubmitted: (String searchkey){
                          _fetchData();
                        },
                        decoration: InputDecoration(
                          hintText: "Search...",
                          prefixIcon: GestureDetector(
                            onTap: _fetchData,
                            child: const Icon(Icons.search),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.black54),
                      onPressed: () {
                        _showFilterDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if(!isLoading && services.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text("No record of services"),
              ),
            )
          else
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                final service = filteredServices[index];
                final car = cars[index];
                final customer = customers[index];

                return ListTile(
                  title: Text(service.serviceType),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.serviceDescription ?? 'No description'),
                      Text(DateFormat('yyyy-MM-dd').format(service.serviceDateTime) ?? 'No description'),
                    ],
                  ),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.orange[100],
                    ),
                    child: DropdownButton<String>(
                      dropdownColor: Colors.orange[100],
                      value: service.serviceStatus,
                      icon: Icon(Icons.arrow_drop_down),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          _showConfirmDialog(index, newValue);
                        }
                      },
                      items: statuses.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  leading: Text((index+1).toString()),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServicePage(
                          service: service,
                          customer: customer,
                          car: car,
                        ),
                      ),
                    );
                  },
                );
              },
              childCount: filteredServices.length,
            ),
          ),
        ],
      ),
    );
  }
}
