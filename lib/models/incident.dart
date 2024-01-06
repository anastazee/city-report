import 'package:cloud_firestore/cloud_firestore.dart';

/*
class IncidentDetails {
  final Timestamp? datetime;
  final String? description;
  final GeoPoint? location;
  final String? title;
  final String? username;
  final int? likes;
  final int? dislikes;

  IncidentDetails({
    this.datetime,
    this.description,
    this.location,
    this.title,
    this.username,
    this.likes,
    this.dislikes,
  });
}
*/

class IncidentDetails {
  final Timestamp? datetime;
  final String? description;
  final GeoPoint? location;
  final String? title;
  final String? username;
  final int? likes;
  final int? dislikes;
  final String? imageURL;

  IncidentDetails({
    this.datetime,
    this.description,
    this.location,
    this.title,
    this.username,
    this.likes,
    this.dislikes,
    this.imageURL,
  });
}
