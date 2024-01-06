import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/bars.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/services/queries.dart';
import 'package:flutter_application_1/models/votes.dart';

class IncidentDetails extends StatefulWidget {
  final String documentId;

  IncidentDetails({required this.documentId});

  @override
  _IncidentDetailsState createState() => _IncidentDetailsState();
}

class _IncidentDetailsState extends State<IncidentDetails> {
  User? user = FirebaseAuth.instance.currentUser;
  String? _currentUsername;
  bool? likePressed;
  bool? dislikePressed;

  int likes = 0;
  int dislikes = 0;

  @override
  void initState() {
    super.initState();
    _getCurrentUsername();
  }

  _getCurrentUsername() async {
    try {
      String? currentUsername = await getUsernameFromEmail(user?.email ?? '');
      setState(() {
        _currentUsername = currentUsername;
        _checkUserVote();
      });
    } catch (e) {
      print('Error getting username: $e');
    }
  }

  _checkUserVote() async {
    try {
      VoteDetails? userVote = await getUserVote();
      if (userVote != null) {
        setState(() {
          if (userVote.vote == 1) {
            likePressed = true;
          } else if (userVote.vote == -1) {
            dislikePressed = true;
          }
        });
      }
    } catch (e) {
      print('Error checking user vote: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _getIncidentDocument(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var incidentData = snapshot.data?.data();

          if (incidentData == null) {
            return Center(child: Text('Incident not found'));
          }

          DateTime datetime = incidentData['datetime']?.toDate() ?? DateTime.now();
          String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(datetime);

          String locationString = incidentData['location'] != null
              ? 'Latitude: ${incidentData['location'].latitude.toStringAsFixed(4)}, Longitude: ${incidentData['location'].longitude.toStringAsFixed(4)}'
              : 'N/A';

          int initialLikes = incidentData['likes'] ?? 0;
          int initialDislikes = incidentData['dislikes'] ?? 0;

          likes = initialLikes;
          dislikes = initialDislikes;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (incidentData['title'] != null) Text('Title: ${incidentData['title']}'),
                if (incidentData['datetime'] != null) Text('Date and Time: $formattedDateTime'),
                if (incidentData['location'] != null) Text('Location: $locationString'),
                if (incidentData['username'] != null) ...[
                  Text('Description:'),
                  Text(incidentData['description']),
                ],
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.thumb_up, color: likePressed == true ? Colors.green : null),
                      onPressed: likePressed == true ? null : () {
                        _handleVote(1);
                      },
                    ),
                    Text('$likes Likes'),
                    IconButton(
                      icon: Icon(Icons.thumb_down, color: dislikePressed == true ? Colors.red : null),
                      onPressed: dislikePressed == true ? null : () {
                        _handleVote(-1);
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
      bottomNavigationBar: AppNavigationBar(selectedIndex: -1),
    );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getIncidentDocument() async {
    try {
      // Check if the document exists in 'incidents' collection
      DocumentSnapshot<Map<String, dynamic>> incidentSnapshot =
          await FirebaseFirestore.instance.collection('recent').doc(widget.documentId).get();

      // If the document doesn't exist in 'incidents', try to get it from 'recent' collection
      if (!incidentSnapshot.exists) {
        incidentSnapshot =
            await FirebaseFirestore.instance.collection('incidents').doc(widget.documentId).get();
      }

      return incidentSnapshot;
    } catch (e) {
      print('Error getting incident document: $e');
      throw e;
    }
  }

  _handleVote(int vote) async {
    try {
       // Check if the document exists in 'recent' collection
    DocumentSnapshot<Map<String, dynamic>> recentSnapshot =
        await FirebaseFirestore.instance.collection('recent').doc(widget.documentId).get();

    if (!recentSnapshot.exists) {
      // Document not found in 'recent' collection, so disable voting
      return;
    }

      if (vote == 1) {
        FirebaseFirestore.instance.collection('recent').doc(widget.documentId).update({
          'likes': FieldValue.increment(1),
          'dislikes': FieldValue.increment(dislikePressed == true ? -1 : 0),
        });
      } else if (vote == -1) {
        FirebaseFirestore.instance.collection('recent').doc(widget.documentId).update({
          'dislikes': FieldValue.increment(1),
          'likes': FieldValue.increment(likePressed == true ? -1 : 0),
        });
      }

      await FirebaseFirestore.instance.collection('votes').doc('$_currentUsername, ${widget.documentId}').set({
        'username': _currentUsername,
        'incidentId': widget.documentId,
        'vote': vote,
      });

      setState(() {
        if (vote == 1) {
          likePressed = true;
          dislikePressed = false;
          likes++;
          if (dislikePressed == true) {
            dislikes--;
          }
        } else if (vote == -1) {
          dislikePressed = true;
          likePressed = false;
          dislikes++;
          if (likePressed == false) {
            likes--;
          }
        }
      });
    } catch (e) {
      print('Error handling vote: $e');
    }
  }

  Future<VoteDetails?> getUserVote() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> voteSnapshot =
          await FirebaseFirestore.instance.collection('votes').doc('$_currentUsername, ${widget.documentId}').get();

      if (voteSnapshot.exists) {
        return VoteDetails(
          username: voteSnapshot['username'],
          incidentId: voteSnapshot['incidentId'],
          vote: voteSnapshot['vote'],
        );
      }

      return null;
    } catch (e) {
      print('Error getting user vote: $e');
      return null;
    }
  }
}
