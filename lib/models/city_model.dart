/// Data model for a City fetched from Wikipedia.
class CityModel {
  final String title;
  final String extract;
  final double lat;
  final double lon;
  final String? imageUrl;

  const CityModel({
    required this.title,
    required this.extract,
    required this.lat,
    required this.lon,
    this.imageUrl,
  });

  /// Factory to create a CityModel from Wikipedia REST API JSON response.
  /// Standard type: https://en.wikipedia.org/api/rest_v1/page/summary/{title}
  factory CityModel.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'standard') {
      throw Exception('Not a standard article (type: ${json['type']})');
    }

    final coordinates = json['coordinates'];
    if (coordinates == null) {
      throw Exception('No coordinates found for this city.');
    }

    return CityModel(
      title: json['title'] ?? 'Unknown',
      extract: json['extract'] ?? 'No summary available.',
      lat: (coordinates['lat'] as num).toDouble(),
      lon: (coordinates['lon'] as num).toDouble(),
      imageUrl: json['thumbnail']?['source'],
    );
  }

  /// Returns true if the city has valid coordinates.
  bool get hasCoordinates =>
      lat != 0 &&
      lon !=
          0; // Simple check, though 0,0 is valid (Null Island) but rare for a city search.

  @override
  String toString() => 'CityModel(title: $title, lat: $lat, lon: $lon)';
}
