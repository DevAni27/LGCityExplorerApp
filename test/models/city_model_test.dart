import 'package:flutter_test/flutter_test.dart';
import 'package:lg_flutter_starter_kit/models/city_model.dart';

void main() {
  group('CityModel', () {
    test('fromJson parses standard wikipedia response', () {
      final json = {
        'type': 'standard',
        'title': 'Paris',
        'extract': 'Capital of France.',
        'coordinates': {'lat': 48.8566, 'lon': 2.3522},
        'thumbnail': {'source': 'https://example.com/paris.jpg'}
      };

      final city = CityModel.fromJson(json);

      expect(city.title, 'Paris');
      expect(city.extract, 'Capital of France.');
      expect(city.lat, 48.8566);
      expect(city.lon, 2.3522);
      expect(city.imageUrl, 'https://example.com/paris.jpg');
      expect(city.hasCoordinates, true);
    });

    test('fromJson throws on missing coordinates', () {
      final json = {
        'type': 'standard',
        'title': 'Mars',
      };
      expect(() => CityModel.fromJson(json), throwsException);
    });

    test('fromJson throws on non-standard type', () {
      final json = {
        'type': 'disambiguation',
        'title': 'Paris',
      };
      expect(() => CityModel.fromJson(json), throwsException);
    });

    test('handles missing thumbnail gracefully', () {
      final json = {
        'type': 'standard',
        'title': 'Small Town',
        'extract': 'Desc',
        'coordinates': {'lat': 1.0, 'lon': 1.0},
      };
      final city = CityModel.fromJson(json);
      expect(city.imageUrl, isNull);
    });
  });
}
