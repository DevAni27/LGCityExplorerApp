# lg-kml-builder

## Name
lg-kml-builder — Safe KML Generation Rules

## Description
Defines exactly how to generate valid, safe, LG-compatible KML in Flutter.
All KML generation must follow these rules. No exceptions.

---

## KML fundamentals for Liquid Galaxy

### How LG loads KML
1. Write KML file to `/var/www/html/kml/<name>.kml` on the master rig via SSH
2. Write its URL to `/var/www/html/kmls.txt` so Google Earth polls it
3. Google Earth refreshes every 2 seconds when `<refreshMode>onInterval</refreshMode>` is set
4. Fly the camera by writing to `/tmp/query.txt`

### The kmls.txt mechanism
```bash
# ONE URL per line — LG master reads this file
echo 'http://<LG_IP>:81/kml/flights.kml' > /var/www/html/kmls.txt
```
Multiple KML files → write multiple URLs, one per line.

### Slave screen KML
Each slave has its own KML file at `/var/www/html/kml/slave_<N>.kml`.
Left screen = slave at index `(rigCount ~/ 2) + 1` — use this formula always.

---

## KML templates (copy-paste safe)

### Minimal valid document
```xml
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>LG Flutter App</name>
    <visibility>1</visibility>
    <!-- Placemarks go here -->
  </Document>
</kml>
```

### Placemark with icon
```xml
<Placemark>
  <name>CALLSIGN</name>
  <description><![CDATA[Altitude: 10000m | Speed: 250kts]]></description>
  <Style>
    <IconStyle>
      <Icon><href>https://maps.google.com/mapfiles/kml/shapes/airports.png</href></Icon>
      <scale>1.2</scale>
      <heading>90</heading>
    </IconStyle>
    <LabelStyle><scale>0.8</scale></LabelStyle>
  </Style>
  <Point>
    <coordinates>72.8777,19.0760,10000</coordinates>
  </Point>
</Placemark>
```

### flyTo query string

⚠️ CRITICAL — Use ONLY this format. Never use the old `flyto=` comma format.

The correct format uses `flytoview=` prefix with a KML `LookAt` XML block:

```dart
// In KmlHelper (correct signature):
static String flyToQuery(
  double lat,
  double lon,
  double zoom,     // range in metres — camera distance from target
  double tilt,     // 0 = top-down, 60 = angled, 90 = horizon
  double heading,  // compass bearing, 0 = north
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
```

```dart
// In LgController (correct SSH command):
await sshController.runCommand(
  "echo 'flytoview=\${KmlHelper.flyToQuery(lat, lon, zoom, tilt, heading)}' > $kAppQueryTxt",
);
```

Example values: lat=19.07, lon=72.88, zoom=500000, tilt=60, heading=0

❌ NEVER write: `echo 'flyto=72.88,19.07,0,0,60,500000,relativeToGround' > /tmp/query.txt`
✅ ALWAYS write: `echo 'flytoview=<gx:duration>...<LookAt>...</LookAt>' > /tmp/query.txt`

### Screen overlay (slave logo)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <ScreenOverlay>
      <name>Logo</name>
      <Icon><href>https://your-logo-url.png</href></Icon>
      <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
      <screenXY x="0.02" y="0.95" xunits="fraction" yunits="fraction"/>
      <size x="0.3" y="0.15" xunits="fraction" yunits="fraction"/>
    </ScreenOverlay>
  </Document>
</kml>
```

---

## Dart KmlHelper rules

### Rule 1 — All methods are static
```dart
class KmlHelper {
  KmlHelper._(); // private constructor, no instantiation
  static String flightsToKml(List<FlightModel> flights) { ... }
  static String flyToQuery(double lat, double lon, double zoom, double tilt, double heading) { ... }
}
```

### Rule 2 — NEVER use string interpolation for user-controlled data in KML
BAD:
```dart
'<name>$callsign</name>'  // if callsign contains < or & this breaks KML
```
GOOD:
```dart
'<name>${_escapeXml(callsign)}</name>'
```

Always include this helper:
```dart
static String _escapeXml(String input) {
  return input
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&apos;');
}
```

### Rule 3 — Use CDATA for descriptions with HTML
```dart
'<description><![CDATA[<b>Altitude:</b> ${model.altitude}m]]></description>'
// CDATA blocks do NOT need _escapeXml()
```

### Rule 4 — Coordinates are lon,lat,alt (NOT lat,lon)
KML coordinate order is **longitude, latitude, altitude**. Always.
```dart
'<coordinates>${model.longitude},${model.latitude},${model.altitude}</coordinates>'
```

### Rule 5 — Test KML output as a string before sending
Every `KmlHelper` method must be unit-testable without SSH:
```dart
final kml = KmlHelper.flightsToKml(sampleFlights);
expect(kml, contains('<kml'));
expect(kml, contains('</kml>'));
expect(kml.split('<Placemark>').length - 1, equals(sampleFlights.length));
```

---

## SSH upload pattern (canonical)
```dart
// In LgController:
Future<void> sendKml(String kmlString, String filename) async {
  final remotePath = '/var/www/html/kml/$filename';
  final url = 'http://${settingsController.lgIp}:81/kml/$filename';

  // Write KML file
  await sshController.runCommand(
    "bash -c 'cat > \"$remotePath\" << \"KMLEOF\"\n$kmlString\nKMLEOF'",
  );

  // Register in kmls.txt
  await sshController.runCommand(
    "echo '$url' > /var/www/html/kmls.txt",
  );
}
```

---

## Common KML mistakes
| Mistake | Fix |
|---|---|
| `lat,lon` coordinate order | Always `lon,lat,alt` |
| Unescaped `&` in names | Use `_escapeXml()` |
| Writing KML to /tmp/ instead of /var/www/html/ | LG web server serves from /var/www/html/ |
| Forgetting to update kmls.txt | Always update BOTH the .kml file AND kmls.txt |
| Building KML in a controller | Move to KmlHelper static method |
