import 'package:clickaeventpr/screen/main%20manu/EventDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clickaeventpr/screen/main%20manu/home.dart';

class PreviousEventsPage extends StatelessWidget {
  const PreviousEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const PreviousEventsPageWidget(),
    );
  }
}

class PreviousEventsPageWidget extends StatefulWidget {
  const PreviousEventsPageWidget({super.key});

  @override
  State<PreviousEventsPageWidget> createState() =>
      _PreviousEventsPageWidgetState();
}

class _PreviousEventsPageWidgetState extends State<PreviousEventsPageWidget> {
  final List<String> _selectedItems = [];
  String _userEmail = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('email') ?? '';
    });
  }

  Future<List<Map<String, dynamic>>> _fetchItemsFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('email', isEqualTo: _userEmail)
        .where('status', isEqualTo: 'completed') // Update status to 'completed'
        .get();

    return snapshot.docs.map((doc) {
      return {...doc.data(), 'docId': doc.id};
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchGuests(String eventId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('guests')
        .where('eventId', isEqualTo: eventId)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> _performAction(Future<void> Function() action) async {
    setState(() {
      _isLoading = true;
    });
    await action();
    setState(() {
      _isLoading = false;
    });
    _refreshEvents();
  }

  Future<void> _completeEvent(String eventId) async {
    bool confirmed = await _showConfirmationDialog('Complete Event');
    if (confirmed) {
      await _performAction(() async {
        await FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .update({'status': 'completed'});
      });
    }
  }

  Future<void> _deleteEvent(String eventId) async {
    bool confirmed = await _showConfirmationDialog('Delete Event');
    if (confirmed) {
      await _performAction(() async {
        await FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .delete();
      });
    }
  }

  Future<void> _downloadEvent(String eventId) async {
    bool confirmed = await _showConfirmationDialog('Download Event');
    if (confirmed) {
      await _performAction(() async {
        final eventSnapshot = await FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .get();

        final eventDetails = eventSnapshot.data();
        final guests = await _fetchGuests(eventId);

        // Combine event details, guests, and budget into a PDF
        await _generatePdf(eventDetails, guests);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF Generated')),
        );
      });
    }
  }

  Future<void> _generatePdf(Map<String, dynamic>? eventDetails,
      List<Map<String, dynamic>> guests) async {
    final pdf = pw.Document();
    final eventTitle = eventDetails?['type'] ?? 'Event';

    // Add content to the PDF
    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Event: $eventTitle', style: const pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            pw.Text('Event Details:', style: const pw.TextStyle(fontSize: 18)),
            pw.Text('Date: ${eventDetails?['date'] ?? 'N/A'}'),
            pw.Text('Status: ${eventDetails?['status'] ?? 'N/A'}'),
            pw.SizedBox(height: 20),
            pw.Text('Guests:', style: const pw.TextStyle(fontSize: 18)),
            ...guests.map((guest) => pw.Text(
                'Guest: ${guest['name']}, Contact: ${guest['contact'] ?? 'N/A'}'))
          ],
        );
      },
    ));

    // Save PDF to device
    final output = await getExternalStorageDirectory();
    final file = File('${output!.path}/event_$eventTitle.pdf');
    await file.writeAsBytes(await pdf.save());

    print('PDF saved to ${file.path}');
  }

  Future<bool> _showConfirmationDialog(String action) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('$action Confirmation'),
              content: Text('Are you sure you want to $action this event?'),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Confirm'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _refreshEvents() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClickAEvent'),
        backgroundColor: Colors.red,
        centerTitle: true,
        elevation: 1,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => const Home()));
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Divider(height: 35),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchItemsFromFirestore(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return const Text('Error loading events');
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No events found.');
                      }

                      final events = snapshot.data!;
                      return Expanded(
                        child: ListView.builder(
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];
                            final eventId = event['docId'];

                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 5),
                              child: ListTile(
                                title: Text(event['name'] ?? 'Unnamed Event'),
                                subtitle: Text(
                                    'Description: ${event['description'] ?? 'No description'}\nType: ${event['type'] ?? 'Unknown'}'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EventDetailsPage(
                                        eventId: eventId,
                                        userEmail: _userEmail,
                                      ),
                                    ),
                                  );
                                },
                                trailing: Wrap(
                                  spacing: 10,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check),
                                      onPressed: () => _completeEvent(eventId),
                                      tooltip: 'Complete Event',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _deleteEvent(eventId),
                                      tooltip: 'Delete Event',
                                    ),
                                    // Removed the download button
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
