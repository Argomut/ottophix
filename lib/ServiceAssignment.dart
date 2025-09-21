import 'package:flutter/material.dart';

class ServiceAssignment {
  final int assignmentId;
  final DateTime assignmentDatetime;
  final int serviceId;
  final String mechanicId;

  ServiceAssignment({
    required this.assignmentId,
    required this.assignmentDatetime,
    required this.serviceId,
    required this.mechanicId,
  });

  factory ServiceAssignment.fromJson(Map<String, dynamic> json) {
    return ServiceAssignment(
      assignmentId: json['assignment_id'],
      assignmentDatetime: DateTime.parse(json['assignment_datetime']),
      serviceId: json['service_id'],
      mechanicId: json['mechanic_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignment_id': assignmentId,
      'assignment_datetime': assignmentDatetime.toIso8601String(),
      'service_id': serviceId,
      'mechanic_id': mechanicId,
    };
  }

  // Optional: Override toString for easier debugging and logging
  @override
  String toString() {
    return 'ServiceAssignment(assignmentId: $assignmentId, assignmentDatetime: $assignmentDatetime, serviceId: $serviceId, mechanicId: $mechanicId)';
  }
}
