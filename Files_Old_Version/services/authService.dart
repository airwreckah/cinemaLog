import 'package:cinema_log/models/app_user.dart';
import 'package:cinema_log/screens/welcome_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cinema_log/main.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  //Need to figure out how to make sure the user is added to the collection
  Future<AppUser> signUp(
    String email,
    String password,
    String age,
    String fullName,
  ) async {
    //put code to hash password here
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    final userAccount = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    User? user = userAccount.user;
    String? uid = user?.uid;
    await users.doc(uid).set({
      'age': age,
      'email': email,
      'fullName': fullName,
    });
    AppUser currentUser = AppUser.creation(uid, email, fullName, age);
    WelcomeUser.currentUser = currentUser;
    return currentUser;
  }
}
