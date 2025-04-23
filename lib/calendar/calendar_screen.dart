import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'calendar_event.dart';
import 'calendar_repository.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarRepository _calendarRepo = CalendarRepository();
  DateTime _focusedDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final events = _calendarRepo.getEventsForDate(_selectedDate);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 My Calendar'),
        backgroundColor: theme.colorScheme.primary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildMonthHeader()),
          SliverToBoxAdapter(child: _buildDateGrid()),
          const SliverToBoxAdapter(child: Divider(thickness: 1)),
          events.isEmpty
              ? const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text("No events for this day."),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final event = events[index];
                      final color = _getEventColor(event);
                      final start = event.startTime?.format(context) ?? '--:--';
                      final end = event.endTime?.format(context) ?? '--:--';

                      return ListTile(
                        leading: CircleAvatar(backgroundColor: color, radius: 8),
                        title: Text(event.title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                        subtitle: Text("$start → $end\n${event.description ?? ''}", maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_forever, color: Colors.red),
                          onPressed: () {
                            setState(() => _calendarRepo.deleteEvent(event.id));
                          },
                        ),
                      );
                    },
                    childCount: events.length,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
              });
            },
          ),
          Text(
            DateFormat.yMMMM().format(_focusedDate),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateGrid() {
    final daysInMonth = DateUtils.getDaysInMonth(_focusedDate.year, _focusedDate.month);
    final firstDayOffset = DateTime(_focusedDate.year, _focusedDate.month, 1).weekday % 7;

    List<Widget> dayCells = List.generate(firstDayOffset, (_) => const SizedBox());
    for (int i = 1; i <= daysInMonth; i++) {
      final currentDay = DateTime(_focusedDate.year, _focusedDate.month, i);
      final isSelected = DateUtils.isSameDay(currentDay, _selectedDate);
      dayCells.add(
        GestureDetector(
          onTap: () => setState(() => _selectedDate = currentDay),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.teal : null,
            ),
            alignment: Alignment.center,
            margin: const EdgeInsets.all(4),
            child: Text(
              '$i',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: dayCells,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1.2,
      ),
    );
  }

  Color _getEventColor(CalendarEvent event) {
    final title = event.title.toLowerCase();
    if (title.contains('midterm') || title.contains('final') || title.contains('exam') || title.contains('deadline')) {
      return Colors.red;
    } else if (title.contains('quiz') || title.contains('homework') || title.contains('assignment')) {
      return Colors.amber;
    } else if (title.contains('class') || title.contains('lecture') || title.contains('presentation') || title.contains('study')) {
      return Colors.blue;
    }
    return Color(event.colorValue ?? Colors.teal.value);
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TimeOfDay? start;
    TimeOfDay? end;
    Color selectedColor = Colors.teal;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("➕ Add New Event"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                            if (picked != null) setState(() => start = picked);
                          },
                          child: Text(start == null ? "Start Time" : start!.format(context)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                            if (picked != null) setState(() => end = picked);
                          },
                          child: Text(end == null ? "End Time" : end!.format(context)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text("Event Color (optional)"),
                  Wrap(
                    spacing: 10,
                    children: [
                      Colors.teal,
                      Colors.red,
                      Colors.amber,
                      Colors.blue,
                    ].map((color) {
                      return GestureDetector(
                        onTap: () => setState(() => selectedColor = color),
                        child: CircleAvatar(
                          backgroundColor: color,
                          radius: 16,
                          child: selectedColor == color
                              ? const Icon(Icons.check, color: Colors.white, size: 16)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isEmpty || start == null || end == null) return;
                  final event = CalendarEvent(
                    id: UniqueKey().toString(),
                    title: titleController.text,
                    description: descController.text,
                    date: _selectedDate,
                    startTime: start,
                    endTime: end,
                    colorValue: selectedColor.value,
                  );
                  setState(() => _calendarRepo.addEvent(event));
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              )
            ],
          );
        });
      },
    );
  }
}
