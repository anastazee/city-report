import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: const Text('New Incident'),
      ),
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
                        .collection('incidents')
                        .add({
                      'datetime': incidentDetails.datetime,
                      'description': incidentDetails.description,
                      'location': incidentDetails.location,
                      'title': incidentDetails.title,
                      'username': incidentDetails.username,
                    });
                  }
                },
                child: const Text('AddIncident'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
