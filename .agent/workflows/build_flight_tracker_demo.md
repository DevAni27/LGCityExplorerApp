# Workflow: Build LGFlightTrackerDemo

## Purpose
This is the end-to-end workflow for using the LGFlutterStarterKit agent system to generate
the `LGFlightTrackerDemo` app from scratch using Gemini in Google Antigravity.

Run skills in the order listed. Do not skip steps.

---

## Phase 0 — Setup

```
LOAD SKILL: .agent/skills/lg-init/SKILL.md
ACTION: Run all checks from lg-init against this repo.
GATE: All checks must pass before Phase 1 begins.
```

**Antigravity prompt:**
```
Read .agent/skills/lg-init/SKILL.md and run every check listed.
Report results in the exact output format specified.
Do not proceed to Phase 1 until all checks pass.
```

---

## Phase 1 — Brainstorm & Brief

```
LOAD SKILL: .agent/skills/lg-brainstormer/SKILL.md
ACTION: Generate the one-page app brief for a flight tracker demo.
OUTPUT: Completed brief (all fields filled, no TBDs).
```

**Antigravity prompt:**
```
Read .agent/skills/lg-brainstormer/SKILL.md.
Generate a one-page brief for an app called "LGFlightTrackerDemo" that:
- Uses OpenSky Network API (free, no auth)
- Lets users search for an airport by IATA code
- Shows live flights near that airport as KML Placemarks on LG screens
- Flies the LG camera to the airport
- Shows the LG logo on the left slave screen
Fill every field in the brief format. No TBDs.
```

---

## Phase 2 — Implementation Plan

```
LOAD SKILL: .agent/skills/lg-plan-writer/SKILL.md
ACTION: Fill all 7 sections of the plan template.
GATE: Plan must be approved (7/7 sections complete) before Phase 3.
```

**Antigravity prompt:**
```
Read .agent/skills/lg-plan-writer/SKILL.md.
Using the brief from Phase 1, fill all 7 sections of the plan template for LGFlightTrackerDemo.
Do not write any code yet. Only write the plan.
Check the gate rule at the end — output PLAN APPROVED or list missing sections.
```

---

## Phase 3 — Architecture Review

```
LOAD SKILL: .agent/skills/lg-architecture-guard/SKILL.md
ACTION: Review the plan against architecture rules.
GATE: Zero violations before coding begins.
```

**Antigravity prompt:**
```
Read .agent/skills/lg-architecture-guard/SKILL.md.
Review the plan from Phase 2 against all 6 architecture rules.
Check the approved dependency graph.
Report any violations. If zero violations, output ARCHITECTURE APPROVED.
```

---

## Phase 4 — Code Generation (in order)

Run each step. After each step, re-run lg-architecture-guard.

### Step 4a — Models
```
LOAD SKILL: .agent/skills/lg-flight-api-opensky/SKILL.md
ACTION: Generate lib/models/flight_model.dart using the FlightModel class from the skill.
```

**Antigravity prompt:**
```
Read .agent/skills/lg-flight-api-opensky/SKILL.md.
Generate lib/models/flight_model.dart using exactly the FlightModel class shown in the skill.
No imports except dart:core. No Flutter imports. No SSH.
Output the complete file only.
```

### Step 4b — Constants
```
ACTION: Generate lib/constants/app_constants.dart with kAirports map from the skill.
```

**Antigravity prompt:**
```
Generate lib/constants/app_constants.dart containing:
- kAirports map (use the airports from lg-flight-api-opensky SKILL.md)
- kDefaultBoundingBoxPadding = 2.0
- kOpenSkyBaseUrl = 'https://opensky-network.org/api'
- kLgWebPort = 81
- kLgKmlPath = '/var/www/html/kml/'
- kLgKmlsTxt = '/var/www/html/kmls.txt'
- kLgQueryTxt = '/tmp/query.txt'
Output the complete file only.
```

### Step 4c — KML Helper (extend, do not replace)
```
LOAD SKILL: .agent/skills/lg-kml-builder/SKILL.md
ACTION: Add flightsToKml(), flyToQuery(), logoOverlayKml() to existing kml_helper.dart
```

**Antigravity prompt:**
```
Read .agent/skills/lg-kml-builder/SKILL.md.
Extend lib/helpers/kml_helper.dart by adding these static methods:
1. flightsToKml(List<FlightModel> flights) → String
2. flyToQuery(double lat, double lon, {double range = 500000}) → String
3. logoOverlayKml(String logoUrl) → String
4. private _escapeXml(String input) → String
Follow the exact rules from the skill (coordinate order, CDATA, escaping).
Do NOT remove or rename existing methods. Output the complete updated file.
```

### Step 4d — FlightController
```
LOAD SKILLS: lg-flight-api-opensky/SKILL.md, lg-networklink/SKILL.md
ACTION: Generate lib/controllers/flight_controller.dart
```

**Antigravity prompt:**
```
Read lg-flight-api-opensky/SKILL.md and lg-networklink/SKILL.md.
Generate lib/controllers/flight_controller.dart with:
- fetchFlights(String iataCode) → fetches from OpenSky, falls back to sample_flights.json
- Rate limiting: 10s cooldown between fetches
- State: List<FlightModel> flights, bool isLoading, String? errorMessage
- Extends ChangeNotifier
- Depends on: LgController (injected via constructor)
- After fetch: calls LgController.sendFlightsKml(flights, airportIata)
Output the complete file.
```

### Step 4e — Extend LgController
```
LOAD SKILL: lg-networklink/SKILL.md
ACTION: Add sendFlightsKml(), flyToAirport(), sendLogoToLeft(), cleanAll() to lg_controller.dart
```

**Antigravity prompt:**
```
Read lg-networklink/SKILL.md.
Extend lib/controllers/lg_controller.dart by adding:
1. sendFlightsKml(List<FlightModel> flights, String filename) — writes KML + updates kmls.txt
2. flyToAirport(String iataCode) — flyTo using kAirports coordinates
3. sendLogoToLeft(String logoUrl) — writes logo KML to left slave screen
4. cleanAll(BuildContext context) — clears kmls.txt, query.txt, slave KML
Do NOT modify existing methods. Follow LG NetworkLink patterns from the skill exactly.
Output the complete updated file.
```

### Step 4f — Views
```
ACTION: Generate the UI files
```

**Antigravity prompt:**
```
Generate these view files following the MVC pattern (views contain NO SSH, NO KML building):

1. lib/views/home/home_page.dart
   - AppBar with connection status indicator (green/red dot)
   - Airport search field (IATA code input)
   - Search button → calls FlightController.fetchFlights()
   - List of FlightCard widgets when flights available
   - "No flights found" empty state
   - FAB or bottom buttons: Clear KML, Relaunch LG
   - All state via context.watch<FlightController>() and context.watch<SshController>()

2. lib/views/widgets/flight_card.dart
   - Shows: callsign, altitude (m), speed (m/s), country
   - Compact card design, no tappable action needed

3. lib/views/settings/settings_page.dart
   - Form fields: LG IP, Port, Username, Password, Number of Rigs
   - Connect button → calls SshController.connect() then LgController.sendLogoToLeft()
   - Disconnect button
   - Save button → persists via SettingsController

Output each file separately and completely.
```

### Step 4g — main.dart and pubspec.yaml
```
ACTION: Wire everything together
```

**Antigravity prompt:**
```
Generate:
1. lib/main.dart — with MultiProvider registering SshController, SettingsController, LgController, FlightController
   (LgController depends on SshController + SettingsController; FlightController depends on LgController)
   Use ChangeNotifierProxyProvider for dependent providers.
   MaterialApp with routes: '/' → HomePage, '/settings' → SettingsPage

2. pubspec.yaml — include: dartssh2, provider, shared_preferences, http, flutter_lints
   Include assets: [assets/sample_flights.json]

Output each file completely.
```

---

## Phase 5 — Assets
```
ACTION: Create assets/sample_flights.json using data from lg-flight-api-opensky skill
```

---

## Phase 6 — Tests
```
ACTION: Generate test/kml_helper_test.dart and test/flight_model_test.dart
```

**Antigravity prompt:**
```
Generate unit tests covering:
test/kml_helper_test.dart:
  - flightsToKml([]) → valid KML with 0 Placemarks
  - flightsToKml(sampleList) → correct Placemark count
  - _escapeXml with special chars
  - coordinate order (lon,lat,alt)

test/flight_model_test.dart:
  - fromOpenSkyState() with full valid state list
  - fromOpenSkyState() with null altitude → no crash
  - isPositionValid → false when lat null

Run: flutter test
Paste output as proof for lg-skeptical-mentor.
```

---

## Phase 7 — Code Review

```
LOAD SKILL: .agent/skills/lg-code-reviewer/SKILL.md
ACTION: Run all 5 review passes.
GATE: Zero violations (or document accepted trade-offs).
```

---

## Phase 8 — Skeptical Mentor Interrogation

```
LOAD SKILL: .agent/skills/lg-skeptical-mentor/SKILL.md
ACTION: Answer all 6 questions with real evidence.
GATE: SKEPTICAL MENTOR SATISFIED before marking complete.
```

---

## Phase 9 — README & submission prep

```
ACTION: Update README.md with:
- Prerequisites (Flutter 3.19+, LG rig setup)
- Clone instructions
- flutter pub get
- Running the app
- Connecting to LG rig
- Using the flight tracker
- Running tests
- Known limitations
```

---

## Final checklist
```
[ ] lg-init: all checks passed
[ ] Plan: 7/7 sections complete
[ ] Architecture: 0 violations
[ ] Models: flight_model.dart complete
[ ] KML: kml_helper.dart extended, never forked
[ ] Controllers: lg_controller.dart + flight_controller.dart complete
[ ] Views: home_page, settings_page, flight_card complete
[ ] main.dart: MultiProvider wired correctly
[ ] sample_flights.json: present in assets/
[ ] Tests: flutter test shows all pass
[ ] Code review: 0 violations
[ ] Skeptical mentor: SATISFIED
[ ] README: followable from scratch
[ ] Second repo (LGFlightTrackerDemo): pushed to GitHub
```
