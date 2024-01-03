import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/screens/view_incident/incident_details.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyPosts extends StatefulWidget {
  @override
  _MyPostsState createState() => _MyPostsState();
}

class _MyPostsState extends State<MyPosts> {
  late User? user;
  late String? _currentUsername;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    print('Current user: $user'); // Add this line to check the user
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for user data
          return Scaffold(
            appBar: AppBar(
              title: Text('My Posts'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasData) {
          Map<String, dynamic>? data = snapshot.data;

          return Scaffold(
            appBar: AppBar(
        title: Text('My Posts'),
      ),
            body: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('incidents')
                  .where('username', isEqualTo: data?['username'].toString() ?? '')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: SizedBox(
                      width: 40.0,
                      height: 40.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                      ),
                    ),
                  );
                }

                var incidents = snapshot.data!.docs;

                // Sort the incidents by datetime
                sortIncidentsByDateTime(incidents);

                return ListView.builder(
                  itemCount: incidents.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder(
                      future: fetchIncidentData(incidents[index]),
                      builder: (context,
                          AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
                        if (asyncSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        var data = asyncSnapshot.data!;

                        // Extracting the title and datetime
                        var title = data['title'] ?? '';
                        var docid = incidents[index].id;
                        var timestamp = data['datetime'] as Timestamp;
                        var datetime = timestamp.toDate();
                        String formattedDateTime =
                            DateFormat('yyyy-MM-dd HH:mm').format(datetime);

                        return ListTile(
                          title: Text('$title'),
                          subtitle: Text('${formattedDateTime}'),
                          trailing: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => IncidentDetails(
                                    documentId: docid,
                                  ),
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
        } else {
          // Handle the case where data is not available
          return Scaffold(
            appBar: AppBar(
              title: Text('My Posts'),
            ),
            body: Center(
              child: Text('No data available'),
            ),
          );
        }
      },
    );
  }

  Future<Map<String, dynamic>> fetchIncidentData(
      DocumentSnapshot document) async {
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

  Future<Map<String, dynamic>?> getUserData() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        print("Error: User does not exist in the database");
        return null;
      }
    } else {
      print("Error: User not logged in");
      return null;
    }
  }
}
