import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ⚠️ നിങ്ങളുടെ ഹോം പേജ്, ലോഗിൻ പേജ് ഇമ്പോർട്ടുകൾ ഇവിടെ മാറ്റുക
import 'home_page.dart'; 
import 'login_page.dart'; 

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // ഫയർബേസ് ലോഗിൻ സ്റ്റാറ്റസ് എപ്പോഴും ചെക്ക് ചെയ്യും
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ഡാറ്റ ലോഡ് ചെയ്തുകൊണ്ടിരിക്കുമ്പോൾ
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // യൂസർ ലോഗിൻ ആണെങ്കിൽ direct Home Page-ലേക്ക് വിടും
        if (snapshot.hasData) {
          return HomePage(userEmail: snapshot.data?.email ?? "User",);
        }

        // ലോഗിൻ അല്ലെങ്കിൽ മാത്രം Login Page കാണിക്കും
        return  LoginPage(); // 👈 നിങ്ങളുടെ ലോഗിൻ പേജിന്റെ പേര്
      },
    );
  }
}