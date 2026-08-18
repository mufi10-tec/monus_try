import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:monuss_try/home_page.dart';
import 'package:monuss_try/signup_screen.dart';

// 1. StatefulWidget മാറ്റി StatelessWidget ആക്കി മാറ്റുന്നു 👈
class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 2. പഴയ bool-ന് പകരം ValueNotifier സെറ്റ് ചെയ്യുന്നു 👈
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);

  // ലോഗിൻ ഫങ്ക്ഷൻ
  Future<void> _login(BuildContext context) async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('ദയവായി ഇമെയിലും പാസ്‌വേർഡും ടൈപ്പ് ചെയ്യുക!')),
      );
      return;
    }

    // ValueNotifier-ന്റെ വാല്യൂ true ആക്കുന്നു (കറക്കം തുടങ്ങാൻ) 👈
    isLoadingNotifier.value = true;

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HomePage(userEmail: emailController.text.trim()),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ലോഗിൻ പരാജയപ്പെട്ടു: ${e.toString()}')),
        );
      }
    } finally {
      // അവസാനം വാല്യൂ false ആക്കുന്നു (കറക്കം നിർത്താൻ) 👈
      isLoadingNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              const Icon(Icons.account_balance_wallet,
                  size: 80, color: Colors.blueAccent),
              const SizedBox(height: 30),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Enter your Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Enter your password",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 30),

              // 3. ബട്ടൺ മാത്രം റീബിൽഡ് ചെയ്യാൻ ഇവിടെ ValueListenableBuilder ഉപയോഗിക്കുന്നു 👈
              ValueListenableBuilder<bool>(
                valueListenable: isLoadingNotifier,
                builder: (context, isLoading, child) {
                  return isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                          ),
                          onPressed: () => _login(
                              context), // ഫങ്ക്ഷനിലേക്ക് context പാസ്സ് ചെയ്യുന്നു
                          child: const Text("Login",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                        );
                },
              ),

              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  );
                },
                child: const Text("Don't have an account? Sign Up",
                    style: TextStyle(color: Colors.blueAccent)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
