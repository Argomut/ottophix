import 'package:flutter/material.dart';

class Service {
  int? serviceId;
  String serviceType;
  String? serviceDescription;
  DateTime serviceDateTime;
  double? serviceCost;
  String serviceStatus;
  String? managerId;
  int? carId;

  // Constructor
  Service({
    this.serviceId,
    required this.serviceType,
    this.serviceDescription,
    required this.serviceDateTime,
    this.serviceCost,
    this.serviceStatus = 'PENDING',
    this.managerId,
    this.carId,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      serviceId: json['service_id'],
      serviceType: json['service_type'],
      serviceDescription: json['service_description'],
      serviceDateTime: DateTime.parse(json['service_datetime']),
      serviceCost: json['service_cost']?.toDouble(),
      serviceStatus: json['service_status'] ?? 'PENDING',
      managerId: json['manager_id'],
      carId: json['car_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'service_type': serviceType,
      'service_description': serviceDescription,
      'service_datetime': serviceDateTime.toString(),
      'service_cost': serviceCost,
      'service_status': serviceStatus,
      'manager_id': managerId,
      'car_id': carId,
    };
  }
}
