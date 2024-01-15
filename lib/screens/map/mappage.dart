import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/bars.dart';
import '/screens/all_incidents.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:geocoding/geocoding.dart';
import 'package:flutter/services.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../view_incident/incident_details.dart';
import '../../models/location_model.dart';
import '../home/home.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapController mapController;
  LocationModel? currentLocation;
  List<LocationModel> incidentLocations = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    //loadIncidents();
  }

  void loadIncidents() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('recent').get();
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

  void searchLocation(String query) async {
    try {
      List<Location> locationsSearch = await locationFromAddress(query);

      if (locationsSearch.isNotEmpty) {
        Location location = locationsSearch.first;
        mapController.move(
          LatLng(location.latitude, location.longitude),
          15.0,
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Location Not Found'),
            content: Text('The specified location could not be found.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } on PlatformException catch (e, _) {
      if (e.code == 'NOT_FOUND') {
        // Handle case where no coordinates are found
        print('Location not found for: $query');
      } else {
        // Handle other platform exceptions
        print('Platform exception: $e');
      }
    } catch (e) {
      // Handle other exceptions
      print('Error searching location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng(
                currentLocation?.latitude ?? 37.97967606756956,
                currentLocation?.longitude ?? 23.783193788361352,
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
                  if (currentLocation != null)
                    Marker(
                      point: LatLng(
                        currentLocation!.latitude,
                        currentLocation!.longitude,
                      ),
                      width: 15.0,
                      height: 15.0,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              Color(0xFF6750A4), // Color of the Show All button
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF6750A4).withOpacity(0.8),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 34.0,
            right: 28.0,
            child: RawMaterialButton(
              onPressed: () {
                // Clear the search bar when the button is tapped
                searchController.clear();
                // Perform other actions if needed
                getCurrentLocation();
              },
              elevation: 0,
              shape: CircleBorder(),
              fillColor: Color(0xFFE8DEF8)
                  .withOpacity(0.8), // Adjust the opacity as needed
              padding: EdgeInsets.all(12.0),
              child: Icon(Icons.my_location,
                  size: 46.0), // Adjust the size as needed
            ),
          ),
          // Positioned(
          //   bottom: 90.0,
          //   left: 28.0,
          //   child: FloatingActionButton(
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => Home(),
          //         ),
          //       );
          //     },
          //     child: Icon(Icons.home),
          //   ),
          // ),
          Positioned(
            bottom: 34.0,
            left: 28.0,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    SwipeablePageRoute(
                      builder: (context) => AllIncidents(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0),
                  backgroundColor: Color(0xFF6750A4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Text(
                  'Show All',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Container(
                width: 256.0,
                height: 39.0,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1.0,
                    color: Color(0xFFCCC2DC),
                  ),
                  borderRadius: BorderRadius.circular(30.0),
                  color: Color(0xFFCCC2DC).withOpacity(0.8),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: TextField(
                    controller: searchController,
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        searchLocation(value);
                      }
                    },
                    style: TextStyle(fontSize: 14.0),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 2.0),
                      hintText: 'Search for a location...',
                      border: InputBorder.none,
                      prefixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          if (searchController.text.isNotEmpty) {
                            searchLocation(searchController.text);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppNavigationBar(selectedIndex: 0),
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
              /*Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Placeholder()),
              );*/
              Navigator.push(
                context,
                SwipeablePageRoute(
                  builder: (context) =>
                      IncidentDetails(documentId: location.documentId ?? ""),
                ),
              );
              print(location.documentId);
            },
            //onLongPress: () {
            // Show title or any other action on long press
            //showTextLabel(context);

            //},
            child: Icon(Icons.error, color: Color(0xFFB3261E)),
          ),
        ),
      );
    });

    return MarkerLayer(markers: markers);
  }
}
