import 'package:flutter/material.dart';
import 'package:ottophix/Account.dart';
import 'package:ottophix/Car.dart';
import 'package:ottophix/Service.dart';
import 'package:ottophix/ServicePage.dart';
import 'package:ottophix/main.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;
  final String userId = supabase.auth.currentUser!.id;
  String userType = "";
  final searchCtrl = TextEditingController();

  List<Service> services = [];
  List<Service> filteredServices = [];
  List<Account> customers = [];
  List<Car> cars = [];

  final List<String> statuses = ['PENDING', 'IN_PROGRESS', 'ON_HOLD', 'REVIEWING'];
  final List<String> customerStatuses = ['PENDING', 'IN_PROGRESS', 'ON_HOLD', 'REVIEWING', 'COMPLETED'];
  List<String> selectedStatuses = ['PENDING', 'IN_PROGRESS', 'ON_HOLD', 'REVIEWING'];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);

    // Identify user
    final user = await supabase.from('account').select().eq('id', userId).single();
    userType = user['account_type'];

    List<Service> tempServiceList = [];
    List<Account> tempCustomers = [];
    List<Car> tempCars = [];

    // mechanic data
    if (userType == 'MECHANIC') {
      final serviceAssignment = await supabase
          .from('serviceassignment')
          .select()
          .eq('mechanic_id', userId);

      List<int> serviceIds = (serviceAssignment as List)
          .map((data) => data['service_id'] as int)
          .toList();

      for (var serviceId in serviceIds) {
        try {
          final response = await supabase
              .from('service')
              .select()
              .ilike('service_type', '%${searchCtrl.text}%')
              .neq('service_status', 'COMPLETED')
              .eq('service_id', serviceId)
              .order('service_datetime', ascending: true)
              .order('service_id', ascending: true)
              .maybeSingle();

          if (response != null) {
            tempServiceList.add(Service.fromJson(response));
          }
        } catch (e) {}
      }
    }

    // manager data
    else if (userType == 'MANAGER') {
      final response = await supabase
          .from('service')
          .select()
          .ilike('service_type', '%${searchCtrl.text}%')
          .neq('service_status', 'COMPLETED')
          .eq('manager_id', userId)
          .order('service_datetime', ascending: true)
          .order('service_id', ascending: true);

      for (var item in response) {
        tempServiceList.add(Service.fromJson(item));
      }
    }

    // customer data
    else if (userType == 'CUSTOMER') {
      final carResponse = await supabase
          .from('cars')
          .select()
          .eq('customer_id', userId);

      List<Car> customerCars = (carResponse as List).map((data) => Car.fromJson(data)).toList();

      for (var car in customerCars) {
        final response = await supabase
            .from('service')
            .select()
            .ilike('service_type', '%${searchCtrl.text}%')
            .neq('service_status', 'COMPLETED')
            .eq('car_id', car.carId)
            .order('service_datetime', ascending: true)
            .order('service_id', ascending: true);

        for (var item in response) {
          tempServiceList.add(Service.fromJson(item));
        }
      }
    }

    // fetch car + customer for each service
    for (var service in tempServiceList) {
      final carResponse = await supabase.from('cars').select().eq('car_id', service.carId!).single();
      Car car = Car.fromJson(carResponse);

      final customerResponse = await supabase.from('account').select().eq('id', car.customerId).single();
      Account customer = Account.fromJson(customerResponse);

      tempCars.add(car);
      tempCustomers.add(customer);
    }

    setState(() {
      services = tempServiceList;
      filteredServices = services;
      cars = tempCars;
      customers = tempCustomers;
      isLoading = false;
    });
  }

  void _updateStatus(int index, String serviceStatus) async {
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
          title: const Text('Confirm Status Change'),
          content: Text('Are you sure you want to change the status to "$serviceStatus"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateStatus(index, serviceStatus);
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
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
          title: const Text("Filter Options"),
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
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Apply"),
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

  void _applyFilters() {
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
        title: const Text("SliverList Example"),
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
                        onSubmitted: (_) => _fetchData(),
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
                      onPressed: () => _showFilterDialog(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (!isLoading && services.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text("No record of services")),
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
                        Text(service.serviceDateTime != null
                            ? DateFormat('yyyy-MM-dd').format(service.serviceDateTime!)
                            : 'No date'),
                        if(userType == "CUSTOMER")
                        Text('Service Status: ${service.serviceStatus}'),
                      ],
                    ),
                    trailing:
                      userType == 'CUSTOMER'
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[100],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: Colors.grey),
                              ),
                            ),
                            onPressed: () {
                              _showConfirmDialog(index, "COMPLETED");
                            },
                            child: Text('COMPLETE?'),
                        )
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.orange[100],
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                dropdownColor: Colors.orange[100],
                                value: service.serviceStatus,
                                icon: const Icon(Icons.arrow_drop_down),
                                onChanged: (String? serviceStatus) {
                                  if (serviceStatus != null) {
                                    _showConfirmDialog(index, serviceStatus);
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
                          ),
                    leading: Text((index + 1).toString()),
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
      floatingActionButton: userType == "MANAGER"
          ? FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("/addservice");
        },
        child: Icon(Icons.add),
      )
          : null,
    );
  }
}
