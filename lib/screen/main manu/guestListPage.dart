import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuestListPage extends StatefulWidget {
  @override
  _GuestListPageState createState() => _GuestListPageState();
}

class _GuestListPageState extends State<GuestListPage> {
  String? _selectedEvent;
  String _selectedStatus = 'all'; // Default to 'all'
  final List<String> _events = [];
  final List<String> _statuses = ['invited', 'coming', 'rejected', 'all'];
  String? _userEmail;
  bool _isLoadingEvents = true;
  Map<String, String> _eventDocIds = {}; // Store event types and their doc IDs

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('email').toString();
    });
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      print(_userEmail);
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('email', isEqualTo: _userEmail)
          .where('status', isEqualTo: 'active')
          .get();

      final Map<String, String> events = {};

      snapshot.docs.forEach((doc) {
        if (doc['name'] != null) {
          events[doc['name']] = doc.id;
        }
      });

      setState(() {
        _events.clear();
        _events.addAll(events.keys);
        _eventDocIds = events;
        _isLoadingEvents = false;
      });
    } catch (e) {
      print('Error fetching events: $e');
      setState(() {
        _isLoadingEvents = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guest List'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (_isLoadingEvents)
            Center(child: CircularProgressIndicator())
          else if (_events.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  Text('No active events found.', textAlign: TextAlign.center),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text('Select Event'),
                value: _selectedEvent,
                items: _events.map((event) {
                  return DropdownMenuItem<String>(
                    value: event,
                    child: Text(event),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedEvent = newValue;
                    _selectedStatus = 'all'; // Reset status when changing event
                  });
                },
              ),
            ),
          SizedBox(height: 20),
          Container(
            height: 60,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _statuses.map((status) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedStatus = status;
                        });
                      },
                      child: Text(
                        '${status.capitalize()}',
                        style: TextStyle(
                          color: _selectedStatus == status
                              ? const Color.fromARGB(255, 6, 6, 6)
                              : Colors.black,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedStatus == status
                            ? Colors.blue
                            : Colors.grey[300],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _selectedEvent == null
                  ? null
                  : FirebaseFirestore.instance
                      .collection('guests')
                      .where('email', isEqualTo: _userEmail)
                      .where('eventID', isEqualTo: _eventDocIds[_selectedEvent])
                      .where('status',
                          isEqualTo:
                              _selectedStatus == 'all' ? null : _selectedStatus)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No guests found for the selected event and status.',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                final guests = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final guestName = data['guestName'] ?? 'Unknown';
                  final contactNumber = data['contactNumber'] ?? 'N/A';
                  final address = data['address'] ?? 'N/A';
                  final status = data['status'] ?? '';

                  return ListTile(
                    title: Text(guestName),
                    subtitle: Text('$contactNumber\n$address'),
                    isThreeLine: true,
                    trailing: DropdownButton<String>(
                      value: status,
                      onChanged: (newStatus) {
                        // Update status only if it's not 'all'
                        if (newStatus != null && newStatus != 'all') {
                          _updateGuestStatus(doc.id, newStatus);
                        }
                      },
                      items: _statuses.map((status) {
                        if (status == 'all') {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: IgnorePointer(
                              child: Text(
                                status.capitalize(),
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(
                            status.capitalize(),
                            style: TextStyle(color: Colors.black),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList();

                return ListView(children: guests);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateGuestStatus(String guestId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('guests')
          .doc(guestId)
          .update({'status': newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to ${newStatus.capitalize()}')),
      );
    } catch (e) {
      print('Error updating guest status: $e');
    }
  }
}

extension StringCasingExtension on String {
  String capitalize() {
    if (this.isEmpty) return '';
    return this[0].toUpperCase() + this.substring(1);
  }
}
