import 'calendar_event.dart';

class CalendarRepository {
  static final List<CalendarEvent> _events = [];

  // Add a new event
  void addEvent(CalendarEvent event) {
    _events.add(event);
  }

  // Get all events
  List<CalendarEvent> getAllEvents() {
    return _events;
  }

  // Get events for a specific date
  List<CalendarEvent> getEventsForDate(DateTime date) {
    return _events.where((event) =>
        event.date.year == date.year &&
        event.date.month == date.month &&
        event.date.day == date.day).toList();
  }

  // Update an existing event
  void updateEvent(String id, CalendarEvent updatedEvent) {
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1) {
      _events[index] = updatedEvent;
    }
  }

  // Delete an event
  void deleteEvent(String id) {
    _events.removeWhere((e) => e.id == id);
  }
}
