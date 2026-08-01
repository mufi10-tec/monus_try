import 'package:flutter/material.dart';

import 'package:monuss_try/expens_list.dart';
import 'package:monuss_try/expense_dailog/expense_dialogs.dart';

import 'package:monuss_try/expense_provider.dart';
import 'package:monuss_try/services/groq_service.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'total_card.dart';
import 'expense_chart.dart';
import 'package:cloud_functions/cloud_functions.dart';

class HomePage extends StatefulWidget {
  final String userEmail;
  const HomePage({super.key, required this.userEmail});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 🤖 Smart AI Expense Dialog Box
  void showSmartAIDialog() {
    final TextEditingController aiInputController = TextEditingController();
    final TextEditingController extractedTitleController = TextEditingController();
    final TextEditingController extractedAmountController = TextEditingController();

    bool isLoading = false;
    bool isExtracted = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.deepPurple),
                  SizedBox(width: 8),
                  Text("Smart AI Expense"),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isExtracted) ...[
                      const Text("ഉദാഹരണത്തിന്: 'ഇന്ന് സനിമക്ക് പോയി 250 രൂപയായി'"),
                      const SizedBox(height: 10),
                      TextField(
                        controller: aiInputController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: "ചിലവ് എന്താണെന്ന് ഇവിടെ എഴുതൂ...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],

                    if (isLoading) ...[
                      const SizedBox(height: 20),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 10),
                      const Text("AI വിശകലനം ചെയ്യുന്നു..."),
                    ],

                    if (isExtracted) ...[
                      TextField(
                        controller: extractedTitleController,
                        decoration: const InputDecoration(
                          labelText: "Title",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: extractedAmountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Amount",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),

                if (!isExtracted)
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (aiInputController.text.trim().isEmpty) return;

                            setState(() => isLoading = true);

                            GroqService groq = GroqService();
                            Map<String, dynamic>? data = await groq.extractExpense(aiInputController.text.trim());

                            if (data != null) {
                              setState(() {
                                extractedTitleController.text = data['title'] ?? "";
                                extractedAmountController.text = data['amount'].toString();
                                isLoading = false;
                                isExtracted = true;
                              });
                            } else {
                              setState(() => isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("വിവരങ്ങൾ വേർതിരിച്ചെടുക്കാൻ കഴിഞ്ഞില്ല!")),
                              );
                            }
                          },
                    child: const Text("Extract"),
                  ),

                if (isExtracted)
                  ElevatedButton(
                    onPressed: () {
                      String title = extractedTitleController.text.trim();
                      double amount = double.tryParse(extractedAmountController.text.trim()) ?? 0.0;

                      if (title.isNotEmpty && amount > 0) {
                        Provider.of<ExpenseProvider>(context, listen: false).addExpense(title, amount);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Add to Expenses"),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  void clearControllers() {
    titleController.clear();
    amountController.clear();
    dateController.clear();
  }

  int getTotalExpense(List<Map<String, dynamic>> expenses) {
    int total = 0;
    for (var expense in expenses) {
      total += expense["amount"] as int;
    }
    return total;
  }

  void addNewExpense() {
    if (titleController.text.isEmpty || amountController.text.isEmpty || dateController.text.isEmpty) {
      return; 
    }
    
    String title = titleController.text.trim();
    double amount = double.tryParse(amountController.text.trim()) ?? 0.0;

    Provider.of<ExpenseProvider>(context, listen: false).addExpense(title, amount);

    clearControllers(); 
    Navigator.pop(context);
  }

  void deleteExpenseFromFirebase(String docId) {
    Provider.of<ExpenseProvider>(context, listen: false).deleteExpense(docId);
  }

  void editExpenseInFirebase(Map<String, dynamic> expense) {
    titleController.text = expense["title"];
    amountController.text = expense["amount"].toString();

    ExpenseDialogs.showEditDialog(
      context: context,
      titleController: titleController,
      amountController: amountController,
      dateController: dateController,
      onCancel: () {
        clearControllers();
        Navigator.pop(context);
      },
      onUpdate: () {
        String title = titleController.text.trim();
        double amount = double.tryParse(amountController.text.trim()) ?? 0.0;

        if (title.isNotEmpty && amount > 0) {
          Provider.of<ExpenseProvider>(context, listen: false)
              .updateExpense(expense["id"], title, amount);
          
          clearControllers();
          Navigator.pop(context);
        }
      },
    );
  }

  void showExpenseDialog() {
    ExpenseDialogs.showAddDialog(
      context: context,
      titleController: titleController,
      amountController: amountController,
      dateController: dateController,
      onAdd: () => addNewExpense(),
      onCancel: () {
        clearControllers();
        Navigator.pop(context);
      },
    );
  }

  // 🤖 AI-യോട് ചോദ്യം ചോദിക്കാനുള്ള ഫംഗ്ഷൻ
  void showAIDialog() {
    final TextEditingController aiQuestionController = TextEditingController();
    String aiResponse = "";
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("AI Assistant"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: aiQuestionController,
                      decoration: const InputDecoration(
                        hintText: "ചോദ്യം ചോദിക്കൂ...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (isLoading)
                      const CircularProgressIndicator()
                    else if (aiResponse.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(aiResponse),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (aiQuestionController.text.trim().isEmpty) return;

                          setState(() {
                            isLoading = true;
                          });

                          GroqService groq = GroqService();
                          String? response = await groq.askGroq(aiQuestionController.text.trim());

                          setState(() {
                            isLoading = false;
                            aiResponse = response ?? "മറുപടി ലഭിച്ചില്ല!";
                          });
                        },
                  child: const Text("Ask"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 🌩️ Cloud Function ടെസ്റ്റ് ചെയ്യാൻ
  Future<void> testCloudFunction() async {
    try {
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('helloExpenseManager');
      final response = await callable.call(<String, dynamic>{
        'name': 'Monu',
      });

      print("Backend Response: ${response.data}");
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.data['message'] ?? 'Response received!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error calling function: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 1. ലോക്കൽ എമുലേറ്ററിലേക്ക് ഡാറ്റ ആഡ് ചെയ്യാൻ
  Future<void> addExpenseToEmulator() async {
    try {
      await FirebaseFirestore.instance.collection('test_expenses').add({
        'title': 'Coffee',
        'amount': 20,
        'date': DateTime.now(),
      });
      print("Expense added successfully!");
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ഡാറ്റ എമുലേറ്ററിലേക്ക് ആഡ് ആയി!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      print("Error adding expense: $e");
    }
  }

  // 2. എമുലേറ്ററിലെ ഡാറ്റ വായിച്ച് എടുക്കാൻ (Fetch/Read)
  Future<void> fetchExpensesFromEmulator() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('test_expenses').get();
      
      for (var doc in snapshot.docs) {
        print("Expense Item: ${doc.data()}");
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ആകെ ${snapshot.docs.length} ഐറ്റങ്ങൾ കിട്ടി! (Console നോക്കുക)'), backgroundColor: Colors.blue),
      );
    } catch (e) {
      print("Error fetching expenses: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseProvider = Provider.of<ExpenseProvider>(context); 

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Manager"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology, color: Colors.white),
            tooltip: "Ask AI",
            onPressed: showAIDialog,
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.yellowAccent),
            tooltip: "Smart Expense AI",
            onPressed: showSmartAIDialog,
          ),
          
          // 🛑 ഇവിടെ മൂന്ന് ഡോട്ട് (Three Dots) മെനു ആക്കി മാറ്റിയിരിക്കുന്നു:
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'cloud') {
                testCloudFunction();
              } else if (value == 'add') {
                addExpenseToEmulator();
              } else if (value == 'read') {
                fetchExpensesFromEmulator();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'cloud',
                  child: Row(
                    children: [
                      Icon(Icons.cloud_queue, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Test Cloud Function'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'add',
                  child: Row(
                    children: [
                      Icon(Icons.add_task, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Add to Emulator'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'read',
                  child: Row(
                    children: [
                      Icon(Icons.storage, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Read Emulator Data'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: firebaseProvider.expensesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          List<Map<String, dynamic>> firebaseExpenses = [];
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            firebaseExpenses = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                "id": doc.id,
                "title": data["title"] ?? "",
                "amount": (data["amount"] ?? 0).toInt(),
                "date": data["timestamp"] != null 
                    ? (data["timestamp"] as Timestamp).toDate().toString().split(' ')[0]
                    : "No Date",
              };
            }).toList();
          }

          int totalAmount = getTotalExpense(firebaseExpenses);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  "Welcome, ${widget.userEmail}", 
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),

              TotalCard(totalAmount: totalAmount),
              ExpenseChart(expenses: firebaseExpenses), 

              Expanded(
                child: firebaseExpenses.isEmpty
                    ? const Center(child: Text("ചിലവുകളൊന്നും രേഖപ്പെടുത്തിയിട്ടില്ല!"))
                    : ExpenseList(
                        expenses: firebaseExpenses, 
                        onEdit: (index) {
                          editExpenseInFirebase(firebaseExpenses[index]);
                        },
                        onDelete: (index) {
                          deleteExpenseFromFirebase(firebaseExpenses[index]["id"]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showExpenseDialog, 
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}