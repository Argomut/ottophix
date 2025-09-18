import 'package:flutter/material.dart';

class Task {
  String id;
  String name;
  String? description;
  DateTime? creationTime;
  String? totalUsedTime;
  DateTime? finishTime;


  Task({
    required this.id,
    required this.name,
    this.description,
    this.creationTime,
    this.totalUsedTime,
    this.finishTime,
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
    };
  }
}