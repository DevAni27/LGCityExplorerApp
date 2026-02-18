import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/lg_controller.dart';
import '../../controllers/ssh_controller.dart';

/// Bottom control strip always visible on HomePage.
/// Provides quick access to common LG operations.
class LgControlPanel extends StatelessWidget {
  const LgControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<SshController>().isConnected;

    return Container(
      color: const Color(0xFF0F3460),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _LgButton(
            icon: Icons.image,
            label: 'Logo',
            enabled: isConnected,
            onTap: () => context.read<LgController>().sendLogoToLeftSlave(context: context),
          ),
          _LgButton(
            icon: Icons.clear_all,
            label: 'Clear',
            enabled: isConnected,
            onTap: () => context.read<LgController>().cleanAll(context),
          ),
          _LgButton(
            icon: Icons.refresh,
            label: 'Relaunch',
            enabled: isConnected,
            color: Colors.orange,
            onTap: () => context.read<LgController>().relaunchLG(context),
          ),
          _LgButton(
            icon: Icons.power_settings_new,
            label: 'Shutdown',
            enabled: isConnected,
            color: Colors.red.shade400,
            onTap: () => _confirmShutdown(context),
          ),
        ],
      ),
    );
  }

  void _confirmShutdown(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('Shut down LG?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will power off the Liquid Galaxy rig.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<LgController>().shutDownLG(context);
            },
            child: const Text('Shut Down'),
          ),
        ],
      ),
    );
  }
}

class _LgButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final Color? color;

  const _LgButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.lightBlueAccent;
    return Opacity(
      opacity: enabled ? 1.0 : 0.35,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: c, size: 22),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: c, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
