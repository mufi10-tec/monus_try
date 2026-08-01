import 'package:flutter/material.dart';

class ExpenseList extends StatelessWidget {
  final List<Map<String, dynamic>> expenses;
  final Function(int) onEdit;
  final Function(int) onDelete;

  const ExpenseList({
    super.key,
    required this.expenses,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: ListTile(
           
            title: Text(expense["title"],style: const TextStyle(fontWeight: FontWeight.bold),),
            subtitle: Text(expense["date"]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "₹${expense["amount"]}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => onEdit(index), // ഹോം പേജിലെ എഡിറ്റ് ഫങ്ക്ഷൻ വർക്ക് ചെയ്യും
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => onDelete(index), // ഹോം പേജിലെ ഡിലീറ്റ് ഫങ്ക്ഷൻ വർക്ക് ചെയ്യും
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}