import 'package:flutter/material.dart';
import 'package:ottophix/Service.dart';
import 'package:ottophix/Account.dart';
import 'package:ottophix/Car.dart';
import 'package:intl/intl.dart';
import 'TaskMain.dart';

import 'main.dart';

class ServicePage extends StatefulWidget {
  final Service service;
  final Account customer;
  final Car car;

  const ServicePage({
    Key? key,
    required this.service,
    required this.customer,
    required this.car,
  }) : super(key: key);

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  final List<String> statuses = ['PENDING', 'IN_PROGRESS', 'ON_HOLD', 'REVIEWING'];
  String userType = '';
  @override
  void initState() {
    identifyUserType();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void identifyUserType() async{
    // Identify user
    final user = await supabase.from('account').select().eq('id', supabase.auth.currentUser!.id).single();
    userType = user['account_type'];

    setState(() {
      userType = user['account_type'];
    });

    print(userType);
  }
  void _updateStatus(String serviceStatus) async{
    setState(() {
      widget.service.serviceStatus = serviceStatus;
    });

    await supabase.from('service')
        .update({'service_status': serviceStatus})
        .eq('service_id', widget.service.serviceId.toString());
  }

  Future<void> _showConfirmDialog(String serviceStatus) async {
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
                _updateStatus(serviceStatus);
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Service Details"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer Info',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('Customer ID: ${widget.customer.id}'),
                  Text('Name: ${widget.customer.username}'),
                  Text('Phone: ${widget.customer.phoneNumber}'),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Car Info',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('Car ID: ${widget.car.carId}'),
                  Text('Make: ${widget.car.carMake}'),
                  Text('Model: ${widget.car.carModel}'),
                  Text('Color: ${widget.car.color}'),
                  Text('Year: ${widget.car.carYear}'),
                  Text('Vin Number: ${widget.car.vinNumber}'),
                  Text('Licence plate: ${widget.car.licencePlate}'),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service Info',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('Service ID: ${widget.service.serviceId}'),
                  Text('Service Type: ${widget.service.serviceType}'),
                  Text('Service Date: ${DateFormat('yyyy-MM-dd').format(widget.service.serviceDateTime)}'),
                  Text('Service Cost: RM${widget.service.serviceCost}'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (widget.service.serviceStatus != 'COMPLETED' && userType == "CUSTOMER")
                        Text('Service Status: (${widget.service.serviceStatus})')
                      else
                        const Text('Service Status:'),
                      const SizedBox(width: 10),

                      if (widget.service.serviceStatus != 'COMPLETED' && userType == "CUSTOMER")
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Colors.grey),
                            ),
                          ),
                          onPressed: () {
                            _showConfirmDialog("COMPLETED");
                          },
                          child: const Text('COMPLETE?'),
                        )

                      else if (widget.service.serviceStatus != 'COMPLETED')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.orange[100],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: widget.service.serviceStatus,
                              icon: const Icon(Icons.arrow_drop_down),
                              dropdownColor: Colors.orange[100],
                              onChanged: (String? serviceStatus) {
                                if (serviceStatus != null) {
                                  _showConfirmDialog(serviceStatus);
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
                        )

                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.lightGreen,
                          ),
                          child: const Text(
                            'COMPLETED',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Service Description:'),
                  Text(widget.service.serviceDescription.toString()),
                  const SizedBox(height: 16),
                  // Task Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TaskMain(
                              title: 'Tasks for Service ${widget.service.serviceId}',
                              serviceId: widget.service.serviceId,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.task_alt, color: Colors.white),
                      label: const Text('View Tasks', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC9C0E2),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

