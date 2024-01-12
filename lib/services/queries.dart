import 'package:cloud_firestore/cloud_firestore.dart';

Future<String?> getUsernameFromEmail(String email) async {
  try {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['username'] as String?;
    }
  } catch (e) {
    print('Error getting username from Firestore: $e');
  }

  return null;
}

Future<int> getLevelFromEmail(String email) async {
  try {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      int points = querySnapshot.docs.first['points'] as int;
      int level = points % 10;
      return level;
    }
  } catch (e) {
    print('Error getting username from Firestore: $e');
  }

  return -1;
}
