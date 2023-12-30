import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "../models/loginuser.dart";

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  Future<User?> signInEmailPassword(LoginUser _login) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _login.email.toString(),
        password: _login.password.toString(),
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle authentication exceptions here
      print("Error signing in: ${e.message}");
      return null;
    }
  }

  Future<User?> registerUser(LoginUser login) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: login.email.toString(),
        password: login.password.toString(),
      );
      await addDetails(login, userCredential.user?.uid);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle registration exceptions here
      print("Error registering: ${e.message}");
      return null;
    } catch (e) {
      print("Unexpected error: $e");
      return null;
    }
  }

  Future<void> addDetails(LoginUser login, String? uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'username': login.username.toString(),
      'email': login.email.toString(),
      'points': 0
    });
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      // Handle sign-out exceptions here
      print("Error signing out: $e");
    }
  }
}
