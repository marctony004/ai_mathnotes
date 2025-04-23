import 'package:flutter/material.dart';

class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date; // ✅ Newly added field
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final int? colorValue;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date, // ✅ Required field now
    this.startTime,
    this.endTime,
    this.colorValue,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'date': date.toIso8601String(), // ✅ Save as string
        'startTime': startTime != null ? '${startTime!.hour}:${startTime!.minute}' : null,
        'endTime': endTime != null ? '${endTime!.hour}:${endTime!.minute}' : null,
        'colorValue': colorValue,
      };

  factory CalendarEvent.fromMap(Map<String, dynamic> map) {
    final timeParts = (String? timeStr) {
      if (timeStr == null) return null;
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    };

    return CalendarEvent(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']), // ✅ Parse the new field
      startTime: timeParts(map['startTime']),
      endTime: timeParts(map['endTime']),
      colorValue: map['colorValue'],
    );
  }
}
