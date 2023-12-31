import '../../models/location_model.dart';
//should see what to do with images!
class Incident {
  final String title;
  final String description;
  final DateTime datetime;
  final String username;
  final LocationModel location; // Use LocationModel instead of GeoPoint

  Incident({
    required this.title,
    required this.description,
    required this.datetime,
    required this.username,
    required this.location,
  });
}
