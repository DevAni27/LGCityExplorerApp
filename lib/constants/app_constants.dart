/// Application-wide constants for LGFlutterStarterKit.
/// All LG-specific paths, URLs, and defaults live here.
/// Never hardcode these values inline — always import from this file.

// ─── LG file paths ───────────────────────────────────────────────────────────
const String kAppKmlDir = '/var/www/html/kml/';
const String kAppKmlsTxt = '/var/www/html/kmls.txt';
const String kAppQueryTxt = '/tmp/query.txt';
const int kAppWebPort = 81;

// ─── LG camera defaults ──────────────────────────────────────────────────────
const double kDefaultFlyToRange = 500000; // metres (~500 km altitude)
const double kDefaultFlyToTilt = 60;
const double kDefaultFlyToHeading = 0;

// ─── Assets ──────────────────────────────────────────────────────────────────
const String kLgLogoUrl =
    'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgXmdNgBTXup6bdWew5RzgCmC9pPb7rK487CpiscWB2S8OlhwFHmeeACHIIjx4B5-Iv-t95mNUx0JhB_oATG3-Tq1gs8Uj0-Xb9Njye6rHtKKsnJQJlzZqJxMDnj_2TXX3eA5x6VSgc8aw/s320-rw/LOGO+LIQUID+GALAXY-sq1000-+OKnoline.png';

// ─── Airport lookup (IATA → lat/lon) ─────────────────────────────────────────
/// Add more airports as needed. Used by flight tracker for bounding box calc.
const Map<String, Map<String, double>> kAirports = {
  'BOM': {'lat': 19.0896, 'lon': 72.8656},
  'DEL': {'lat': 28.5562, 'lon': 77.0999},
  'BLR': {'lat': 13.1986, 'lon': 77.7066},
  'MAA': {'lat': 12.9941, 'lon': 80.1709},
  'CCU': {'lat': 22.6520, 'lon': 88.4463},
  'LHR': {'lat': 51.4700, 'lon': -0.4543},
  'JFK': {'lat': 40.6413, 'lon': -73.7781},
  'CDG': {'lat': 49.0097, 'lon': 2.5479},
  'DXB': {'lat': 25.2532, 'lon': 55.3657},
  'SIN': {'lat': 1.3644, 'lon': 103.9915},
  'NRT': {'lat': 35.7653, 'lon': 140.3856},
  'SYD': {'lat': -33.9399, 'lon': 151.1753},
  'LAX': {'lat': 33.9425, 'lon': -118.4081},
  'ORD': {'lat': 41.9742, 'lon': -87.9073},
  'FRA': {'lat': 50.0379, 'lon': 8.5622},
  'AMS': {'lat': 52.3086, 'lon': 4.7639},
};

// ─── OpenSky API ─────────────────────────────────────────────────────────────
const String kOpenSkyBaseUrl = 'https://opensky-network.org/api';
const double kDefaultBoundingBoxPad = 2.0; // degrees (~222 km radius)
const int kOpenSkyRateLimitSeconds = 10;

// ─── App strings ─────────────────────────────────────────────────────────────
const String kAppName = 'LG Flutter Starter Kit';
const String kAppVersion = '1.0.0';
