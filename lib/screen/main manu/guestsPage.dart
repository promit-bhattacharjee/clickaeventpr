import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bodyBackground.dart';

class Guests extends StatefulWidget {
  const Guests({super.key});

  @override
  State<Guests> createState() => _GuestsState();
}

class _GuestsState extends State<Guests> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedEvent;
  String _guestName = '';
  String _contactNumber = '';
  String _address = '';

  final List<Map<String, String>> _events = [];
  bool _isLoading = true; // Loading indicator
  String? _userEmail; // To store user email

  @override
  void initState() {
    super.initState();
    _loadUserEmail(); // Load user email and events
  }

  Future<void> _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('email'); // Get user email
    });
    _loadEvents(); // Load events after getting the email
  }

  Future<void> _loadEvents() async {
    // if (_userEmail == null) return; // Ensure email is loaded
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('status', isEqualTo: 'active')
          .where("email", isEqualTo: _userEmail)
          .get();

      final List<Map<String, String>> events = [];

      snapshot.docs.forEach((doc) {
        if (doc['type'] != null) {
          events.add({'id': doc.id, 'name': doc['name'], 'type': doc['type']});
        }
      });

      setState(() {
        _events.addAll(events);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading events: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    try {
      if (_userEmail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User email not found.'),
          ),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('guests').add({
        'eventID': _selectedEvent,
        'guestName': _guestName,
        'contactNumber': _contactNumber,
        'address': _address,
        'email': _userEmail,
        'createdAt': Timestamp.now(),
        'status': "all"
      });

      // Clear form fields
      _formKey.currentState?.reset();
      setState(() {
        _selectedEvent = null;
        _guestName = '';
        _contactNumber = '';
        _address = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Guest added successfully!'),
        ),
      );
    } catch (e) {
      print('Error adding guest: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add guest. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text('Add Guest'),
        centerTitle: true,
      ),
      body: BodyBackground(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Select Event'),
                        value: _selectedEvent,
                        items: _events.map((event) {
                          return DropdownMenuItem<String>(
                            value: event['id'],
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(event['name']!,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(width: 4),
                                Text(
                                  "[" + event['type']!,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedEvent = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select an event';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Guest Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the guest\'s name';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _guestName = value;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration:
                            InputDecoration(labelText: 'Contact Number'),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the contact number';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _contactNumber = value;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Address'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the address';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _address = value;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text('Add Guest'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
