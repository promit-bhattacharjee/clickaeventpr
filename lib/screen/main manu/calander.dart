
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;
  final DateTime _firstDay = DateTime(2022, 1, 1);
  final DateTime _lastDay = DateTime(2031, 12, 31);

  Map<String, List<Map<String, dynamic>>> mySelectedEvents = {};

  final titleController = TextEditingController();
  final descpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusedDay = _focusedDay.isBefore(_firstDay) ? _firstDay : _focusedDay;
    _focusedDay = _focusedDay.isAfter(_lastDay) ? _lastDay : _focusedDay;
    _selectedDate = _focusedDay;

    loadPreviousEvents();
  }

  Future<String?> _getUserEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Future<void> loadPreviousEvents() async {
    final String? userEmail = await _getUserEmail();
    if (userEmail == null) return;

    final eventsSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('email', isEqualTo: userEmail)
        .get();
    final events = eventsSnapshot.docs.map((doc) => doc.data()).toList();

    final Map<String, List<Map<String, dynamic>>> loadedEvents = {};
    for (var event in events) {
      final date = (event['date'] as Timestamp).toDate();
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      if (loadedEvents[formattedDate] != null) {
        loadedEvents[formattedDate]!.add({
          'eventTitle': event['type'],
          'eventDescp': event['description'],
        });
      } else {
        loadedEvents[formattedDate] = [
          {
            'eventTitle': event['type'],
            'eventDescp': event['description'],
          }
        ];
      }
    }

    setState(() {
      mySelectedEvents = loadedEvents;
    });
  }

  Future<void> _addEvent() async {
    if (titleController.text.isEmpty || descpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Required title and description'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final String formattedDate =
        DateFormat('yyyy-MM-dd').format(_selectedDate!);

    final userEmail = await _getUserEmail();
    final newEvent = {
      'type': titleController.text,
      'description': descpController.text,
      'date': Timestamp.fromDate(_selectedDate!),
      'userEmail': userEmail, // Store user email with the event
    };

    await FirebaseFirestore.instance.collection('events').add(newEvent);

    setState(() {
      if (mySelectedEvents[formattedDate] != null) {
        mySelectedEvents[formattedDate]?.add({
          'eventTitle': titleController.text,
          'eventDescp': descpController.text,
        });
      } else {
        mySelectedEvents[formattedDate] = [
          {
            'eventTitle': titleController.text,
            'eventDescp': descpController.text,
          }
        ];
      }
    });

    titleController.clear();
    descpController.clear();
    Navigator.pop(context);
  }

  List<Map<String, dynamic>> _listOfDayEvents(DateTime dateTime) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    return mySelectedEvents[formattedDate] ?? [];
  }

  Future<void> _showAddEventDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Add New Event',
          textAlign: TextAlign.center,
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            TextField(
              controller: descpController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            child: const Text('Add Event'),
            onPressed: () => _addEvent(),
          )
        ],
      ),
    );
  }

  Widget _buildEventMarker(DateTime dateTime) {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    final hasEvents = mySelectedEvents.containsKey(formattedDate);

    return hasEvents
        ? Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          )
        : const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Calendar",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.red,
        centerTitle: true,
        elevation: 1,
        // leading: IconButton(
        //   onPressed: () {
        //   },
        //   icon: const Icon(Icons.arrow_back),
        // ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: _firstDay,
            lastDay: _lastDay,
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDate, selectedDay)) {
                setState(() {
                  _selectedDate = selectedDay;
                  _focusedDay = focusedDay.isBefore(_firstDay)
                      ? _firstDay
                      : focusedDay.isAfter(_lastDay)
                          ? _lastDay
                          : focusedDay;
                });
              }
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDate, day);
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay.isBefore(_firstDay)
                    ? _firstDay
                    : focusedDay.isAfter(_lastDay)
                        ? _lastDay
                        : focusedDay;
              });
            },
            eventLoader: _listOfDayEvents,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                return _buildEventMarker(date);
              },
            ),
          ),
          ..._listOfDayEvents(_selectedDate!).map(
            (event) => ListTile(
              leading: const Icon(
                Icons.done,
                color: Colors.teal,
              ),
              title: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('Event Title:   ${event['eventTitle']}'),
              ),
              subtitle: Text('Description:   ${event['eventDescp']}'),
            ),
          ),
        ],
      ),
    );
  }
}
