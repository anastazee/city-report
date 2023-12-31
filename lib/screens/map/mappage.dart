import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

import '../../models/location_model.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapController mapController;
  LocationModel? currentLocation;
  List<LocationModel> incidentLocations =
      []; // List to store incident locations

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    loadIncidents();
  }

  void loadIncidents() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('incidents').get();
    List<LocationModel> locations = [];

    snapshot.docs.forEach((doc) {
      GeoPoint? geoPoint = doc.get('location');

      if (geoPoint != null) {
        double latitude = geoPoint.latitude;
        double longitude = geoPoint.longitude;
        String documentId = doc.id; // Get the document ID

        locations.add(LocationModel(
          latitude: latitude,
          longitude: longitude,
          documentId: documentId,
        ));
      } else {
        print("Invalid or missing 'location' field in the document");
      }
    });

    setState(() {
      incidentLocations = locations;
    });
  }

  void getCurrentLocation() async {
    loadIncidents();
    print("ha");
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Location Service Disabled'),
          content: Text('Please enable location services.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Location Permission Denied'),
            content: Text('Please grant location permission.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      currentLocation = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      mapController.move(
        LatLng(currentLocation!.latitude, currentLocation!.longitude),
        15.0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    print("wtf");
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Map Demo'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(
                  currentLocation?.latitude ?? 0.0,
                  currentLocation?.longitude ?? 0.0,
                ),
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                Markers(locations: incidentLocations),
                MarkerLayer(
                  markers: [
                    if (currentLocation != null) // Add null check
                      Marker(
                        point: LatLng(
                          currentLocation!.latitude,
                          currentLocation!.longitude,
                        ),
                        child: Icon(Icons.location_on, color: Colors.red),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                getCurrentLocation();
              },
              child: Text('Get Location'),
            ),
          ),
        ],
      ),
    );
  }
}

class Markers extends StatelessWidget {
  Markers({
    super.key,
    required this.locations,
  });

  final List<LocationModel> locations;

  @override
  Widget build(BuildContext context) {
    print("mark prob");

    List<Marker> markers = [];

    // Add markers for each location in the list
    locations.forEach((location) {
      markers.add(
        Marker(
          point: LatLng(location.latitude, location.longitude),
          child: GestureDetector(
            onTap: () {
              // Navigate to the placeholder page on short tap
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Placeholder()),
              );
              print(location.documentId);
            },
            //onLongPress: () {
            // Show title or any other action on long press
            //showTextLabel(context);

            //},
            child: Icon(Icons.location_on),
          ),
        ),
      );
    });

    return MarkerLayer(markers: markers);
  }
}
