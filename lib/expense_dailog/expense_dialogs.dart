import 'package:flutter/material.dart';

class ExpenseDialogs {
  // കലണ്ടർ കാണിക്കാനും ഡേറ്റ് സെലക്ട് ചെയ്യാനുമുള്ള കോമൺ ഫങ്ക്ഷൻ
  static Future<void> _selectDate(
      BuildContext context, TextEditingController dateController) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate:
          DateTime.now(), // കലണ്ടർ തുറക്കുമ്പോൾ ഇന്നത്തെ തീയതി കാണിക്കും
      firstDate: DateTime(2020), // എത്ര വർഷം പുറകോട്ട് പോകാം
      lastDate: DateTime(2030), // എത്ര വർഷം മുൻപോട്ട് പോകാം
    );

    if (pickedDate != null) {
      // തിരഞ്ഞെടുത്ത തീയതിയെ 'DD-MM-YYYY' രൂപത്തിലാക്കി ബോക്സിലേക്ക് നൽകുന്നു
      String formattedDate =
          "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
      dateController.text = formattedDate;
    }
  }

  // 1. പുതിയ ചിലവ് ചേർക്കാനുള്ള പോപ്പപ്പ് ബോക്സ്
  static void showAddDialog({
    required BuildContext context,
    required TextEditingController titleController,
    required TextEditingController amountController,
    required TextEditingController dateController,
    required VoidCallback onAdd,
    required VoidCallback onCancel,
  }) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Expense"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                      labelText: "എന്തിനാണ് ചിലവാക്കിയത്?")),
              const SizedBox(height: 10),
              TextField(
                controller: dateController,
                readOnly:
                    true, // യൂസർക്ക് കീബോർഡ് വച്ച് കൈകൊണ്ട് ടൈപ്പ് ചെയ്യാൻ പറ്റില്ല
                onTap: () => _selectDate(context,
                    dateController), // ബോക്സിൽ ഞെക്കുമ്പോൾ കലണ്ടർ വരും!
                decoration: const InputDecoration(
                  labelText: "തീയതി തിരഞ്ഞെടുക്കുക",
                  suffixIcon: Icon(Icons
                      .calendar_month), // ബോക്സിന്റെ വലതുവശത്ത് ഒരു കലണ്ടർ ഐക്കൺ
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: "എത്ര രൂപയായി?")),
            ],
          ),
          actions: [
            TextButton(onPressed: onCancel, child: const Text("Cancel")),
            ElevatedButton(onPressed: onAdd, child: const Text("Add")),
          ],
        );
      },
    );
  }

  // 2. ഉള്ള ചിലവ് എഡിറ്റ് ചെയ്യാനുള്ള പോപ്പപ്പ് ബോക്സ്
  static void showEditDialog({
    required BuildContext context,
    required TextEditingController titleController,
    required TextEditingController amountController,
    required TextEditingController dateController,
    required VoidCallback onUpdate,
    required VoidCallback onCancel,
  }) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Expense"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: titleController,
                  decoration:
                      const InputDecoration(labelText: "മാറ്റേണ്ട പേര്")),
              const SizedBox(height: 10),
              TextField(
                controller: dateController,
                readOnly: true, // ഇവിടെയും കൈകൊണ്ട് ടൈപ്പ് ചെയ്യുന്നത് തടഞ്ഞു
                onTap: () => _selectDate(
                    context, dateController), // ഞെക്കുമ്പോൾ കലണ്ടർ വരും
                decoration: const InputDecoration(
                  labelText: "മാറ്റേണ്ട തീയതി",
                  suffixIcon: Icon(Icons.calendar_month),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: "മാറ്റേണ്ട തുക")),
            ],
          ),
          actions: [
            TextButton(onPressed: onCancel, child: const Text("Cancel")),
            ElevatedButton(onPressed: onUpdate, child: const Text("Update")),
          ],
        );
      },
    );
  }
}
