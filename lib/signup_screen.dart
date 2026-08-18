import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// 1. StatefulWidget മാറ്റി StatelessWidget ആക്കുന്നു 👈
class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  // 2. രജിസ്റ്റർ ചെയ്യുമ്പോൾ ബട്ടൺ മാത്രം കറങ്ങാൻ ValueNotifier സെറ്റ് ചെയ്യുന്നു 👈
  final ValueNotifier<bool> isRegisteringNotifier = ValueNotifier<bool>(false);

  // സൈൻ അപ്പ് ഫങ്ക്ഷൻ
  Future<void> _signUp(BuildContext context) async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('ദയവായി ഇമെയിലും പാസ്‌വേർഡും ടൈപ്പ് ചെയ്യുക!')),
      );
      return;
    }

    // ലോഡിംഗ് സ്റ്റാർട്ട് ചെയ്യുന്നു
    isRegisteringNotifier.value = true;

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('അക്കൗണ്ട് വിജയകരമായി ഉണ്ടാക്കി!')),
        );
        Navigator.pop(
            context); // രജിസ്റ്റർ ആയിക്കഴിഞ്ഞാൽ ലോഗിൻ പേജിലേക്ക് തിരിച്ചു പോകാൻ
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      // ലോഡിംഗ് നിർത്തുന്നു
      isRegisteringNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              const Icon(Icons.person_add, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 30),

              // 3. രജിസ്റ്റർ ബട്ടൺ മാത്രം റീബിൽഡ് ചെയ്യാൻ ValueListenableBuilder 👈
              ValueListenableBuilder<bool>(
                valueListenable: isRegisteringNotifier,
                builder: (context, isRegistering, child) {
                  return isRegistering
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                          ),
                          onPressed: () => _signUp(
                              context), // ഫങ്ക്ഷനിലേക്ക് context പാസ്സ് ചെയ്യുന്നു
                          child: const Text('Register',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
