import 'package:clickaeventpr/screen/main%20manu/home.dart';
import 'package:clickaeventpr/style/style.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReceiptPicturePage extends StatefulWidget {
  const ReceiptPicturePage({super.key});

  @override
  _ReceiptPicturePageState createState() => _ReceiptPicturePageState();
}

class _ReceiptPicturePageState extends State<ReceiptPicturePage> {
  final List<File> _images = [];
  String? _selectedEvent;
  String? _selectedTransaction;
  String? _selectedEventId;
  String? _selectedTransactionId;
  DateTime? _selectedDateTime;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _transactions = [];
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserEmail(); // Load user email at the start
  }

  Future<void> _loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('email');
    });
    _fetchEvents(); // Fetch only events at the start
  }

  Future<void> _fetchEvents() async {
    try {
      QuerySnapshot eventSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('email', isEqualTo: _userEmail)
          .where('status', isEqualTo: "active")
          .get();

      setState(() {
        _events = eventSnapshot.docs
            .map((doc) => {'id': doc.id, 'name': doc['name']})
            .toList();
      });
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  Future<void> _fetchTransactions(String eventId) async {
    try {
      QuerySnapshot transactionSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('eventDocId', isEqualTo: eventId)
          .where('email', isEqualTo: _userEmail)
          .get();

      setState(() {
        _transactions = transactionSnapshot.docs
            .map((doc) => {'id': doc.id, 'name': doc['title']})
            .toList();
      });
    } catch (e) {
      print('Error fetching transactions: $e');
    }
  }

  Future<void> _pickImage() async {
    if (_images.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 2 images allowed')),
      );
      return;
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _selectDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _uploadImages() async {
    if (_userEmail == null) return; // Ensure email is loaded
    try {
      // Upload images to Firebase Storage and get URLs
      List<String> imageUrls = [];
      for (File image in _images) {
        String fileName = _selectedEventId! +
            _selectedTransactionId! +
            DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('receipt_images')
            .child(fileName);
        UploadTask uploadTask = storageRef.putFile(image);
        TaskSnapshot snapshot = await uploadTask;
        String imageUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      // Save the data to Firestore
      await FirebaseFirestore.instance.collection('receipts').add({
        'eventId': _selectedEventId,
        'transactionId': _selectedTransactionId,
        'dateTime': _selectedDateTime,
        'imageUrls': imageUrls,
        'email': _userEmail,
      });

      // Clear the form
      setState(() {
        _images.clear();
        _selectedEvent = null;
        _selectedTransaction = null;
        _selectedDateTime = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt uploaded successfully')),
      );
    } catch (e) {
      print('Error uploading receipt: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error uploading receipt')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorRed,
        centerTitle: true,
        title: const Text(
          "Budget Tracker",
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Event Dropdown
            DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Select Event'),
              value: _selectedEvent,
              items: _events.map((event) {
                return DropdownMenuItem<String>(
                  value: event['name'],
                  child: Text(event['name']),
                  onTap: () {
                    _selectedEventId = event['id']; // Store event document ID
                    _fetchTransactions(
                        _selectedEventId!); // Fetch transactions for selected event
                  },
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedEvent = newValue;
                });
              },
            ),
            const SizedBox(height: 16),

            // Transaction Dropdown
            DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Select Transaction'),
              value: _selectedTransaction,
              items: _transactions.map((transaction) {
                return DropdownMenuItem<String>(
                  value: transaction['name'],
                  child: Text(transaction['name']),
                  onTap: () {
                    _selectedTransactionId =
                        transaction['id']; // Store transaction document ID
                  },
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedTransaction = newValue;
                });
              },
            ),
            const SizedBox(height: 16),

            // Date and Time Picker
            ListTile(
              title: Text(
                _selectedDateTime == null
                    ? 'Select Date and Time'
                    : DateFormat.yMMMd().add_jm().format(_selectedDateTime!),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDateTime,
            ),
            const SizedBox(height: 16),

            // Image Previews
            Row(
              children: _images.map((image) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.file(image, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _images.remove(image);
                          });
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),

            // Add Image Button
            if (_images.length < 2)
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Add Image'),
              ),

            const Spacer(),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                if (_selectedEvent == null ||
                    _selectedTransaction == null ||
                    _selectedDateTime == null ||
                    _images.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please complete all fields')),
                  );
                  return;
                }

                // Handle submission with event and transaction IDs
                _uploadImages();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
