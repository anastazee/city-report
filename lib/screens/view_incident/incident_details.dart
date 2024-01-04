/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IncidentDetailsScreen extends StatelessWidget {
  final String documentId;

  IncidentDetailsScreen({required this.documentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Incident Details'),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('incidents').doc(documentId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          // Extract incident details from snapshot
          var incidentData = snapshot.data?.data();

          // Convert Timestamp to DateTime
          DateTime datetime = incidentData?['datetime']?.toDate() ?? DateTime.now();

          // Format DateTime as a string
          String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(datetime);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title: ${incidentData?['title']}'),
                Text('Date and Time: $formattedDateTime'),
                Text('Location: ${incidentData?['location']}'),
                Text('Username: ${incidentData?['username']}'),
                Text('Description: ${incidentData?['description']}'),
                // Add more details as needed
              ],
            ),
          );
        },
      ),
    );
  }
}
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
/*
class IncidentDetails extends StatelessWidget {
  final String documentId;

  IncidentDetails({required this.documentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Incident Details'),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('incidents').doc(documentId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Extract incident details from snapshot
          var incidentData = snapshot.data?.data();

          // Convert Timestamp to DateTime
          DateTime datetime = incidentData?['datetime']?.toDate() ?? DateTime.now();

          // Format DateTime as a string
          String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(datetime);

          // Extract latitude and longitude from GeoPoint
          String locationString = incidentData?['location'] != null
              ? 'Latitude: ${incidentData!['location'].latitude.toStringAsFixed(4)}, Longitude: ${incidentData['location'].longitude.toStringAsFixed(4)}'
              : 'N/A';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (incidentData?['title'] != null) Text('Title: ${incidentData!['title']}'),
                if (incidentData?['datetime'] != null) Text('Date and Time: $formattedDateTime'),
                if (incidentData?['location'] != null) Text('Location: $locationString'),
                if (incidentData?['username'] != null) Text('Username: @${incidentData!['username']}'),
                if (incidentData?['description'] != null) ...[
                  Text('Description:'),
                  Text(incidentData!['description']),
                ],
                // Add more details as needed
              ],
            ),
          );
        },
      ),
    );
  }
}
*/

class IncidentDetails extends StatefulWidget {
  final String documentId;

  IncidentDetails({required this.documentId});

  @override
  _IncidentDetailsState createState() => _IncidentDetailsState();
}

class _IncidentDetailsState extends State<IncidentDetails> {
  int likes = 0;
  int dislikes = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Incident Details'),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('incidents')
            .doc(widget.documentId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var incidentData = snapshot.data?.data();

          DateTime datetime =
              incidentData?['datetime']?.toDate() ?? DateTime.now();

          String formattedDateTime =
              DateFormat('yyyy-MM-dd HH:mm:ss').format(datetime);

          String locationString = incidentData?['location'] != null
              ? 'Latitude: ${incidentData!['location'].latitude.toStringAsFixed(4)}, Longitude: ${incidentData['location'].longitude.toStringAsFixed(4)}'
              : 'N/A';

          int initialLikes = incidentData?['likes'] ?? 0;
          int initialDislikes = incidentData?['dislikes'] ?? 0;

          likes = initialLikes;
          dislikes = initialDislikes;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (incidentData?['title'] != null)
                  Text('Title: ${incidentData!['title']}'),
                if (incidentData?['datetime'] != null)
                  Text('Date and Time: $formattedDateTime'),
                if (incidentData?['location'] != null)
                  Text('Location: $locationString'),
                if (incidentData?['username'] != null) ...[
                  Text('Description:'),
                  Text(incidentData!['description']),
                ],
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.thumb_up),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('incidents')
                            .doc(widget.documentId)
                            .update({
                          'likes': FieldValue.increment(1),
                        });

                        setState(() {
                          likes++;
                        });
                      },
                    ),
                    Text('$likes Likes'),
                    IconButton(
                      icon: Icon(Icons.thumb_down),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('incidents')
                            .doc(widget.documentId)
                            .update({
                          'dislikes': FieldValue.increment(1),
                        });

                        setState(() {
                          dislikes++;
                        });
                      },
                    ),
                    Text('$dislikes Dislikes'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
