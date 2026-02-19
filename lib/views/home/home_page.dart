import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/lg_controller.dart';
import '../../controllers/city_controller.dart';
import '../../views/settings/settings_page.dart';
import '../../constants/app_constants.dart';
import '../widgets/city_info_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const String routeName = '/';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cityController = context.watch<CityController>();
    final isConnected =
        context.select<LgController, bool>((c) => c.sshController.isConnected);

    return Scaffold(
      appBar: AppBar(
        title: const Text(kAppName),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          // Connection Indicator
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.circle,
              color: isConnected ? Colors.green : Colors.red,
              size: 12,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () =>
                Navigator.pushNamed(context, SettingsPage.routeName),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header / Logo area
            const SizedBox(height: 20),
            const Icon(Icons.travel_explore,
                size: 80, color: Colors.blueAccent),
            const SizedBox(height: 20),
            Text(
              'Explore the World',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 30),

            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter city name (e.g. Paris)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _searchController.clear,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
              ),
              onSubmitted: (value) => cityController.searchCity(context, value),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: cityController.isLoading
                        ? null
                        : () {
                            cityController.searchCity(
                                context, _searchController.text);
                            FocusScope.of(context).unfocus();
                          },
                    icon: cityController.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.flight_takeoff),
                    label: const Text('FLY TO CITY'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blueAccent,
                      disabledBackgroundColor:
                          Colors.blueAccent.withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    cityController.clear(context);
                    _searchController.clear();
                  },
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.redAccent),
                  label: const Text('CLEAR',
                      style: TextStyle(color: Colors.redAccent)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.redAccent),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Results Area
            if (cityController.currentCity != null)
              CityInfoCard(city: cityController.currentCity!)
            else if (!cityController.isLoading)
              Column(
                children: [
                  const SizedBox(height: 40),
                  Icon(Icons.public,
                      size: 60, color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 16),
                  Text(
                    'Search for a city to begin',
                    style: TextStyle(color: Colors.white.withOpacity(0.3)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
