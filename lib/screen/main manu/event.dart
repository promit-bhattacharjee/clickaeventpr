import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(EventApp());
}

class EventApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: EventPage(),
    );
  }
}

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final TextEditingController _eventNameController =
      TextEditingController(); // Controller for event name
  final TextEditingController _eventTypeController = TextEditingController();
  final TextEditingController _eventDescriptionController =
      TextEditingController(); // Controller for description
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Get the current user's email
  Future<String?> _getUserEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  // Add new event to Firestore
  Future<void> _addEvent() async {
    final email = await _getUserEmail(); // Await the future to get the email
    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user logged in.')),
      );
      return;
    }

    if (_eventNameController.text.isEmpty ||
        _eventTypeController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null ||
        _eventDescriptionController.text.isEmpty) {
      // Check if description is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }

    final newEvent = {
      'name': _eventNameController.text,
      'type': _eventTypeController.text,
      'date': Timestamp.fromDate(_selectedDate!),
      'time': _selectedTime!.format(context),
      'description': _eventDescriptionController.text, // Added field
      'email': email,
      'status': 'active'
    };

    await FirebaseFirestore.instance.collection('events').add(newEvent);

    setState(() {
      _eventNameController.clear();
      _eventTypeController.clear();
      _eventDescriptionController.clear(); // Clear description
      _selectedDate = null;
      _selectedTime = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event added successfully!')),
    );
  }

  // Load events from Firestore
  Stream<List<Map<String, dynamic>>> _loadEvents() {
    return FirebaseFirestore.instance
        .collection('events')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'name': doc['name'],
                  'type': doc['type'],
                  'date': (doc['date'] as Timestamp).toDate(),
                  'time': doc['time'],
                  'description': doc['description'], // Added field
                  'email': doc['email'],
                })
            .toList());
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && picked != _selectedTime)
      setState(() {
        _selectedTime = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event'),
        backgroundColor: Colors.red,
        centerTitle: true,
        elevation: 1,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _eventNameController,
              decoration: InputDecoration(
                labelText: 'Event Name',
                hintText: 'Enter event name',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _eventTypeController,
              decoration: InputDecoration(
                labelText: 'Event Type',
                hintText: 'Birthday, Wedding, etc.',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _eventDescriptionController, // New field
              decoration: InputDecoration(
                labelText: 'Event Description',
                hintText: 'Enter event description',
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate == null
                      ? 'No date chosen!'
                      : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                ),
                ElevatedButton(
                  onPressed: _selectDate,
                  child: Text('Select Date'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedTime == null
                      ? 'No time chosen!'
                      : 'Time: ${_selectedTime!.format(context)}',
                ),
                ElevatedButton(
                  onPressed: _selectTime,
                  child: Text('Select Time'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addEvent,
              child: Text('Add Event'),
            ),
            SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }
}
