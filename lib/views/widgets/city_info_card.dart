import 'package:flutter/material.dart';
import '../../models/city_model.dart';
import '../../constants/app_constants.dart';

class CityInfoCard extends StatelessWidget {
  final CityModel city;

  const CityInfoCard({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.1), // Glassmorphic-ish
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image Header
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              city.imageUrl ?? kDefaultWikiImage,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (ctx, _, __) => Container(
                height: 200,
                color: Colors.grey.shade900,
                child: const Center(
                  child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  city.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 8),

                // Summary
                Text(
                  city.extract,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                        height: 1.4,
                      ),
                ),

                const SizedBox(height: 16),

                // Coordinates
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.blueAccent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${city.lat.toStringAsFixed(4)}, ${city.lon.toStringAsFixed(4)}',
                      style: const TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
