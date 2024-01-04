import 'package:flutter_application_1/models/loginuser.dart';
import 'package:flutter_application_1/services/auth.dart';
import 'package:flutter/material.dart';
import './login.dart';


class Register extends StatefulWidget{

  final Function? toggleView;
   Register({this.toggleView});

   @override
  State<StatefulWidget> createState() {
    return _Register();
  }
}

class _Register extends State<Register>{
  final AuthService _auth = AuthService();

  bool _obscureText = true;
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
  
  final usernameField = TextFormField(
        controller: _username,
        autofocus: false,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'This field is required';
          }
          return null;
        },
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "Username",
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))));


  final emailField = TextFormField(
        controller: _email,
        autofocus: false,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'This field is required';
          }
          if (value.contains('@') && value.endsWith('.com')) {
              return null;
            }
            return 'Enter a Valid Email Address';
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
          if (value.trim().length < 8) {
            return 'Password must be at least 8 characters in length';
          }
                          // Return null if the entered password is valid
          return null;
        } ,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "Password",
             suffixIcon: IconButton(icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
            onPressed: (){
              setState(() {
                _obscureText = !_obscureText;
              });
            },),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))));

    final txtbutton = TextButton(
        onPressed: () {
        Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Login()), // Replace Register() with the actual Register widget
    );
        },
        child: const Text('Go to login'));

    final registerButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Theme.of(context).primaryColor,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            bool isUsernameTaken = await isUsernameAlreadyTaken(_username.text);

          if (isUsernameTaken) {
            // Display an error message to the user
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Username is already taken. Please choose a different one.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          else {
            dynamic result = await _auth.registerUser(LoginUser(username: _username.text, email: _email.text,password: _password.text));
            if (result.uid == null) { //null means unsuccessfull authentication
              showDialog(
                context: context,
                builder: (context) {
                return AlertDialog(
                content: Text(result.code),
                );
                });
            }
            else {
              ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Registration completed succcessfully'),
                backgroundColor: Colors.green,
              ),
            );
            }
          }
          }
        },
        child: Text(
          "Create Account",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  
  
  
   return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: const Text('City Report', textAlign: TextAlign.center,),
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 227, 186, 220),
        ),
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Welcome!\n You can create your account right below!", textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,),
            ),
        Form(
          autovalidateMode: AutovalidateMode.always,
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                usernameField,
                const SizedBox(height: 25.0),
                passwordField,
                const SizedBox(height: 25.0),
                emailField,
                const SizedBox(height: 25.0),
                registerButton,
                const SizedBox( height: 35.0),
                txtbutton,
                const SizedBox(height: 15.0),
              ],
            ),
          ),
        ),
      ],
    ),
    );
  }
}