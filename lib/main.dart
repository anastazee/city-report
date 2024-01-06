import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'services/auth.dart';
import 'screens/home/wrapper.dart';
import 'screens/myposts2.dart';
import 'screens/map/mappage.dart';
import 'screens/new_incident/new_incident.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: const FirebaseOptions(apiKey:'AIzaSyDHSMiQYcbxTjeqo5A9UdejOsbMqaXY45A',appId:'1:781909190909:android:3d3bfcba13844aa9607694',messagingSenderId:'781909190909',projectId:'city-report-app'));
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    
    return StreamProvider<User?>.value(
      value: AuthService().user,
       initialData: null,
       child: MaterialApp(
              initialRoute: '/home', // Set the initial route
      routes: {
        '/map': (context) => MapPage(), // Define the 'map' route
        '/new_incident': (context) => NewIncident(), 
        '/my_posts': (context) => MyPosts(), 
      },

      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF6750A4),
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xFF6750A4),
          textTheme: ButtonTextTheme.primary,
          colorScheme:
              Theme.of(context).colorScheme.copyWith(secondary: Colors.white),
        ),
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 20.0, fontStyle: FontStyle.normal),
          bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Inter'),
        ),
        ),
      home: Wrapper(),
    ),);

  }
}