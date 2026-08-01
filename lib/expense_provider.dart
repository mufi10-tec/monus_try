import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExpenseProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ഫയർബേസിലേക്ക് പുതിയ ചെലവ് ആഡ് ചെയ്യാനുള്ള ഫങ്ക്ഷൻ 👈
  Future<void> addExpense(String title, double amount) async {
    final user = _auth.currentUser;
    if (user == null) return; // യൂസർ ലോഗിൻ ചെയ്തിട്ടില്ലെങ്കിൽ ഒന്നും ചെയ്യില്ല

    try {
      // 'users' എന്ന കളക്ഷനിൽ ലോഗിൻ ചെയ്ത യൂസറുടെ ഐഡിക്ക് ഉള്ളിൽ 'expenses' സബ്-കളക്ഷൻ ഉണ്ടാക്കുന്നു
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .add({
        'title': title,
        'amount': amount,
        'timestamp': FieldValue.serverTimestamp(), // സമയം കൃത്യമായി കിട്ടാൻ
      });
      
      notifyListeners(); // സ്ക്രീൻ പുതുക്കാൻ പ്രൊവൈഡറോട് പറയുന്നു
    } catch (e) {
      print("Error adding expense: $e");
    }
  }
Future<void> updateExpense(String docId, String title, double amount) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .doc(docId) // മാറ്റം വരുത്തേണ്ട ഡോക്യുമെന്റ് ഐഡി
          .update({
        'title': title,
        'amount': amount,
      });
    } catch (e) {
      print("Error updating expense: $e");
    }

  }   
  
  Future<void> deleteExpense(String docId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .doc(docId) // കളയേണ്ട ഡോക്യുമെന്റ് ഐഡി
          .delete();
    } catch (e) {
      print("Error deleting expense: $e");
    }
  }
  // ഫയർബേസിൽ നിന്ന് ചെലവുകളുടെ ലിസ്റ്റ് ലൈവ് ആയി എടുക്കാനുള്ള Stream 👈
  Stream<QuerySnapshot> get expensesStream {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .orderBy('timestamp', descending: true) // പുതിയത് ആദ്യം കാണിക്കാൻ
        .snapshots();
  }
}