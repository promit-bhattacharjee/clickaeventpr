import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ViewReceiptsPage extends StatefulWidget {
  @override
  _ViewReceiptsPageState createState() => _ViewReceiptsPageState();
}

class _ViewReceiptsPageState extends State<ViewReceiptsPage> {
  String? _userEmail;
  String? _selectedEventId;
  String? _selectedTransactionId;

  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _getUserEmail();
  }

  Future<void> _getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('email'); // Get email from SharedPreferences
    });
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    QuerySnapshot eventSnapshot =
        await FirebaseFirestore.instance.collection('events').get();
    setState(() {
      _events = eventSnapshot.docs
          .map((doc) => {'id': doc.id, 'name': doc['name']})
          .toList();
    });
  }

  Future<void> _fetchTransactions(String eventId) async {
    QuerySnapshot transactionSnapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('eventDocId', isEqualTo: eventId)
        .get();
    setState(() {
      _transactions = transactionSnapshot.docs
          .map((doc) => {'id': doc.id, 'name': doc['title']})
          .toList();
    });
  }

  Stream<QuerySnapshot> _fetchReceipts() {
    if (_userEmail != null &&
        _selectedEventId != null &&
        _selectedTransactionId != null) {
      return FirebaseFirestore.instance
          .collection('receipts')
          .where('email', isEqualTo: _userEmail)
          .where('eventId', isEqualTo: _selectedEventId)
          .where('transactionId', isEqualTo: _selectedTransactionId)
          .snapshots();
    } else {
      return Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Receipt Pictures'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Event Dropdown
            DropdownButton<String>(
              isExpanded: true,
              hint: Text('Select Event'),
              value: _selectedEventId,
              items: _events.map((event) {
                return DropdownMenuItem<String>(
                  value: event['id'],
                  child: Text(event['name']),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedEventId = newValue;
                  _selectedTransactionId = null; // Reset transaction selection
                  _transactions.clear();
                  if (newValue != null) {
                    _fetchTransactions(newValue);
                  }
                });
              },
            ),
            SizedBox(height: 16),

            // Transaction Dropdown
            if (_selectedEventId != null)
              DropdownButton<String>(
                isExpanded: true,
                hint: Text('Select Transaction'),
                value: _selectedTransactionId,
                items: _transactions.map((transaction) {
                  return DropdownMenuItem<String>(
                    value: transaction['id'],
                    child: Text(transaction['name']),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedTransactionId = newValue;
                  });
                },
              ),

            SizedBox(height: 16),

            // Receipts GridView
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _fetchReceipts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                          'No receipts found for the selected event and transaction.'),
                    );
                  }

                  final receipts = snapshot.data!.docs;

                  return GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: receipts.length > 2 ? 2 : receipts.length,
                    itemBuilder: (context, index) {
                      final receipt = receipts[index];
                      final data = receipt.data() as Map<String, dynamic>?;
                      final List<dynamic> imageUrls =
                          data?['imageUrls'] as List<dynamic>? ?? [];

                      return GestureDetector(
                        onTap: () {
                          _showReceiptDetails(context, receipt);
                        },
                        child: GridTile(
                          child: imageUrls.isNotEmpty
                              ? Image.network(
                                  imageUrls.first as String,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) {
                                      return child;
                                    } else {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(Icons.error),
                                    );
                                  },
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey,
                                  child: Icon(Icons.receipt, size: 50),
                                ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReceiptDetails(
      BuildContext context, QueryDocumentSnapshot receipt) {
    final data =
        receipt.data() as Map<String, dynamic>?; // Safely cast data to Map
    final List<dynamic> imageUrls = data?['imageUrls'] as List<dynamic>? ?? [];
    final event = data?['event'] ?? 'No event';
    final transaction = data?['transaction'] ?? 'No transaction';
    final dateTime = data?['dateTime']?.toDate();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Event: $event',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Transaction: $transaction',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                if (dateTime != null)
                  Text(
                    'Date: ${DateFormat.yMMMd().add_jm().format(dateTime)}',
                    style: TextStyle(fontSize: 16),
                  ),
                SizedBox(height: 16),
                if (imageUrls.isNotEmpty)
                  ...imageUrls.map((imageUrl) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Image.network(
                        imageUrl as String,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) {
                            return child;
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(Icons.error),
                          );
                        },
                        fit: BoxFit.cover,
                      ),
                    );
                  }).toList(),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
