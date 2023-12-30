import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import '../authenticate/login.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    // If the user is logged in, show the home page
    if (user != null) {
      return Home();
    } else {
      // If the user is not logged in, show the login page
      return Login();
    }
  }
}

