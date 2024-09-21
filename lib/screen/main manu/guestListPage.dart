import 'package:clickaeventpr/screen/main%20manu/home.dart';
import 'package:clickaeventpr/style/style.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuestListPage extends StatefulWidget {
  const GuestListPage({super.key});

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

      for (var doc in snapshot.docs) {
        if (doc['name'] != null) {
          events[doc['name']] = doc.id;
        }
      }

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
        backgroundColor: colorRed,
        centerTitle: true,
        title: const Text(
          "Guest List",
          style: TextStyle(color: Colors.white),

        ),

        leading: IconButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => const Home()));
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(

        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (_isLoadingEvents)
            const Center(child: CircularProgressIndicator())
          else if (_events.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child:
                  Text('No active events found.', textAlign: TextAlign.center),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<String>(
                isExpanded: true,
                hint: const Text('Select Event'),
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
          const SizedBox(height: 20),
          SizedBox(
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedStatus == status
                            ? Colors.blue
                            : Colors.grey[300],
                      ),
                      child: Text(
                        '${status.capitalize()}',
                        style: TextStyle(
                          color: _selectedStatus == status
                              ? const Color.fromARGB(255, 6, 6, 6)
                              : Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
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
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
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
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(
                            status.capitalize(),
                            style: const TextStyle(color: Colors.black),
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
    if (isEmpty) return '';
    return this[0].toUpperCase() + substring(1);
  }
}
