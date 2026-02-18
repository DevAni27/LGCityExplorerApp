# lg-networklink

## Name
lg-networklink — LG Network Link & KML Delivery Conventions

## Description
Defines exactly how KML reaches the Liquid Galaxy screens — file paths, serving conventions,
NetworkLink patterns, and validation steps.

---

## LG file-serving architecture
```
Flutter App (SSH client)
  │
  │  SSH runCommand()
  ▼
LG Master (lg1)   ← SSH target
  ├── /var/www/html/          ← Apache serves this on port 81
  │   ├── kmls.txt            ← Google Earth polls this for KML URLs
  │   └── kml/
  │       ├── flights.kml     ← your app writes here
  │       ├── slave_2.kml     ← left screen overlay
  │       └── slave_3.kml     ← right screen overlay (if 3-rig setup)
  └── /tmp/query.txt          ← Google Earth polls this for flyTo commands
```

---

## Canonical SSH command sequences

### 1. Upload a KML file
```bash
bash -c 'cat > "/var/www/html/kml/flights.kml" << "KMLEOF"
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  ...
</kml>
KMLEOF'
```
⚠️ Use `<< "KMLEOF"` (quoted heredoc) to prevent shell variable expansion inside KML.

### 2. Register KML in kmls.txt (makes LG load it)
```bash
echo 'http://192.168.1.100:81/kml/flights.kml' > /var/www/html/kmls.txt
```
For multiple KML files:
```bash
printf 'http://192.168.1.100:81/kml/a.kml\nhttp://192.168.1.100:81/kml/b.kml\n' > /var/www/html/kmls.txt
```

### 3. Fly to a location
```dart
// Always use flytoview= with LookAt XML — NEVER the old flyto= format
await sshController.runCommand(
  "echo 'flytoview=\${KmlHelper.flyToQuery(lat, lon, zoom, tilt, heading)}' > $kAppQueryTxt",
);
```

Where `KmlHelper.flyToQuery(lat, lon, zoom, tilt, heading)` produces:
```
<gx:duration>2</gx:duration><gx:flyToMode>smooth</gx:flyToMode><LookAt><longitude>72.8777</longitude><latitude>19.0760</latitude><range>500000</range><tilt>60</tilt><heading>0</heading><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>
```

⚠️ NEVER write: `echo 'flyto=72.88,19.07,0,0,60,500000' > /tmp/query.txt`
✅ ALWAYS write: `echo 'flytoview=<LookAt XML block>' > /tmp/query.txt`

Params: lat, lon, zoom (metres, e.g. 500000), tilt (60 = angled), heading (0 = north)

### 4. Clear everything
```bash
echo '' > /var/www/html/kmls.txt
echo '' > /tmp/query.txt
```

### 5. Write to slave screen (logo/legend)
```bash
# Left screen formula: (rigCount ~/ 2) + 1
# For 3 rigs: (3 ~/ 2) + 1 = 2  →  slave_2.kml
bash -c 'cat > "/var/www/html/kml/slave_2.kml" << "KMLEOF"
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <ScreenOverlay>
      <Icon><href>https://your-logo.png</href></Icon>
      <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
      <screenXY x="0.02" y="0.95" xunits="fraction" yunits="fraction"/>
      <size x="0.3" y="0.15" xunits="fraction" yunits="fraction"/>
    </ScreenOverlay>
  </Document>
</kml>
KMLEOF'
```

### 6. Enable slave refresh (so slave KML auto-reloads)
```bash
# On slave lg2, edit myplaces.kml to add refresh tags
sshpass -p 'PASSWORD' ssh -o StrictHostKeyChecking=no lg2 \
  "sudo sed -i 's|<href>##LG_PHPIFACE##kml/slave_2.kml</href>|<href>##LG_PHPIFACE##kml/slave_2.kml</href><refreshMode>onInterval</refreshMode><refreshInterval>2</refreshInterval>|g' ~/earth/kml/slave/myplaces.kml"
```

---

## NetworkLink alternative (advanced)
Instead of direct file writes, you can use a KML NetworkLink that LG polls:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <NetworkLink>
    <name>Live Flights</name>
    <Link>
      <href>http://192.168.1.100:81/kml/flights.kml</href>
      <refreshMode>onInterval</refreshMode>
      <refreshInterval>5</refreshInterval>
    </Link>
  </NetworkLink>
</kml>
```
Write this to kmls.txt URL → LG polls it and auto-refreshes flights.kml every 5s.

---

## Validation checklist (run after every sendKml)
```dart
// In LgController, after writing KML:
Future<bool> validateKmlDelivery(String filename) async {
  // Check file exists and is non-empty on LG
  final result = await sshController.runCommand(
    'wc -c < /var/www/html/kml/$filename',
  );
  final bytes = int.tryParse(result.trim()) ?? 0;
  return bytes > 50; // A valid KML is never < 50 bytes
}
```

Manual validation:
1. SSH into LG master: `cat /var/www/html/kmls.txt` → should show your URL
2. `curl http://192.168.1.100:81/kml/flights.kml` → should return KML XML
3. Google Earth on LG should show placemarks within ~3 seconds

---

## Common errors
| Symptom | Cause | Fix |
|---|---|---|
| KML written but LG doesn't show it | kmls.txt not updated | Always update kmls.txt after writing KML file |
| `flyto` written but LG doesn't move | query.txt had trailing whitespace | Use `echo -n` or strip result |
| Slave screen shows old logo | Refresh not enabled | Run setRefreshForSlaves() |
| KML file empty on LG | Heredoc shell expansion issue | Use `<< "KMLEOF"` (quoted) |
| Permission denied writing to /var/www/html | Not using sudo | Prefix with `echo PASSWORD \| sudo -S` |
