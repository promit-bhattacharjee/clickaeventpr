import 'package:clickaeventpr/screen/main%20manu/home.dart';
import 'package:clickaeventpr/style/style.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bodyBackground.dart'; // Adjust this import based on your file structure

class Transaction {
  final String id; // Added id field for deletion and editing
  final String title;
  final double amount;
  final String eventDocId;

  Transaction(this.id, this.title, this.amount, this.eventDocId);
}

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final List<Transaction> _transactions = [];
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  String? _selectedEvent;
  double _totalSpent = 0.0;
  double _eventBudget = 0.0;
  final List<Map<String, String>> _events = []; // Store event names and IDs
  String? _selectedEventDocId;
  bool _isLoading = false;
  bool _isEventLoaded = false; // Flag to check if events are loaded
  String? email; // Nullable email field

  @override
  void initState() {
    super.initState();
    _getEmailFromPrefs();
  }

  Future<void> _getEmailFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email =
          prefs.getString('email'); // Fetch the email from SharedPreferences
    });
    if (email != null) {
      _loadEvents();
    }
  }

  Future<void> _loadEvents() async {
    if (email == null) return; // Ensure email is available

    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('status', isEqualTo: 'active')
          .where('email', isEqualTo: email)
          .get();
      final List<Map<String, String>> events = [];
      for (var doc in snapshot.docs) {
        events.add({
          'id': doc.id, // Document ID
          'name': doc.data()['name'] ?? 'Unnamed Event', // Event name
        });
      }

      setState(() {
        _events.addAll(events);
        _isEventLoaded = true; // Mark events as loaded
      });
    } catch (error) {
      print("Error loading events: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEventBudget(String eventDocId) async {
    if (!_isEventLoaded || email == null) {
      return; // Ensure events are loaded and email is available
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventDocId) // Use document ID directly
          .get();

      if (snapshot.exists) {
        final eventDoc = snapshot;
        setState(() {
          _eventBudget = eventDoc.data()?['budget']?.toDouble() ?? 0.0;
          _selectedEventDocId = eventDoc.id;
          _selectedEvent =
              _events.firstWhere((event) => event['id'] == eventDocId)['name'];
        });
        _loadTransactions(); // Load transactions after setting event budget
      } else {
        setState(() {
          _eventBudget = 0.0;
          _selectedEventDocId = null;
          _selectedEvent = null;
        });
      }
    } catch (error) {
      print("Error loading event budget: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addTransaction(String title, double amount) async {
    if (_selectedEventDocId == null || email == null) {
      return;
    }

    final newTransaction = Transaction(
      DateTime.now().toString(), // Use a timestamp as a unique id
      title,
      amount,
      _selectedEventDocId!,
    );

    setState(() {
      _transactions.add(newTransaction);
      _calculateTotalSpent();
    });

    try {
      await FirebaseFirestore.instance.collection('transactions').add({
        'title': newTransaction.title,
        'amount': newTransaction.amount,
        'createdAt': Timestamp.now(),
        'email': email,
        'eventDocId': newTransaction.eventDocId,
      });

      if (_selectedEventDocId != null) {
        await _updateEventBudget(_selectedEventDocId!, newTransaction.amount);
      }
    } catch (error) {
      print("Error adding transaction: $error");
    }
  }

  Future<void> _updateEventBudget(
      String eventDocId, double transactionAmount) async {
    try {
      final eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventDocId)
          .get();

      final newBudget =
          (eventDoc.data()?['budget']?.toDouble() ?? 0.0) - transactionAmount;

      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventDocId)
          .update({
        'budget': newBudget,
      });

      setState(() {
        _eventBudget = newBudget;
      });
    } catch (error) {
      print("Error updating event budget: $error");
    }
  }

  Future<void> _loadTransactions() async {
    if (_selectedEventDocId == null || email == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('email', isEqualTo: email)
          .where('eventDocId', isEqualTo: _selectedEventDocId)
          .get();

      final List<Transaction> loadedTransactions = [];

      for (var doc in snapshot.docs) {
        loadedTransactions.add(
          Transaction(
            doc.id, // Use Firestore document ID
            doc['title'],
            doc['amount'].toDouble(),
            doc['eventDocId'],
          ),
        );
      }

      setState(() {
        _transactions.clear();
        _transactions.addAll(loadedTransactions);
        _calculateTotalSpent();
        _isLoading = false;
      });
    } catch (error) {
      print("Error loading transactions: $error");
    }
  }

  Future<void> _deleteTransaction(String transactionId, double amount) async {
    try {
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transactionId)
          .delete();

      setState(() {
        _transactions.removeWhere((tx) => tx.id == transactionId);
        _calculateTotalSpent();
        // Optionally, update the event budget if needed
      });
    } catch (error) {
      print("Error deleting transaction: $error");
    }
  }

  Future<void> _editTransaction(String transactionId, double newAmount) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transactionId)
          .get();

      final oldAmount = doc.data()?['amount']?.toDouble() ?? 0.0;

      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transactionId)
          .update({'amount': newAmount});

      setState(() {
        // Update the transaction amount in the list
        final index = _transactions.indexWhere((tx) => tx.id == transactionId);
        if (index != -1) {
          _transactions[index] = Transaction(
            _transactions[index].id,
            _transactions[index].title,
            newAmount,
            _transactions[index].eventDocId,
          );
          _calculateTotalSpent();
        }
      });

      if (_selectedEventDocId != null) {
        await _updateEventBudget(_selectedEventDocId!, newAmount - oldAmount);
      }
    } catch (error) {
      print("Error editing transaction: $error");
    }
  }

  void _showEditTransactionDialog(Transaction tx) {
    titleController.text = tx.title;
    amountController.text = tx.amount.toString();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              readOnly: true,
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newAmount = double.tryParse(amountController.text) ?? 0.0;

              if (newAmount > 0.0) {
                _editTransaction(tx.id, newAmount);
                Navigator.of(ctx).pop();
                titleController.clear();
                amountController.clear();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text;
              final amount = double.tryParse(amountController.text) ?? 0.0;

              if (title.isNotEmpty && amount > 0.0) {
                _addTransaction(title, amount);
                Navigator.of(ctx).pop();
                titleController.clear();
                amountController.clear();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _calculateTotalSpent() {
    double total = 0.0;
    for (var tx in _transactions) {
      total += tx.amount;
    }
    setState(() {
      _totalSpent = total;
    });
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
      ),),
      body:  Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              DropdownButton<String>(
                hint: const Text('Select Event'),
                value: _selectedEvent,
                onChanged: (value) {
                  setState(() {
                    _selectedEvent = value;
                    _selectedEventDocId = _events
                        .firstWhere((event) => event['name'] == value)['id'];
                    _loadEventBudget(_selectedEventDocId!);
                  });
                },
                items: _events.map((event) {
                  return DropdownMenuItem<String>(
                    value: event['name'],
                    child: Text(event['name'] ?? 'Unnamed Event'),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text('Event Budget: $_eventBudget'),
              const SizedBox(height: 16),
              Text('Total Spent: $_totalSpent'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _showAddTransactionDialog,
                child: const Text('Add Transaction'),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _transactions.length,
                        itemBuilder: (ctx, index) {
                          final tx = _transactions[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(tx.title),
                              subtitle:
                                  Text('\$${tx.amount.toStringAsFixed(2)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        _showEditTransactionDialog(tx),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _deleteTransaction(tx.id, tx.amount);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),

    );
  }
}
