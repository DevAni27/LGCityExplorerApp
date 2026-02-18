# lg-code-reviewer

## Name
lg-code-reviewer — DRY, SOLID & LG-Specific Code Quality Checker

## Description
Reviews generated Dart/Flutter code for quality, correctness, and LG compatibility.
Run after code generation, before lg-skeptical-mentor.

---

## Review pass 1 — DRY (Don't Repeat Yourself)

Scan all files for:

### DRY-1: Duplicated KML snippets
Search for `<kml` or `<?xml` appearing in more than one file outside `kml_helper.dart`.
```
❌ VIOLATION DRY-1: KML template duplicated in flight_controller.dart and home_page.dart
   Fix: Extract to KmlHelper.flightsToKml()
```

### DRY-2: Duplicated SSH command strings
If the exact same SSH command string appears in more than one controller method:
```
❌ VIOLATION DRY-2: 'echo '' > /var/www/html/kmls.txt' appears in 3 places
   Fix: Extract to LgController.clearKmls()
```

### DRY-3: Duplicated SnackBar construction
If `SnackBar(content: Text(...), backgroundColor: ...)` is built inline in more than 2 places:
```
❌ VIOLATION DRY-3: Inline SnackBar in 4 methods
   Fix: Use showSnackBar() helper from snackbar_helper.dart
```

### DRY-4: Duplicated airport/settings reads
If `settingsController.lgIp` appears in more than one controller (outside LgController):
```
❌ VIOLATION DRY-4: Direct settings read outside LgController
   Fix: Route all LG config through LgController
```

---

## Review pass 2 — SOLID

### S — Single Responsibility
Each class should have ONE reason to change.
```
Check: Does FlightController do BOTH the API call AND the KML building?
❌ If yes → extract KML building to KmlHelper
```

### O — Open/Closed
New features should extend, not modify, existing classes.
```
Check: Is KmlHelper extended by adding new static methods?
✅ Good: adding static String earthquakeKml(...)
❌ Bad: modifying existing flightsToKml() signature to add unrelated params
```

### L — Liskov Substitution
Not directly applicable to most LG app patterns. Skip unless inheritance is used.

### I — Interface Segregation
```
Check: Does LgController have methods unrelated to LG hardware?
❌ Bad: LgController.parseFlightJson() — this is domain logic, not LG hardware
   Fix: Move to FlightController or KmlHelper
```

### D — Dependency Inversion
```
Check: Do views depend on concrete controllers, or on Providers?
❌ Bad: final ctrl = LgController(SshController(), SettingsController()) in a Widget
✅ Good: final ctrl = context.read<LgController>()
```

---

## Review pass 3 — Naming conventions

| What | Convention | Example |
|---|---|---|
| Classes | PascalCase | `FlightModel`, `LgController` |
| Variables/methods | camelCase | `fetchFlights()`, `isConnected` |
| Constants | camelCase with `k` prefix | `kAirports`, `kDefaultRange` |
| Private members | underscore prefix | `_client`, `_lastFetch` |
| Files | snake_case | `flight_model.dart` |
| KML files on LG | kebab-case | `flights.kml`, `slave-2.kml` |

Flag any name that:
- Uses `Manager`, `Data`, `Info` (too vague)
- Is a single letter except loop variables (`i`, `j`)
- Doesn't describe what it does (e.g. `doStuff()`, `handle()`)

---

## Review pass 4 — Error handling

Every `async` method that calls SSH or HTTP MUST:
```dart
// Pattern required in every LgController/FlightController method:
try {
  // ... operation
} catch (e) {
  // log the error
  debugPrint('[LgController.methodName] $e');
  // inform the user
  showSnackBar(context: context, message: 'Operation failed: $e', color: Colors.red);
  // do NOT rethrow unless the caller handles it
}
```

Violations:
- Empty catch block → "VIOLATION: Silent failure in <method>"
- `catch (e) { print(e); }` only → "VIOLATION: Error logged but user not informed"
- No try/catch on `runCommand()` call → "VIOLATION: Unhandled SSH exception"

---

## Review pass 5 — Tests checklist

```
Unit tests required:
[ ] KmlHelper.flightsToKml() with 0 flights → valid empty KML
[ ] KmlHelper.flightsToKml() with 3 flights → 3 Placemark elements
[ ] KmlHelper._escapeXml() with <>&"' → all escaped correctly
[ ] FlightModel.fromOpenSkyState() with null fields → no crash, defaults used
[ ] FlightModel.isPositionValid → false when lat or lon is null
[ ] airportBoundingBox("BOM") → correct lat/lon center

Widget tests required:
[ ] HomePageWidget: shows "No flights" message when list is empty
[ ] FlightCard: renders callsign text correctly

Missing tests → "QUALITY: <test name> is missing. Add before submission."
```

---

## Output format
```
📋 Code Review Report
---------------------
DRY violations:    0 ✅
SOLID violations:  1 ❌  → FlightController.buildKml() should be in KmlHelper
Naming violations: 0 ✅
Error handling:    2 ❌  → Silent catch in sendLogoToLeftScreen(), fetchFlights()
Tests missing:     1 ❌  → KmlHelper._escapeXml() not tested

Overall: ❌ Fix 3 issues before proceeding to lg-skeptical-mentor
```
