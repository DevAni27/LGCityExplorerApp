import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/city_model.dart';
import '../helpers/kml_helper.dart';
import '../helpers/snackbar_helper.dart';
import '../constants/app_constants.dart';
import 'lg_controller.dart';

class CityController extends ChangeNotifier {
  final LgController lgController;

  CityController({required this.lgController});

  CityModel? _currentCity;
  bool _isLoading = false;

  CityModel? get currentCity => _currentCity;
  bool get isLoading => _isLoading;

  /// Fetches city data from Wikipedia and updates LG.
  Future<void> searchCity(BuildContext context, String query) async {
    if (query.trim().isEmpty) {
      showSnackBar(
          context: context,
          message: 'Please enter a city name',
          color: Colors.orange);
      return;
    }

    _setLoading(true);

    try {
      final city = await _fetchWikiData(query);

      if (city != null) {
        _currentCity = city;
        notifyListeners();

        await _sendToLg(context, city);
        showSnackBar(
            context: context,
            message: 'Flying to ${city.title}!',
            color: Colors.green);
      } else {
        showSnackBar(
            context: context,
            message: 'City not found: $query',
            color: Colors.red);
      }
    } catch (e) {
      debugPrint('[CityController] Search failed: $e');
      showSnackBar(
          context: context, message: 'Search failed: $e', color: Colors.red);
    } finally {
      _setLoading(false);
    }
  }

  /// Clears data and LG screens.
  Future<void> clear(BuildContext context) async {
    _currentCity = null;
    notifyListeners();
    await lgController.cleanAll(context);
    // Also stop the flyTo motion or reset view if desired, but cleanAll handles KMLs.
    // To stop movement, we might want to fly to a neutral position or just stop.
    // For now, cleanAll is sufficient as it clears the content.
  }

  // ─── Internal Logic ────────────────────────────────────────────────────────

  Future<CityModel?> _fetchWikiData(String query) async {
    final url = Uri.parse('$kWikiBaseUrl${Uri.encodeComponent(query)}');
    debugPrint('[CityController] Fetching $url');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CityModel.fromJson(data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('API Error: ${response.statusCode}');
    }
  }

  Future<void> _sendToLg(BuildContext context, CityModel city) async {
    if (!city.hasCoordinates) {
      showSnackBar(
          context: context,
          message: 'No coordinates for ${city.title}',
          color: Colors.orange);
      return;
    }

    // 1. Send Master KML (Pin)
    final masterKml = KmlHelper.buildCityPlacemark(city);
    await lgController.sendKml(
      context: context,
      kmlString: masterKml,
      filename: 'city_marker.kml',
    );

    // 2. Send Slave KML (Info Overlay)
    final slaveKml = KmlHelper.buildCityOverlay(city);
    await lgController.sendKmlToSlave(
        context: context,
        kmlContent: slaveKml,
        slaveIndex:
            3 // Default right slave (or left, LgController defaults to left)
        // Wait, KmlHelper.logoOverlayKml uses specific coords for left.
        // LgController.sendKmlToSlave defaults to left slave index.
        // Let's use default (null) which maps to _leftSlaveIndex() in LgController.
        );

    // 3. Fly To
    await lgController.flyTo(
      context: context,
      lat: city.lat,
      lon: city.lon,
      range: 15000, // Closer look for a city
      tilt: 45,
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
