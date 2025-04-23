// ================================
// 📝 ReviewEventsScreen.dart
// ================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../calendar/calendar_event.dart';
import '../calendar/calendar_repository.dart';

class ReviewEventsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> parsedEvents;

  const ReviewEventsScreen({super.key, required this.parsedEvents});

  @override
  State<ReviewEventsScreen> createState() => _ReviewEventsScreenState();
}

class _ReviewEventsScreenState extends State<ReviewEventsScreen> {
  final CalendarRepository _calendarRepo = CalendarRepository();
  late List<Map<String, dynamic>> _editableEvents;

  @override
  void initState() {
    super.initState();
    _editableEvents = List<Map<String, dynamic>>.from(widget.parsedEvents);
  }

  void _addToCalendar() {
    for (final event in _editableEvents) {
      _calendarRepo.addEvent(
        CalendarEvent(
          id: UniqueKey().toString(),
          title: event['title'],
          description: '',
          date: event['date'],
          startTime: const TimeOfDay(hour: 9, minute: 0),
          endTime: const TimeOfDay(hour: 10, minute: 0),
          colorValue: Colors.teal.value,
        ),
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Events added to calendar!')),
    );
    Navigator.pop(context);
  }

  void _editTitle(int index, String value) {
    setState(() => _editableEvents[index]['title'] = value);
  }

  void _editDate(int index, DateTime newDate) {
    setState(() => _editableEvents[index]['date'] = newDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📝 Review & Edit Events')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _editableEvents.length,
        itemBuilder: (context, index) {
          final event = _editableEvents[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'Title'),
                    controller: TextEditingController(text: event['title'])
                      ..selection = TextSelection.collapsed(offset: event['title'].length),
                    onChanged: (value) => _editTitle(index, value),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('📅 ${DateFormat.yMMMd().format(event['date'])}'),
                      const Spacer(),
                      TextButton(
                        child: const Text('Change Date'),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: event['date'],
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                          );
                          if (picked != null) _editDate(index, picked);
                        },
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      onPressed: () => setState(() => _editableEvents.removeAt(index)),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: _editableEvents.isEmpty ? null : _addToCalendar,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Confirm & Add to Calendar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}