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

Future<bool> isUsernameAlreadyTaken(String username) async {
  try {
    // Reference to the 'users' collection in Firestore
    CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

    // Query Firestore to check if the provided username already exists
    QuerySnapshot querySnapshot = await usersCollection.where('username', isEqualTo: username).get();

    // If there are any documents with the given username, it's already taken
    return querySnapshot.docs.isNotEmpty;
  } catch (e) {
    // Handle any potential errors, e.g., connection issues, etc.
    print("Error checking username availability: $e");
    return true; // Consider it as taken to be on the safe side
  }
}

Future<Map<String, dynamic>?> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        Map<String, dynamic> userData =
            userDoc.data() as Map<String, dynamic>;
            return userData;
      }
      else print("error user does not exist in db");
      return null;
    }
    else print("error user not logged in");
    return null;
  }

  Future<bool> updateUserData(String username, String password) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {

    try {
    if (username.isNotEmpty) {
      await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'username': username,
             });

    }
    if (password.isNotEmpty) {
        await user.updatePassword(password);
    }
    print('User data updated successfully!');
    return true;

    } catch (error) {
        // Handle errors
        print('Error updating user data: $error');
        return false;
    }
  } 
  else {
    print('User not logged in');
    return false;
  }
} 