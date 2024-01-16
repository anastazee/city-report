import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/bars.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/services/queries.dart';
import 'package:flutter_application_1/models/votes.dart';
import 'package:photo_view/photo_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

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
  late int? points;
  bool isLoading = true; // New variable to track whether data is loading

  int likes = 0;
  int dislikes = 0;

  @override
  void initState() {
    super.initState();
    _getCurrentUsername();
    _loadIncidentData();
  }

  Future<void> _loadIncidentData() async {
  try {
    DocumentSnapshot<Map<String, dynamic>> incidentSnapshot =
        await _getIncidentDocument();
    fetchData(incidentSnapshot.data()?['uid']);
  } catch (e) {
    print('Error loading incident data: $e');
  }
}

  Future<void> fetchData(String? userId) async {
    try {
      points = await fetchUserPoints(userId);
      setState(() {
        isLoading = false; // Set isLoading to false after data is fetched
      });
    } catch (e) {
      print('Error fetching user points: $e');
      setState(() {
        isLoading = false; // Set isLoading to false in case of an error
      });
    }
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
          if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.active || isLoading) {
          return Center(child: CircularProgressIndicator());
        }


          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var incidentData = snapshot.data?.data();

          if (incidentData == null) {
            return Center(child: Text('Incident not found'));
          }

          DateTime datetime =
              incidentData['datetime']?.toDate() ?? DateTime.now();
          String formattedDateTime =
              DateFormat('yyyy-MM-dd HH:mm:ss').format(datetime);

          String locationString = incidentData['location'] != null
              ? 'Latitude: ${incidentData['location'].latitude.toStringAsFixed(4)}, Longitude: ${incidentData['location'].longitude.toStringAsFixed(4)}'
              : 'N/A';

          int initialLikes = incidentData['likes'] ?? 0;
          int initialDislikes = incidentData['dislikes'] ?? 0;

          likes = initialLikes;
          dislikes = initialDislikes;
          String? userId = incidentData['uid'];
          
          //fetchData(userId);
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.0),
                  Text(
                    "Report's Details",
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    '${incidentData['title'] ?? ''}',
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '$formattedDateTime',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  Row(children: [
                    if (incidentData['username'] != null) ...[
                      SizedBox(height: 8.0),
                      Text(
                        '@${incidentData['username']}',
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.grey[850],
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8.0),
                      // Display user level as a badge
                      points != null
                          ? buildLevelBadge(points! ~/ 10)
                          : CircularProgressIndicator(),
                    ],
                  ]),
                  SizedBox(height: 8.0),
                  Text(
                    'Short Description:',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    '${incidentData['description']}',
                    style: TextStyle(fontSize: 16.0, color: Colors.grey[850]),
                  ),
                  if (incidentData['imageURL'] != null) ...[
                    SizedBox(height: 16.0),
                    Text(
                      'Incident Documents',
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          SwipeablePageRoute(
                            builder: (context) => ZoomableImage(
                                imageURL: incidentData['imageURL']),
                          ),
                        );
                      },
                      child: Image.network(
                        incidentData['imageURL'],
                        width: double.infinity,
                        height: 200.0, // Adjust the initial image size
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                  SizedBox(height: 16.0),
                  Text("Rate this post",
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.thumb_up,
                            color: likePressed == true ? Colors.green : null),
                        onPressed: likePressed == true
                            ? null
                            : () {
                                _handleVote(1);
                              },
                      ),
                      Text('$likes Likes'),
                      IconButton(
                        icon: Icon(Icons.thumb_down,
                            color: dislikePressed == true ? Colors.red : null),
                        onPressed: dislikePressed == true
                            ? null
                            : () {
                                _handleVote(-1);
                              },
                      ),
                      Text('$dislikes Dislikes'),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
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
          await FirebaseFirestore.instance
              .collection('recent')
              .doc(widget.documentId)
              .get();

      // If the document doesn't exist in 'incidents', try to get it from 'recent' collection
      if (!incidentSnapshot.exists) {
        incidentSnapshot = await FirebaseFirestore.instance
            .collection('incidents')
            .doc(widget.documentId)
            .get();
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
          await FirebaseFirestore.instance
              .collection('recent')
              .doc(widget.documentId)
              .get();

      if (!recentSnapshot.exists) {
        // Document not found in 'recent' collection, so disable voting
        return;
      }

      if (vote == 1) {
        FirebaseFirestore.instance
            .collection('recent')
            .doc(widget.documentId)
            .update({
          'likes': FieldValue.increment(1),
          'dislikes': FieldValue.increment(dislikePressed == true ? -1 : 0),
        });
      } else if (vote == -1) {
        FirebaseFirestore.instance
            .collection('recent')
            .doc(widget.documentId)
            .update({
          'dislikes': FieldValue.increment(1),
          'likes': FieldValue.increment(likePressed == true ? -1 : 0),
        });
      }

      await FirebaseFirestore.instance
          .collection('votes')
          .doc('$_currentUsername, ${widget.documentId}')
          .set({
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
          await FirebaseFirestore.instance
              .collection('votes')
              .doc('$_currentUsername, ${widget.documentId}')
              .get();

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

class ZoomableImage extends StatelessWidget {
  final String imageURL;

  ZoomableImage({required this.imageURL});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PhotoView(
            imageProvider: NetworkImage(imageURL),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            backgroundDecoration: BoxDecoration(
              color: Colors.black,
            ),
          ),
          Positioned(
            left: 16.0,
            bottom: 16.0,
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(
                    context); // Navigate back when the back button is pressed
              },
            ),
          ),
        ],
      ),
    );
  }
}

Color mapLevelToColor(int level) {
  // Example: Assuming you want to create a color gradient from low to high levels
  // You can adjust the colors based on your design preference
  double factor = level / 5.0; // Assuming the maximum level is 5
  return Color.lerp(Color.fromARGB(255, 132, 226, 177),
          Color.fromARGB(255, 68, 0, 186), factor) ??
      Colors.yellow;
}

Widget buildLevelBadge(int level) {
  // Customize the appearance of the level badge (e.g., using a circle)
  return Container(
    padding: EdgeInsets.all(6.0),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: [
          mapLevelToColor(level).withOpacity(0.5), // Lighter color at the top
          mapLevelToColor(level), // Original color at the bottom
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: Text(
      '$level',
      style: TextStyle(
        fontSize: 14.0, // Increase the font size for a more impressive look
        fontWeight: FontWeight.bold, // Make the text bold
        color: Colors.white,
      ),
    ),
  );
}

Future<int?> fetchUserPoints(String? userId) async {
  try {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      // The document with the specified ID exists
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      return userData['points'] as int?;
    } else {
      // The document with the specified ID does not exist
      print('Document does not exist');
      return null; // Return null or a default value based on your use case
    }
  } catch (e) {
    print('Error fetching user data: $e');
    return null; // Return null or a default value based on your use case
  }
}

