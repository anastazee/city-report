import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/services/auth.dart';
import '../models/bars.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './authenticate/login.dart';

class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Profile();
  }
}
class _Profile extends State<Profile>{

   final AuthService _auth = AuthService();
   bool _obscureText = true;
   final _username = TextEditingController();
   final _email = TextEditingController();
   final _password = TextEditingController();
   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


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
          int points = data?['points'];
          int level = points ~/ 10;
          int toNext = 10 - points%10;
          String? email = data?['email'].toString();
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
           
          final passwordField = TextFormField(
              obscureText: _obscureText,
              controller: _password,
              autofocus: false,
              validator: (val) {
                if (val != null && val != '' && val.trim().length < 8) {
                  return 'Password must be at least 8 characters in length';
                }
                return null;                // Return null if the entered password is valid
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
            minWidth: MediaQuery.of(context).size.width*0.2,
            padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            onPressed: () async {
                String username = _username.text.trim();
                String password = _password.text.trim();
                if (username.isNotEmpty){} 
                  bool taken = await isUsernameAlreadyTaken(username);
                  if (taken) {
                    ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                    content: Text('Username is already taken. Please choose a different one.'),
                    backgroundColor: Colors.red,
                    ),
                    );
                  }
                  else {
                   bool check = await updateUserData(username, password);
                   if (check) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                          content: Text('Information updated successfully!'),
                          backgroundColor: Colors.green,
                          ),
                        );
                   }
                   else {
                    ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating user data'),
                      backgroundColor: Colors.red,
                    ),
                    );
                   }
                  }
            },
            child: Text(
              "Update",
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          );        
   
   final SignOut = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Theme.of(context).primaryColor,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width*0.2,
        padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () async {
          await _auth.signOut();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Login()),
          );
        },
        child: Text(
          "Log out",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );

   return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: MyAppBar(),
      body: SingleChildScrollView(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "My Profile", textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30.0
            ),
        ),
       Form(
  autovalidateMode: AutovalidateMode.always,
  key: _formKey,
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 15.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '  Username',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            usernameField,
          ],
        ),
        const SizedBox(height: 16.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '  Password',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            passwordField,
          ],
        ),
        const SizedBox(height: 20.0),
        Text('You are registered with $email.\n',
                style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey
              ),
          ),
       Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            saveButton,
            SignOut,
          ],
        ),
        const SizedBox(height: 15.0),
      ],
    ),
  ),
),
        Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'My Statistics',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      // Colored box with more text
      Padding (
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: 
      Container(
        color: Color.fromARGB(255, 233, 190, 226),
        width: MediaQuery.of(context).size.width, // Set your desired color
        padding: const EdgeInsets.symmetric(vertical: 10.0),
child: RichText(
  text: TextSpan(
    style: TextStyle(
      color: Colors.black,
      fontSize: 22.0,
      fontWeight: FontWeight.bold,
    ),
    children: [
      TextSpan(
        text: ' Points: ',
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      TextSpan(text: '$points \n\n'),
      TextSpan(
        text: ' Level: ',
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      TextSpan(text: '$level \n\n'),
      TextSpan(
        text: ' Points to Next Level: ',
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      TextSpan(text: '$toNext'),
    ],
  ),
),
        ),
      ),
      ],
    ),
      ),
    bottomNavigationBar: AppNavigationBar(selectedIndex: -1),
    );
} else {
    // Handle the case when there is no data
    return Text('No data available');
  }
   }
  );

   }


  
}