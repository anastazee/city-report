/*import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/bars.dart';
import "package:location/location.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/incident.dart';
import 'package:flutter_application_1/services/queries.dart';

class NewIncident extends StatefulWidget {
  @override
  _NewIncidentState createState() => _NewIncidentState();
}

class _NewIncidentState extends State<NewIncident> {
  final _incidentTitleController = TextEditingController();
  final _incidentDescriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  GeoPoint? _currentLocation;
  Location location = Location();

  User? user = FirebaseAuth.instance.currentUser;
  String? _currentUsername;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getCurrentUsername();
  }

  GeoPoint? _geoPointFromLocationData(LocationData? locationData) {
    if (locationData != null) {
      return GeoPoint(
          locationData.latitude ?? 0.0, locationData.longitude ?? 0.0);
    }
    return null;
  }

  _getCurrentLocation() async {
    try {
      var currentLocation = await location.getLocation();
      setState(() {
        _currentLocation = _geoPointFromLocationData(currentLocation);
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  _getCurrentUsername() async {
    try {
      String? currentUsername = await getUsernameFromEmail(user?.email ?? '');
      setState(() {
        _currentUsername = currentUsername;
      });
    } catch (e) {
      print('Error getting username: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _incidentTitleController,
                decoration: InputDecoration(labelText: 'Incident Title'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _incidentDescriptionController,
                decoration: InputDecoration(labelText: 'Incident Description'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Text(
                'Current Location: ${_currentLocation?.latitude ?? ''}, ${_currentLocation?.longitude ?? ''}',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    IncidentDetails incidentDetails = IncidentDetails(
                      datetime: Timestamp.now(),
                      description: _incidentDescriptionController.text,
                      location: _currentLocation,
                      title: _incidentTitleController.text,
                      username: _currentUsername,
                    );

                    await FirebaseFirestore.instance
                        .collection('recent')
                        .add({
                      'datetime': incidentDetails.datetime,
                      'description': incidentDetails.description,
                      'location': incidentDetails.location,
                      'title': incidentDetails.title,
                      'username': incidentDetails.username,
                      'likes': 0,
                      'dislikes': 0,
                    });
                  }
                },
                child: const Text('AddIncident'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppNavigationBar(selectedIndex: 1),
    );
  }
}
*/

// new_incident.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter_application_1/models/bars.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/incident.dart';
import 'package:flutter_application_1/services/queries.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import './camerapage.dart'; // Import the CameraPage
import 'package:flutter/foundation.dart' show kIsWeb;

class NewIncident extends StatefulWidget {
  @override
  _NewIncidentState createState() => _NewIncidentState();
}

class _NewIncidentState extends State<NewIncident> {
  final _incidentTitleController = TextEditingController();
  final _incidentDescriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _image;

  GeoPoint? _currentLocation;
  Location location = Location();
  User? user = FirebaseAuth.instance.currentUser;
  String? _currentUsername;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getCurrentUsername();
  }

  GeoPoint? _geoPointFromLocationData(LocationData? locationData) {
    if (locationData != null) {
      return GeoPoint(
          locationData.latitude ?? 0.0, locationData.longitude ?? 0.0);
    }
    return null;
  }

  _getCurrentLocation() async {
    try {
      var currentLocation = await location.getLocation();
      setState(() {
        _currentLocation = _geoPointFromLocationData(currentLocation);
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  _getCurrentUsername() async {
    try {
      String? currentUsername = await getUsernameFromEmail(user?.email ?? '');
      setState(() {
        _currentUsername = currentUsername;
      });
    } catch (e) {
      print('Error getting username: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Incident'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _incidentTitleController,
                  decoration: InputDecoration(labelText: 'Incident Title'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _incidentDescriptionController,
                  decoration:
                      InputDecoration(labelText: 'Incident Description'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Current Location: ${_currentLocation?.latitude ?? ''}, ${_currentLocation?.longitude ?? ''}',
                  style: TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    final String? capturedImageURL = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CameraPage()),
                    );

                    if (capturedImageURL != null) {
                      setState(() {
                        _image = File(capturedImageURL);
                      });
                    }
                  },
                  child: const Text('Take Picture'),
                ),
                Column(
                  children: [
                    if (_image != null) SizedBox(height: 16.0),
                    _image != null
                        ? kIsWeb
                            ? Image.network(_image!.path)
                            : Image.file(_image!)
                        : Container(), // or some placeholder widget
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      if (_image != null) {
                        IncidentDetails incidentDetails = IncidentDetails(
                          datetime: Timestamp.now(),
                          description: _incidentDescriptionController.text,
                          location: _currentLocation,
                          title: _incidentTitleController.text,
                          username: _currentUsername,
                          imageURL: _image != null ? _image!.path : null,
                        );

                        print('Image URL: ${incidentDetails.imageURL}');
                        await FirebaseFirestore.instance
                            .collection('recent')
                            .add({
                          'datetime': incidentDetails.datetime,
                          'description': incidentDetails.description,
                          'location': incidentDetails.location,
                          'title': incidentDetails.title,
                          'username': incidentDetails.username,
                          'likes': 0,
                          'dislikes': 0,
                          'imageURL': incidentDetails.imageURL,
                        });

                        // Reset the image file after adding the incident
                        setState(() {
                          _image = null;
                        });
                      }

                      Navigator.pop(context); // Go back to the previous page
                    }
                  },
                  child: const Text('Add Incident'),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppNavigationBar(selectedIndex: -1),
    );
  }
}
