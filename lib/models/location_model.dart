class LocationModel {
  final double latitude;
  final double longitude;
  final String? documentId; // Make documentId nullable

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.documentId, // Provide a default value of null
  });
}
