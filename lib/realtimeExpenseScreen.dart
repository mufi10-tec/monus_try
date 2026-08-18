import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RealtimeExpenseScreen extends StatefulWidget {
  const RealtimeExpenseScreen({super.key});

  @override
  State<RealtimeExpenseScreen> createState() => _RealtimeExpenseScreenState();
}

class _RealtimeExpenseScreenState extends State<RealtimeExpenseScreen> {
  // Realtime Database റെഫറൻസ് ഉണ്ടാക്കുന്നു
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref('monthly_budget');
  final TextEditingController _budgetController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realtime Budget Tracker'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Current Monthly Budget:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 1. REALTIME STREAM BUILDER (തത്സമയം ഡാറ്റ വായിക്കുന്നു)
            StreamBuilder<DatabaseEvent>(
              stream: _dbRef
                  .onValue, // ഡാറ്റാബേസിൽ എന്ത് മാറ്റം വന്നാലും ഇത് അറിയും
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  final budget = snapshot.data!.snapshot.value.toString();
                  return Text(
                    '₹ $budget',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  );
                }

                return const Text(
                  'No Budget Set',
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                );
              },
            ),

            const SizedBox(height: 40),

            // 2. INPUT FIELD (പുതിയ ബജറ്റ് മാറ്റാൻ)
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter New Budget Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // 3. UPDATE BUTTON (ഡാറ്റാബേസിലേക്ക് ആഡ് ചെയ്യാൻ)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              onPressed: () async {
                if (_budgetController.text.isNotEmpty) {
                  // Realtime Database-ലേക്ക് പുതിയ ബജറ്റ് സെറ്റ് ചെയ്യുന്നു
                  await _dbRef.set(_budgetController.text);
                  _budgetController.clear();
                }
              },
              child: const Text('Update Budget',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
