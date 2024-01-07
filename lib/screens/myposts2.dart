import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/bars.dart';
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
            appBar: MyAppBar(),
            
            body: Center(
              child: CircularProgressIndicator(),
            ),
            bottomNavigationBar: AppNavigationBar(selectedIndex: 2,),
          );
        } else if (snapshot.hasData) {
          Map<String, dynamic>? userData = snapshot.data;

          return Scaffold(
            appBar: MyAppBar(),
            body: buildStream('incidents', userData),
            bottomNavigationBar: AppNavigationBar(selectedIndex: 2),
          );
        } else {
          return Scaffold(
            appBar: MyAppBar(),
            body: Center(
              child: Text('No data available'),
            ),
            bottomNavigationBar: AppNavigationBar(selectedIndex: 2),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0), // Adjust vertical padding
      child: Container(
        width: 250.0, // Adjust the overall width of the list tiles
        height: 75.0,
        decoration: BoxDecoration(
          color: Color(0xFFF7F2FA),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 8.0, // Add some spacing between the left edge and the content
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder(
                future: fetchDocumentData(combinedList[index]),
                builder: (context, AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
                  if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var data = asyncSnapshot.data!;
                  var title = data['title'] ?? '';
                  var timestamp = data['datetime'] as Timestamp;
                  var datetime = timestamp.toDate();
                  String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm').format(datetime);

                  return Column(
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
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),),
            Container(
              width: 60.0,
              height: 33.75,
              decoration: BoxDecoration(
                color: Color(0xFF6750A4),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0), // Add padding to the right
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IncidentDetails(
                            documentId: combinedList[index].id,
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
          ],
        ),
      ),
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
