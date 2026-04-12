import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import 'login.dart';
import 'welcome_user.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  // Load user data from Firestore and set it globally
  Future<void> _loadUser(User user) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();

    WelcomeUser.currentUser = AppUser.creation(
      user.uid,
      user.email,
      data?['fullName'] ?? '',
      data?['age']?.toString() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ⏳ Waiting for Firebase auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        
        if (snapshot.hasData) {
          return FutureBuilder(
            future: _loadUser(snapshot.data!),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              
              return const WelcomeUser();
            },
          );
        }

        
        return const Login();
      },
    );
  }
}
