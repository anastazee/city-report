import 'package:flutter_application_1/models/bars.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/screens/view_incident/incident_details.dart';
import 'package:intl/intl.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import './all_incidents.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Notifications extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Notifications();
  }
}

class _Notifications extends State<Notifications> {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    print('Current user: $user');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('recent')
            .where('uid', isEqualTo: user!.uid.toString() ?? '')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var incidents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: incidents.length,
            itemBuilder: (context, index) {
              return FutureBuilder(
                future: fetchIncidentData(incidents[index]),
                builder: (context,
                    AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
                  if (asyncSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  var data = asyncSnapshot.data!;
                  var title = (data['title'] ?? '').toString();

                  if (title.length > 15) {
                    title = title.substring(0, 15) + '...';
                  }

                  var likes = data['likes'];
                  var dislikes = data['dislikes'];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 75.0,
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
                                  'Your post $title got',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Text(
                                  '$likes Likes & $dislikes Dislikes.',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.2,
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
    );
  }

  Future<Map<String, dynamic>> fetchDocumentData(
      DocumentSnapshot document) async {
    var documentSnapshot = await document.reference.get();
    return documentSnapshot.data() as Map<String, dynamic>;
  }

  void sortDocumentsByDateTime(List<DocumentSnapshot> documents) {
    documents.sort((a, b) {
      var datetimeA = (a['datetime'] as Timestamp).toDate();
      var datetimeB = (b['datetime'] as Timestamp).toDate();
      return datetimeB.compareTo(datetimeA);
    });
  }

  Future<Map<String, dynamic>> fetchIncidentData(
      DocumentSnapshot document) async {
    var documentSnapshot = await document.reference.get();
    return documentSnapshot.data() as Map<String, dynamic>;
  }
}
