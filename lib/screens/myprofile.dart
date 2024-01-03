import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/bars.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Profile();
  }
}
class _Profile extends State<Profile>{

   bool _obscureText = true;
   final _username = TextEditingController();
   final _email = TextEditingController();
   final _password = TextEditingController();
   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static Future<Map<String, dynamic>?> getUserData() async {
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
    @override
   Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while the data is being fetched
          return const CircularProgressIndicator();
        } else if (snapshot.hasData) {
          // Data has been successfully fetched
          Map<String, dynamic>? data = snapshot.data;

          // Your existing TextFormField with the retrieved username
          final usernameField = TextFormField(
            controller: _username,
            autofocus: false,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              hintText: data?['username'].toString() ?? '', // Use null-aware operator to handle null case
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32.0),
              ),
            ),
          );

          final emailField = TextFormField(
                controller: _email,
                autofocus: false,
                validator: (value) {
                  if (value != null && !value.contains('@') && !value.endsWith('.com')) {
                      return 'Enter a Valid Email Address';
                    }
                    return null;
                  },
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    hintText: data?['email'].toString(),
                    border:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))));

          final passwordField = TextFormField(
              obscureText: _obscureText,
              controller: _password,
              autofocus: false,
              validator: (val) {
                if (val != null && val.trim().length < 8) {
                  return 'Password must be at least 8 characters in length';
                }
                                // Return null if the entered password is valid
                return null;
              } ,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  hintText: 'password',
                   suffixIcon: IconButton(icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                  onPressed: (){
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },),
                  border:
                          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))));
              
          final saveButton = Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(30.0),
          color: Theme.of(context).primaryColor,
          child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            onPressed: () async {
                updateUserData();
            },
            child: Text(
              "Update",
              style: TextStyle(color: Theme.of(context).primaryColorLight),
              textAlign: TextAlign.center,
            ),
          ),
          );        
   
   return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: MyAppBar(),
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Form(
          autovalidateMode: AutovalidateMode.always,
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 45.0),
                emailField,
                const SizedBox(height: 45.0),
                usernameField,
                const SizedBox(height: 25.0),
                passwordField,
                const SizedBox(height: 25.0),
                saveButton,
                const SizedBox(height: 15.0),
              ],
            ),
          ),
        ),
      ],
    ),
    );
} else {
    // Handle the case when there is no data
    return Text('No data available');
  }
   }
  );

   }
   Future<void> updateUserData() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    // Check if username, email, and password are not null or empty
    try {
    if (_username.text != null && _username.text.trim().isNotEmpty) {
      await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'username': _username.text,
          // You may want to add additional checks or validations for the password
        });

    }
    if (_email.text != null && _email.text.trim().isNotEmpty) {
      await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'email': _email.text});
    }
    if (_password.text != null && _password.text.trim().isNotEmpty) {
        await user.updatePassword(_password.text);
    }
    print('User data updated successfully!');
    } catch (error) {
        // Handle errors
        print('Error updating user data: $error');
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating user data: $error'),
          duration: Duration(seconds: 3),
        ),
      );
      }
  } else {
    print('User not logged in');
  }
} 
}