import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

class EventDetailsPage extends StatefulWidget {
  final String eventId;
  final String userEmail;

  const EventDetailsPage({
    Key? key,
    required this.eventId,
    required this.userEmail,
  }) : super(key: key);

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  Map<String, dynamic>? _eventDetails;
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _guests = [];
  List<String> _imageUrls = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
    _fetchTransactions();
    _fetchGuests();
  }

  Future<void> _fetchEventDetails() async {
    try {
      final eventSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .get();

      setState(() {
        _eventDetails = eventSnapshot.data();
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchTransactions() async {
    try {
      final transactionsSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('eventDocId', isEqualTo: widget.eventId)
          .get();

      final transactionData = transactionsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Extract image URLs from JSON objects in transactions
      List<String> imageUrls = [];
      for (var transaction in transactionData) {
        final imageUrlsObject =
            transaction['imageUrls'] as Map<String, dynamic>?;
        if (imageUrlsObject != null) {
          imageUrls.addAll(imageUrlsObject.values.cast<String>());
        }
      }

      setState(() {
        _transactions = transactionData;
        _imageUrls = imageUrls;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  Future<void> _fetchGuests() async {
    try {
      final guestsSnapshot = await FirebaseFirestore.instance
          .collection('guests')
          .where('eventID', isEqualTo: widget.eventId)
          .get();

      setState(() {
        _guests = guestsSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Event Details'),
          backgroundColor: Colors.red,
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Event Details'),
          backgroundColor: Colors.red,
          centerTitle: true,
        ),
        body: const Center(child: Text('Failed to load data')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Details
            Text(
              'Event Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Name: ${_eventDetails?['name'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            Text(
              'Description: ${_eventDetails?['description'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            Text(
              'Date: ${_eventDetails?['date'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            Text(
              'Location: ${_eventDetails?['location'] ?? 'N/A'}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),

            // Transactions
            Text(
              'Transactions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ..._transactions.isEmpty
                ? [const Text('No transactions available')]
                : _transactions.map((transaction) => ListTile(
                      title: Text('Amount: \$${transaction['amount']}'),
                      subtitle: Text('Description: ${transaction['title']}'),
                    )),
            const SizedBox(height: 16),

            // Images Carousel
            if (_imageUrls.isNotEmpty) ...[
              Text(
                'Images',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              CarouselSlider(
                options: CarouselOptions(
                  height: 120,
                  aspectRatio: 16 / 9,
                  viewportFraction: 1.0,
                  enlargeCenterPage: true,
                ),
                items: _imageUrls.map((imageUrl) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Guests
            Text(
              'Guests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ..._guests.isEmpty
                ? [const Text('No guests available')]
                : _guests.map((guest) => ListTile(
                      title: Text('Name: ${guest['guestName'] ?? 'Unnamed'}'),
                      subtitle: Text('Status: ${guest['status'] ?? 'Unknown'}'),
                    )),
          ],
        ),
      ),
    );
  }
}
