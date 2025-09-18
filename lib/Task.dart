import 'package:flutter/material.dart';

class Task {
  String id;
  String name;
  String? description;
  DateTime? creationTime;
  String? totalUsedTime;
  DateTime? finishTime;
  // Note: Add fields for evidence and assigned parts if you have models for them
  // List<Evidence>? evidence;
  // List<Part>? assignedParts;

  Task({
    required this.id,
    required this.name,
    this.description,
    this.creationTime,
    this.totalUsedTime,
    this.finishTime,
  });
}