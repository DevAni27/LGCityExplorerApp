import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/ssh_controller.dart';
import '../../controllers/lg_controller.dart';
import '../settings/settings_page.dart';
import '../widgets/connection_status_dot.dart';
import '../widgets/lg_control_panel.dart';

/// Main home screen of the LG Flutter Starter Kit.
/// Contains connection status, LG controls, and a placeholder for your app's feature.
/// To build a new app on this skeleton: replace the [_FeaturePlaceholder] section below.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<SshController>().isConnected;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          'LG Flutter Starter Kit',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          ConnectionStatusDot(isConnected: isConnected),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            onPressed: () => Navigator.pushNamed(context, SettingsPage.routeName),
            tooltip: 'LG Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Your app's feature UI goes here ─────────────────────────────
          const Expanded(child: _FeaturePlaceholder()),

          // ── LG control panel (always visible at bottom) ──────────────────
          const LgControlPanel(),
        ],
      ),
    );
  }
}

/// Replace this widget with your app's actual feature.
/// Example: a flight search field, earthquake list, ISS tracker, etc.
class _FeaturePlaceholder extends StatelessWidget {
  const _FeaturePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.public, size: 80, color: Colors.blue.shade300),
          const SizedBox(height: 16),
          Text(
            'Your App Feature Here',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connect to LG via Settings, then build\nyour feature in this area.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.settings),
            label: const Text('Open LG Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => Navigator.pushNamed(context, SettingsPage.routeName),
          ),
        ],
      ),
    );
  }
}
