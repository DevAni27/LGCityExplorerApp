# lg-plan-writer

## Name
lg-plan-writer — Mandatory Planning Gate

## Description
Forces a complete, written implementation plan before any code is generated.
This skill is a GATE — Gemini must not write a single line of Dart until this plan is approved.
Run after lg-brainstormer, before lg-architecture-guard.

---

## Why this exists
AI models default to immediately writing code. On complex multi-layer apps (Flutter + SSH + KML + LG),
jumping to code produces:
- Wrong architecture choices that are hard to undo
- Missing edge cases (SSH disconnect, API failure, KML malformation)
- Starter kit structure violations

This skill forces the plan first. Always.

---

## Planning template (fill every section, no skipping)

### 1. Feature list (what this app does)
List every user-facing feature as a numbered sentence:
```
1. User opens Settings and enters LG IP, port, username, password.
2. App connects to LG via SSH and shows a green connected indicator.
3. User types an airport IATA code (e.g. "BOM") and taps Search.
4. App fetches live flights from OpenSky API within a bounding box around the airport.
5. App builds a KML Placemark for each flight with callsign label and airplane icon.
6. KML is uploaded to LG and shown on the centre screen.
7. LG flies to the airport coordinates.
8. Logo is displayed on left slave screen.
9. User can tap Clear to remove all KML.
10. If API fails, app falls back to assets/sample_flights.json.
```

### 2. File plan (every new file that will be created)
```
lib/
  models/
    flight_model.dart          ← data class, fromJson factory
  controllers/
    flight_controller.dart     ← OpenSky fetch, KML build, send to LG
  views/
    home/
      home_page.dart           ← search bar, results list, LG buttons
    widgets/
      flight_card.dart         ← one row per flight in results list
  helpers/
    kml_helper.dart            ← ADD pyramidKml(), flightKml() methods
  constants/
    app_constants.dart         ← API base URL, default bounding box padding
assets/
  sample_flights.json          ← 5 hardcoded flights for offline fallback
```

### 3. Data flow diagram (text format)
```
User taps Search
  → FlightController.fetchFlights(iataCode)
    → AirportLookup.getBoundingBox(iataCode)   // returns {minLat, maxLat, minLon, maxLon}
    → OpenSky REST GET /states/all?lamin=&lamax=&lomin=&lomax=
    → List<FlightModel> parsed from JSON
    → KmlHelper.flightsToKml(flights)          // returns KML string
    → LgController.sendKml(kmlString)          // SSH write to /var/www/html/kmls.txt
    → LgController.flyTo(lat, lon, range)      // SSH echo to /tmp/query.txt
  → UI rebuilds with flight count + list
```

### 4. SSH command plan (every LG SSH command, listed explicitly)
```
# Upload KML
echo '<kml>...</kml>' > /var/www/html/kml/flights.kml
echo 'http://<LG_IP>:81/kml/flights.kml' > /var/www/html/kmls.txt

# Fly to location
echo 'flyto=<lat>,<lon>,<altitude>,<heading>,<tilt>,<range>,<altitudeMode>' > /tmp/query.txt

# Show logo on left slave
cat > /var/www/html/kml/slave_<leftRig>.kml << EOF ... EOF

# Clean KML
echo '' > /var/www/html/kmls.txt
echo '' > /tmp/query.txt
```

### 5. Error handling plan
```
| Scenario | Handling |
|---|---|
| SSH connect fails | Show SnackBar, set isConnected=false, allow retry |
| SSH command throws | Catch, log, show SnackBar, do NOT crash |
| OpenSky API 429 | Show "Rate limited, try again in 10s" |
| OpenSky returns empty | Show "No flights found, try a busier airport" |
| API unreachable | Load sample_flights.json, show "Offline mode" banner |
| KML write fails | Show SnackBar, do not update UI state |
```

### 6. Test plan (before writing any tests)
```
Unit tests:
  - KmlHelper.flightsToKml() → valid XML, correct placemark count
  - FlightModel.fromJson() → parses real OpenSky response correctly
  - AirportLookup.getBoundingBox("BOM") → returns correct bounding box
  - KmlHelper with 0 flights → returns empty document kml, no crash

Widget tests:
  - HomePageWidget shows "No flights" when list empty
  - FlightCard renders callsign and altitude correctly

Integration (manual checklist):
  - Connect to LG → green indicator
  - Search "BOM" → flights appear in list AND on LG screen
  - Clear → LG screens blank
```

### 7. Starter kit integrity pledge
The agent MUST state:
```
I will NOT:
- Rename or move any file that exists in the starter kit
- Change the SshController public interface
- Replace Provider with any other state management
- Add packages not listed in the feature plan above

I WILL:
- Add new files only in the locations specified in section 2
- Extend KmlHelper by adding new static methods only
- Add new controllers that depend on SshController and SettingsController
```

---

## Gate rule
If this plan is not complete (any section missing or says "TBD") → output:
```
🚫 PLAN INCOMPLETE — Section <N> is missing or says TBD.
Fill all sections before proceeding to lg-architecture-guard.
```

If plan is complete → output:
```
✅ PLAN APPROVED
Sections complete: 7/7
→ Proceed to lg-architecture-guard
```
