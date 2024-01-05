import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/screens/view_incident/incident_details.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

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
    print('Current user: $user');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('My Posts'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasData) {
          Map<String, dynamic>? userData = snapshot.data;

          return Scaffold(
            appBar: AppBar(
              title: Text('My Posts'),
            ),
            body: buildStream('incidents', userData),
          );
        } else {
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

  StreamBuilder<List<QuerySnapshot<Map<String, dynamic>>>> buildStream(
    String collection, Map<String, dynamic>? userData) {
    final Stream<QuerySnapshot<Map<String, dynamic>>> incidentsStream =
        FirebaseFirestore.instance
            .collection(collection)
            .where('username', isEqualTo: userData?['username'].toString() ?? '')
            .snapshots();

    final Stream<QuerySnapshot<Map<String, dynamic>>> recentStream =
        FirebaseFirestore.instance
            .collection('recent')
            .where('username', isEqualTo: userData?['username'].toString() ?? '')
            .snapshots();

      final mergedStream = Rx.combineLatest2(
    incidentsStream,
    recentStream,
    (QuerySnapshot<Map<String, dynamic>> incidents, QuerySnapshot<Map<String, dynamic>> recent) {
      return [incidents, recent];
    },
  );


    return StreamBuilder<List<QuerySnapshot<Map<String, dynamic>>>>(
      stream: mergedStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        var incidents = snapshot.data![0];
        var recent = snapshot.data![1];

        var combinedList = [...incidents.docs, ...recent.docs];

        sortDocumentsByDateTime(combinedList);

        return ListView.builder(
          itemCount: combinedList.length,
          itemBuilder: (context, index) {
            return FutureBuilder(
              future: fetchDocumentData(combinedList[index]),
              builder: (context, AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                var data = asyncSnapshot.data!;
                var title = data['title'] ?? '';
                var documentId = combinedList[index].id;
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
                          builder: (context) => IncidentDetails(
                            documentId: documentId,
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
    );
  }

  Future<Map<String, dynamic>> fetchDocumentData(DocumentSnapshot document) async {
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

  Future<Map<String, dynamic>?> getUserData() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
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
