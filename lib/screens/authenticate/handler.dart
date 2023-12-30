import 'package:flutter_application_1/screens/authenticate/login.dart';
import 'package:flutter_application_1/screens/authenticate/register.dart';
import 'package:flutter/material.dart';

class Handler extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Handler();
  }
}

class _Handler extends State<Handler> {

  bool showSignin = true;

  void toggleView(){
    setState(() {
      showSignin = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(showSignin)
    {
       return Login(toggleView : toggleView);
    }else
    {
      return Register(toggleView : toggleView);
    }
  }
}