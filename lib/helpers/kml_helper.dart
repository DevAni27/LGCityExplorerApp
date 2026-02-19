import '../models/city_model.dart';
import '../constants/app_constants.dart';

/// KML generation utilities for Liquid Galaxy applications.
/// All methods are static — this class is never instantiated.
/// RULE: Only this file may build KML strings. Never build KML inline elsewhere.
class KmlHelper {
  KmlHelper._(); // prevent instantiation

  // ─── Core document wrapper ─────────────────────────────────────────────────

  /// Wraps [innerContent] in a valid KML Document element.
  static String kmlDocument({
    required String name,
    required String innerContent,
    String? description,
  }) {
    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>${_escapeXml(name)}</name>
    <visibility>1</visibility>
    ${description != null ? '<description><![CDATA[$description]]></description>' : ''}
    $innerContent
  </Document>
</kml>''';
  }

  // ─── Placemark builder ────────────────────────────────────────────────────

  /// Generates a KML Placemark at [lon],[lat],[alt].
  /// Coordinates are in KML order: longitude, latitude, altitude.
  static String placemark({
    required String name,
    required double lon,
    required double lat,
    double alt = 0,
    String? description,
    String? iconUrl,
    double iconScale = 1.0,
    double heading = 0,
  }) {
    final icon = iconUrl != null
        ? '''<Style>
        <IconStyle>
          <Icon><href>${_escapeXml(iconUrl)}</href></Icon>
          <scale>$iconScale</scale>
          <heading>$heading</heading>
        </IconStyle>
        <LabelStyle><scale>0.8</scale></LabelStyle>
      </Style>'''
        : '';
    final desc = description != null
        ? '<description><![CDATA[$description]]></description>'
        : '';
    return '''<Placemark>
      <name>${_escapeXml(name)}</name>
      $desc
      $icon
      <Point>
        <altitudeMode>absolute</altitudeMode>
        <coordinates>$lon,$lat,$alt</coordinates>
      </Point>
    </Placemark>''';
  }

  // ─── flyTo query string ───────────────────────────────────────────────────

  /// Returns the LookAt XML block to write to /tmp/query.txt via flytoview=.
  /// Usage in LgController:
  ///   "echo 'flytoview=${KmlHelper.flyToQuery(...)}' > /tmp/query.txt"
  ///
  /// Parameters:
  ///   lat/lon  — target coordinates
  ///   zoom     — range in metres (camera distance from target)
  ///   tilt     — 0 = top-down, 60 = angled, 90 = horizon
  ///   heading  — compass bearing (0 = north)
  static String flyToQuery(
    double lat,
    double lon,
    double zoom,
    double tilt,
    double heading,
  ) =>
      '<gx:duration>2</gx:duration>'
      '<gx:flyToMode>smooth</gx:flyToMode>'
      '<LookAt>'
      '<longitude>$lon</longitude>'
      '<latitude>$lat</latitude>'
      '<range>$zoom</range>'
      '<tilt>$tilt</tilt>'
      '<heading>$heading</heading>'
      '<gx:altitudeMode>relativeToGround</gx:altitudeMode>'
      '</LookAt>';

  // ─── Screen overlays ─────────────────────────────────────────────────────

  /// KML for a logo overlay on the top-left of a slave screen.
  static String logoOverlayKml(String logoUrl) {
    return '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>Logo</name>
    <ScreenOverlay>
      <name>LG Logo</name>
      <Icon><href>${_escapeXml(logoUrl)}</href></Icon>
      <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
      <screenXY x="0.02" y="0.95" xunits="fraction" yunits="fraction"/>
      <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
      <size x="0.3" y="0.15" xunits="fraction" yunits="fraction"/>
    </ScreenOverlay>
  </Document>
</kml>''';
  }

  /// Default blank KML for resetting a slave screen.
  static String getSlaveDefaultKml(int slaveNo) =>
      '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document id="slave_$slaveNo">
</Document>
</kml>
''';

  // ─── LGCityExplorer KML generation ─────────────────────────────────────────

  /// 1. Master: Pin for the city center.
  static String buildCityPlacemark(CityModel city) {
    return kmlDocument(
      name: city.title,
      innerContent: placemark(
        name: city.title,
        lon: city.lon,
        lat: city.lat,
        description: city.extract,
        iconUrl: 'http://maps.google.com/mapfiles/kml/paddle/red-circle.png',
        iconScale: 1.2,
      ),
    );
  }

  /// 2. Slave: ScreenOverlay (Logo) + Info Balloon (Text).
  /// Note: Pure KML ScreenOverlays cannot display dynamic text without image generation.
  /// We use a Balloon attached to the location for the text content.
  static String buildCityOverlay(CityModel city) {
    // Extract the content of the logo overlay (minus the header/footer) to merge.
    // Actually, screen overlays and placemarks can coexist in one Document.
    // We'll reconstruct the document here for simplicity.

    final logoOverlay = '''
    <ScreenOverlay>
      <name>Logo</name>
      <Icon><href>${_escapeXml(kLgLogoUrl)}</href></Icon>
      <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
      <screenXY x="0.02" y="0.95" xunits="fraction" yunits="fraction"/>
      <size x="0.3" y="0.15" xunits="fraction" yunits="fraction"/>
    </ScreenOverlay>''';

    final htmlContent = '''
      <div style="font-family:sans-serif; color:white; width:400px; padding:20px; background-color:rgba(0,0,0,0.7); border-radius:10px;">
        <h1 style="margin:0; font-size:40px; color:#42a5f5;">${_escapeXml(city.title)}</h1>
        <hr style="border:1px solid #ddd; margin:10px 0;">
        <p style="font-size:24px; line-height:1.4;">${_escapeXml(city.extract)}</p>
      </div>
    ''';

    final textBalloon = '''
    <Placemark>
      <name>Info</name>
      <description><![CDATA[$htmlContent]]></description>
      <gx:balloonVisibility>1</gx:balloonVisibility>
      <Style>
        <IconStyle><scale>0</scale></IconStyle>
        <BalloonStyle>
          <bgColor>00000000</bgColor>
          <text><![CDATA[$htmlContent]]></text>
        </BalloonStyle>
      </Style>
      <Point>
        <coordinates>${city.lon},${city.lat},0</coordinates>
      </Point>
    </Placemark>''';

    return kmlDocument(
      name: 'Slave Info',
      innerContent: '$logoOverlay\n$textBalloon',
    );
  }

  // ─── XML safety ───────────────────────────────────────────────────────────

  /// Escapes special XML characters in user-controlled strings.
  /// Always use this for names, labels, and any field from an API.
  static String _escapeXml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}
