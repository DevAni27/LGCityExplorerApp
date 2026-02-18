# lg-flight-api-opensky

## Name
lg-flight-api-opensky — OpenSky Network API Integration Guide

## Description
Step-by-step guide for fetching live flight data from the OpenSky Network REST API
and converting it to Dart models for KML generation.

---

## API Overview
- **Base URL**: `https://opensky-network.org/api`
- **Auth**: None required for basic access (rate limited to 1 req/10s per IP)
- **Docs**: https://openskynetwork.github.io/opensky-api/rest.html
- **License**: Creative Commons — data is open, attribution required

---

## Key endpoint: `/states/all`

### Request
```
GET https://opensky-network.org/api/states/all?lamin={minLat}&lamax={maxLat}&lomin={minLon}&lomax={maxLon}
```

### Bounding box math
Given an airport's center coordinates, compute a bounding box with padding:
```dart
// lib/helpers/airport_helper.dart
class BoundingBox {
  final double minLat, maxLat, minLon, maxLon;
  const BoundingBox({
    required this.minLat, required this.maxLat,
    required this.minLon, required this.maxLon,
  });
}

/// Returns a bounding box 2 degrees around the airport center.
/// 1 degree ≈ 111 km, so 2 degrees ≈ 222 km radius — catches approach traffic.
BoundingBox airportBoundingBox(double lat, double lon, {double pad = 2.0}) {
  return BoundingBox(
    minLat: lat - pad,
    maxLat: lat + pad,
    minLon: lon - pad,
    maxLon: lon + pad,
  );
}
```

### Airport lookup table (for offline / no separate API)
Use a small hardcoded map of major airports. This avoids a second API dependency:
```dart
// lib/constants/app_constants.dart
const Map<String, Map<String, double>> kAirports = {
  'BOM': {'lat': 19.0896, 'lon': 72.8656},  // Mumbai
  'DEL': {'lat': 28.5562, 'lon': 77.0999},  // Delhi
  'BLR': {'lat': 13.1986, 'lon': 77.7066},  // Bangalore
  'LHR': {'lat': 51.4700, 'lon': -0.4543},  // London Heathrow
  'JFK': {'lat': 40.6413, 'lon': -73.7781}, // New York JFK
  'CDG': {'lat': 49.0097, 'lon':  2.5479},  // Paris CDG
  'DXB': {'lat': 25.2532, 'lon':  55.3657}, // Dubai
  'SIN': {'lat':  1.3644, 'lon': 103.9915}, // Singapore
  'NRT': {'lat': 35.7653, 'lon': 140.3856}, // Tokyo Narita
  'SYD': {'lat': -33.9399,'lon': 151.1753}, // Sydney
};
```

### Response JSON structure
```json
{
  "time": 1699999999,
  "states": [
    [
      "abc123",    // 0: ICAO24 transponder address
      "AI101   ",  // 1: callsign (may have trailing spaces)
      "India",     // 2: origin country
      1699999990,  // 3: time_position (unix)
      1699999998,  // 4: last_contact (unix)
      72.8777,     // 5: longitude
      19.0760,     // 6: latitude
      10000.0,     // 7: baro_altitude (meters, can be null)
      false,       // 8: on_ground
      250.0,       // 9: velocity (m/s)
      90.0,        // 10: true_track (heading degrees)
      0.0,         // 11: vertical_rate
      null,        // 12: sensors
      10500.0,     // 13: geo_altitude (meters, can be null)
      "2000",      // 14: squawk
      false,       // 15: spi
      0            // 16: position_source
    ]
  ]
}
```

### FlightModel Dart class
```dart
// lib/models/flight_model.dart
class FlightModel {
  final String icao24;
  final String callsign;
  final String country;
  final double? longitude;
  final double? latitude;
  final double? altitude;   // meters
  final double? velocity;   // m/s
  final double? heading;    // degrees
  final bool onGround;

  const FlightModel({
    required this.icao24,
    required this.callsign,
    required this.country,
    this.longitude,
    this.latitude,
    this.altitude,
    this.velocity,
    this.heading,
    required this.onGround,
  });

  factory FlightModel.fromOpenSkyState(List<dynamic> state) {
    return FlightModel(
      icao24:    (state[0]  as String? ?? '').trim(),
      callsign:  (state[1]  as String? ?? 'N/A').trim(),
      country:   (state[2]  as String? ?? 'Unknown').trim(),
      longitude: (state[5]  as num?)?.toDouble(),
      latitude:  (state[6]  as num?)?.toDouble(),
      altitude:  (state[7]  as num?)?.toDouble(),
      velocity:  (state[9]  as num?)?.toDouble(),
      heading:   (state[10] as num?)?.toDouble(),
      onGround:  (state[8]  as bool?) ?? false,
    );
  }

  /// Filter: only include flights with valid coordinates
  bool get isPositionValid => longitude != null && latitude != null;

  @override
  String toString() => 'Flight($callsign @ $latitude,$longitude)';
}
```

---

## FlightController fetch method
```dart
// lib/controllers/flight_controller.dart (canonical pattern)
Future<List<FlightModel>> fetchFlights(String iataCode) async {
  final airport = kAirports[iataCode.toUpperCase()];
  if (airport == null) throw Exception('Unknown airport: $iataCode');

  final box = airportBoundingBox(airport['lat']!, airport['lon']!);
  final uri = Uri.parse(
    'https://opensky-network.org/api/states/all'
    '?lamin=${box.minLat}&lamax=${box.maxLat}'
    '&lomin=${box.minLon}&lomax=${box.maxLon}',
  );

  try {
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final states = data['states'] as List<dynamic>? ?? [];
      return states
        .map((s) => FlightModel.fromOpenSkyState(s as List<dynamic>))
        .where((f) => f.isPositionValid && !f.onGround)
        .toList();
    } else {
      throw Exception('OpenSky returned ${response.statusCode}');
    }
  } on TimeoutException {
    return _loadSampleFlights(); // fallback
  } on SocketException {
    return _loadSampleFlights(); // fallback
  }
}

Future<List<FlightModel>> _loadSampleFlights() async {
  final raw = await rootBundle.loadString('assets/sample_flights.json');
  final list = json.decode(raw) as List<dynamic>;
  return list.map((s) => FlightModel.fromOpenSkyState(s as List<dynamic>)).toList();
}
```

---

## sample_flights.json (offline fallback)
```json
[
  ["abc001","AI101   ","India",1699999990,1699999998,72.8777,19.0760,10000.0,false,250.0,90.0,0.0,null,10500.0,"2000",false,0],
  ["abc002","6E456   ","India",1699999990,1699999998,72.8500,19.1200, 8000.0,false,220.0,45.0,0.0,null, 8500.0,"3000",false,0],
  ["abc003","UK789   ","India",1699999990,1699999998,72.9000,18.9800,12000.0,false,270.0,180.0,0.0,null,12500.0,"4000",false,0],
  ["abc004","SG321   ","Singapore",1699999990,1699999998,72.8300,19.0400, 9000.0,false,230.0,270.0,0.0,null, 9500.0,"5000",false,0],
  ["abc005","EK555   ","UAE",1699999990,1699999998,72.8900,19.1000,11000.0,false,260.0,135.0,0.0,null,11500.0,"6000",false,0]
]
```

---

## Rate limiting
OpenSky free tier: 1 request per 10 seconds per IP.
```dart
// Simple debounce in FlightController:
DateTime? _lastFetch;

bool get canFetch =>
  _lastFetch == null || DateTime.now().difference(_lastFetch!) > const Duration(seconds: 10);
```
Show UI feedback: "Please wait ${10 - elapsed}s before fetching again."
