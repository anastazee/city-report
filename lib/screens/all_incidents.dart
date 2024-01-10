import 'package:flutter_application_1/models/bars.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/screens/view_incident/incident_details.dart';
import 'package:intl/intl.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

/*class AllIncidents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Incident List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('incidents').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          var incidents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: incidents.length,
            itemBuilder: (context, index) {
              return FutureBuilder(
                future: fetchIncidentData(incidents[index]),
                builder: (context, AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
                  if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  var data = asyncSnapshot.data!;

                  // Extracting the title and datetime
                  var title = data['title'] ?? '';
                  var docid = incidents[index].id;
var timestamp = data['datetime'] as Timestamp;
var datetime = timestamp.toDate();
String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm').format(datetime);
                  return ListTile(
  title: Text('$title'),
  subtitle: Text('${formattedDateTime}'),
  trailing: TextButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IncidentDetails(documentId: docid),
        ),
      );
    },
    child: Text('More'),
  ),
);


                },
              );
            },
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> fetchIncidentData(DocumentSnapshot document) async {
    var documentSnapshot = await document.reference.get();
    return documentSnapshot.data() as Map<String, dynamic>;
  }
}
*/

class AllIncidents extends StatefulWidget {
  @override
  _AllIncidentsState createState() => _AllIncidentsState();
}

class _AllIncidentsState extends State<AllIncidents> {
  bool sortByProximity = false;
  Position? userLocation;

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

Future<void> getUserLocation() async {
  try {
    Position position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        userLocation = position;
      });
    }
  } catch (e) {
    print("Error getting user's location: $e");
  }
}


    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('recent').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var incidents = snapshot.data!.docs;

          sortByProximity
              ? sortIncidentsByProximity(incidents)
              : sortIncidentsByDateTime(incidents);

          return ListView.builder(
            itemCount: incidents.length,
            itemBuilder: (context, index) {
              return FutureBuilder(
                future: fetchIncidentData(incidents[index]),
                builder: (context, AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
                  if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  var data = asyncSnapshot.data!;
                  var title = data['title'] ?? '';
                  var docid = incidents[index].id;
                  var timestamp = data['datetime'] as Timestamp;
                  var datetime = timestamp.toDate();
                  String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm').format(datetime);

                  var proximity = '';
                  if (sortByProximity) {
                    var geopoint = data['location'] as GeoPoint?;
                    var incidentLocation =
                        geopoint != null ? Location1(geopoint.latitude, geopoint.longitude) : null;

                    if (incidentLocation != null) {
                      var distance = Geolocator.distanceBetween(
                        userLocation!.latitude,
                        userLocation!.longitude,
                        incidentLocation.latitude,
                        incidentLocation.longitude,
                      );

                      proximity = '${(distance/1000).toStringAsFixed(2)} km away';
                    } else {
                      proximity = 'Proximity: N/A';
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 90.0,
                      decoration: BoxDecoration(
                        color: Color(0xFFF7F2FA),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 8.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$title',
                                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '$formattedDateTime',
                                  style: TextStyle(fontSize: 14.0),
                                ),
                                if (sortByProximity) Text(proximity,style: TextStyle(fontSize: 12.0),),
                              ],
                            ),
                          ),
                          Spacer(),
                          Container(
                      width: 60.0,
                      height: 33.75,
                      decoration: BoxDecoration(
                        color: Color(0xFF6750A4),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5.0), // Add padding to the right
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                SwipeablePageRoute(
                                  builder: (context) => IncidentDetails(
                                    documentId: incidents[index].id,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'More',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                            width: 8.0,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: AppNavigationBar(selectedIndex: -1),
      floatingActionButton: _buildSortButton(),
    );
  }


  Widget _buildSortButton() {
    return FloatingActionButton(
      onPressed: () {
        _showSortOptions();
      },
      child: Text("Sort by"),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Sort by Time'),
                onTap: () {
                  setState(() {
                    sortByProximity = false;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Sort by Proximity'),
                onTap: () {
                  setState(() {
                    sortByProximity = true;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> fetchIncidentData(DocumentSnapshot document) async {
    var documentSnapshot = await document.reference.get();
    return documentSnapshot.data() as Map<String, dynamic>;
  }

  void sortIncidentsByDateTime(List<DocumentSnapshot> incidents) {
    incidents.sort((a, b) {
      var datetimeA = (a['datetime'] as Timestamp).toDate();
      var datetimeB = (b['datetime'] as Timestamp).toDate();
      return datetimeB.compareTo(datetimeA);
    });
  }


  void sortIncidentsByProximity(List<DocumentSnapshot> incidents) {
    if (userLocation != null) {
      incidents.sort((a, b) {
        var geopointA = (a['location'] as GeoPoint?);
        var incidentLocationA = geopointA != null ? Location1(geopointA.latitude, geopointA.longitude) : null;

        var geopointB = (b['location'] as GeoPoint?);
        var incidentLocationB = geopointB != null ? Location1(geopointB.latitude, geopointB.longitude) : null;

        // Handle cases where location is null
        if (incidentLocationA == null && incidentLocationB == null) {
          return 0;
        } else if (incidentLocationA == null) {
          return 1; // Place incidents with null location at the end
        } else if (incidentLocationB == null) {
          return -1; // Place incidents with null location at the end
        }

        // Calculate distance and sort by proximity
        var distanceA = Geolocator.distanceBetween(
          userLocation!.latitude,
          userLocation!.longitude,
          incidentLocationA.latitude,
          incidentLocationA.longitude,
        );

        var distanceB = Geolocator.distanceBetween(
          userLocation!.latitude,
          userLocation!.longitude,
          incidentLocationB.latitude,
          incidentLocationB.longitude,
        );

        return distanceA.compareTo(distanceB);
      });

    }
  }
}

class Location1 {
  final double latitude;
  final double longitude;

  Location1(this.latitude, this.longitude);
}
