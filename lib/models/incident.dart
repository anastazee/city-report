import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentDetails {
  final Timestamp? datetime;
  final String? description;
  final GeoPoint? location;
  final String? title;
  final String? username;

  IncidentDetails({
    this.datetime,
    this.description,
    this.location,
    this.title,
    this.username,
  });
}
