import 'package:flutter_application_1/models/loginuser.dart';
import 'package:flutter_application_1/services/auth.dart';
import 'package:flutter/material.dart';
import '../home/home.dart';
import './register.dart';

class Login extends StatefulWidget {
  final Function? toggleView;
  Login({this.toggleView});

  @override
  State<StatefulWidget> createState() {
    return _Login();
  }
}

class _Login extends State<Login> {
  bool _obscureText = true;

  final _email = TextEditingController();
  final _password = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
        controller: _email,
        autofocus: false,
        validator: (value) {
          if (value != null) {
            if (value.contains('@') && value.endsWith('.com')) {
              return null;
            }
            return 'Enter a Valid Email Address';
          }
          return 'This field is required';
        },
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "Email",
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))));

    final passwordField = TextFormField(
        obscureText: _obscureText,
        controller: _password,
        autofocus: false,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'This field is required';
          }
          // Return null if the entered password is valid
          return null;
        },
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "Password",
            suffixIcon: IconButton(
              icon:
                  Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
            )));

    final register = Material(
      elevation: 0.0,
      borderRadius: BorderRadius.circular(5.0),
      color: Color.fromARGB(255, 232, 222, 255),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width * 0.1, // Adjust the factor to your liking
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 7.0),
        onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Register()), // Replace Register() with the actual Register widget
    );
  },
  child: const Text('Register here'),
));

    
    final loginButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Theme.of(context).primaryColor,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            dynamic result = await _auth.signInEmailPassword(LoginUser(email: _email.text, password: _password.text));
            if (result != null && result.uid != null) { // Successful authentication
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Home()), 
              );
            } else {
              showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(result != null ? result.code : "You are not registerd"),
              );
                },
              );
            }
          }
},
        child: Text(
          "Log in",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30.0),
        Container(
        color: Color.fromARGB(255, 232, 222, 255), // Set the desired color for the box
        padding: EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 25.0), // Add top padding
        child: Text(
          'City \nReport',
          style: TextStyle(
            color: Colors.black, // Set the text color
            fontSize: 36.0,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      SizedBox(height: 20.0),
    Text(
      'Log In',
            style: TextStyle(
            color: Colors.black, // Set the text color
            fontSize: 20.0,
            fontWeight: FontWeight.normal,
          ),
          ),
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  emailField,
                  const SizedBox(height: 25.0),
                  passwordField,
                  const SizedBox(height: 25.0),
                  loginButton,
                  const SizedBox(height: 15.0),
                ],
              ),
            ),
          ),
          Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account ?",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(width: 20.0),
            register,
          ],
        ),
        const SizedBox(height: 25.0),
        ],
      ),
    );
  }
}