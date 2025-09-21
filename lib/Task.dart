import 'package:flutter/material.dart';
import 'item.dart';

class Task {
  String id;
  String name;
  String? description;
  DateTime? creationTime;
  String? totalUsedTime;
  DateTime? finishTime;
  List<Map<String, dynamic>>? assignedParts; // Store parts as JSON data
  String? status; // Add status field
  int? accumulatedSeconds; // Track accumulated time in seconds
  DateTime? lastPauseTime; // Track when task was last paused

  Task({
    required this.id,
    required this.name,
    this.description,
    this.creationTime,
    this.totalUsedTime,
    this.finishTime,
    this.assignedParts,
    this.status,
    this.accumulatedSeconds,
    this.lastPauseTime,
  });


  factory Task.fromSupabaseJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      creationTime: json['creation_time'] != null
          ? DateTime.parse(json['creation_time'])
          : null,
      finishTime: json['finish_time'] != null
          ? DateTime.parse(json['finish_time'])
          : null,
      totalUsedTime: json['total_used_time'],
      assignedParts: null, // assigned_parts column doesn't exist in database
      status: json['status'],
      accumulatedSeconds: json['accumulated_seconds'] ?? 0,
      lastPauseTime: json['last_pause_time'] != null
          ? DateTime.parse(json['last_pause_time'])
          : null,
    );
  }

  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'creation_time': creationTime?.toIso8601String(),
      'finish_time': finishTime?.toIso8601String(),
      'total_used_time': totalUsedTime,
      'status': status,
      'accumulated_seconds': accumulatedSeconds,
      'last_pause_time': lastPauseTime?.toIso8601String(),
      // Note: assigned_parts column doesn't exist in the database schema
      // We'll handle parts separately through the cart/checkout system
    };
  }
}