import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(
    home: FirestoreExpenseScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class FirestoreExpenseScreen extends StatefulWidget {
  const FirestoreExpenseScreen({super.key});

  @override
  State<FirestoreExpenseScreen> createState() => _FirestoreExpenseScreenState();
}

class _FirestoreExpenseScreenState extends State<FirestoreExpenseScreen> {
  // 1. FIRESTORE COLLECTION REFERENCE
  final CollectionReference _expensesCollection =
      FirebaseFirestore.instance.collection('expenses');

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // 2. CREATE: പുതിയ ഡോക്യുമെന്റ് ആഡ് ചെയ്യാൻ
  Future<void> _addExpense() async {
    final title = _titleController.text.trim();
    final amount = _amountController.text.trim();

    if (title.isNotEmpty && amount.isNotEmpty) {
      await _expensesCollection.add({
        'title': title,
        'amount': double.tryParse(amount) ?? 0.0, // Firestore-ൽ നമ്പർ ആയി സൂക്ഷിക്കാം
        'createdAt': FieldValue.serverTimestamp(), // സർവർ സമയം
      });

      _titleController.clear();
      _amountController.clear();
    }
  }

  // 3. DELETE: ഡോക്യുമെന്റ് ഡിലീറ്റ് ചെയ്യാൻ (Document ID ഉപയോഗിച്ച്)
  Future<void> _deleteExpense(String docId) async {
    await _expensesCollection.doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App Version B'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // INPUT FIELDS
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Expense Title (e.g., Dinner)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (e.g., 250)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: const Size.fromHeight(45),
              ),
              onPressed: _addExpense,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add to Firestore', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),

            const SizedBox(height: 20),
            const Divider(),

            // 4. READ: FIRESTORE REALTIME STREAM
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // createdAt വച്ച് ഓഡർ ചെയ്താണ് ഡാറ്റ എടുക്കുന്നത്
                stream: _expensesCollection.orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final docId = docs[index].id; // Document ID

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(
                              data['title'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('₹ ${data['amount']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteExpense(docId),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return const Center(
                    child: Text('No expenses found in Firestore!'),
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