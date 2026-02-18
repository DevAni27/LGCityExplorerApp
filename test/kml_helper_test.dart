import 'package:flutter_test/flutter_test.dart';
import 'package:lg_flutter_starter_kit/helpers/kml_helper.dart';

void main() {
  group('KmlHelper', () {
    group('kmlDocument', () {
      test('produces valid XML wrapper', () {
        final result =
            KmlHelper.kmlDocument(name: 'Test', innerContent: '<Placemark/>');
        expect(result, contains('<?xml version="1.0"'));
        expect(
            result, contains('<kml xmlns="http://www.opengis.net/kml/2.2">'));
        expect(result, contains('<Document>'));
        expect(result, contains('</Document>'));
        expect(result, contains('</kml>'));
      });

      test('includes the document name', () {
        final result = KmlHelper.kmlDocument(name: 'My App', innerContent: '');
        expect(result, contains('<name>My App</name>'));
      });

      test('escapes special chars in name', () {
        final result =
            KmlHelper.kmlDocument(name: 'A & B < C', innerContent: '');
        expect(result, contains('A &amp; B &lt; C'));
        expect(result, isNot(contains('A & B')));
      });
    });

    group('placemark', () {
      test('coordinates are in lon,lat,alt order', () {
        final result = KmlHelper.placemark(
            name: 'Test', lon: 72.88, lat: 19.07, alt: 5000);
        expect(result, contains('<coordinates>'));
        final coordMatch = RegExp(
          r'<coordinates>([\d.]+),([\d.]+),([\d.]+)<\/coordinates>',
        ).firstMatch(result);
        expect(coordMatch, isNotNull,
            reason: 'No <coordinates> tag found in placemark output');
        expect(double.parse(coordMatch!.group(1)!), closeTo(72.88, 0.001));
        expect(double.parse(coordMatch.group(2)!), closeTo(19.07, 0.001));
        expect(double.parse(coordMatch.group(3)!), closeTo(5000.0, 0.1));
      });

      test('does not crash with empty name', () {
        expect(
          () => KmlHelper.placemark(name: '', lon: 0, lat: 0),
          returnsNormally,
        );
      });

      test('escapes callsign with special chars', () {
        final result = KmlHelper.placemark(name: 'A&B', lon: 0, lat: 0);
        expect(result, contains('&amp;'));
      });

      test('includes icon when iconUrl provided', () {
        final result = KmlHelper.placemark(
          name: 'Plane',
          lon: 0,
          lat: 0,
          iconUrl: 'https://example.com/icon.png',
        );
        expect(result, contains('<IconStyle>'));
        expect(result, contains('example.com/icon.png'));
      });
    });

    group('flyToQuery', () {
      test('produces LookAt XML with correct structure', () {
        final q = KmlHelper.flyToQuery(19.07, 72.88, 1000, 45, 0);
        expect(q, contains('<LookAt>'));
        expect(q, contains('</LookAt>'));
        expect(q, contains('<gx:duration>2</gx:duration>'));
        expect(q, contains('<gx:flyToMode>smooth</gx:flyToMode>'));
        expect(
            q, contains('<gx:altitudeMode>relativeToGround</gx:altitudeMode>'));
      });

      test('contains correct lat and lon values', () {
        final q = KmlHelper.flyToQuery(19.07, 72.88, 1000, 45, 0);
        expect(q, contains('<latitude>19.07</latitude>'));
        expect(q, contains('<longitude>72.88</longitude>'));
      });

      test('lon and lat are in separate XML tags (not comma-separated)', () {
        final q = KmlHelper.flyToQuery(10.0, 50.0, 500000, 60, 0);
        expect(q, contains('<longitude>50.0</longitude>'));
        expect(q, contains('<latitude>10.0</latitude>'));
        expect(q, contains('<range>500000.0</range>'));
        expect(q, contains('<tilt>60.0</tilt>'));
        expect(q, contains('<heading>0.0</heading>'));
      });

      test('SSH command must use flytoview= prefix (not flyto=)', () {
        // The query string itself is the LookAt block — the flytoview= prefix
        // is added by LgController when writing to query.txt:
        // "echo 'flytoview=${KmlHelper.flyToQuery(...)}' > /tmp/query.txt"
        final q = KmlHelper.flyToQuery(19.07, 72.88, 1000, 45, 0);
        expect(q, isNot(startsWith('flyto=')));
        expect(q, startsWith('<gx:duration>'));
      });
    });

    group('logoOverlayKml', () {
      test('produces valid KML', () {
        final result = KmlHelper.logoOverlayKml('https://example.com/logo.png');
        expect(result, contains('<kml'));
        expect(result, contains('<ScreenOverlay>'));
        expect(result, contains('example.com/logo.png'));
      });
    });

    group('slaveDefaultKml', () {
      test('contains slave number', () {
        final result = KmlHelper.getSlaveDefaultKml(2);
        expect(result, contains('slave_2'));
      });
    });
  });
}
