import 'package:flutter/material.dart';

/// A small coloured dot indicating SSH connection status.
/// Green = connected, Red = disconnected.
class ConnectionStatusDot extends StatelessWidget {
  final bool isConnected;
  const ConnectionStatusDot({super.key, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      child: Tooltip(
        message: isConnected ? 'Connected to LG' : 'Not connected',
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isConnected ? Colors.greenAccent : Colors.red,
            boxShadow: [
              BoxShadow(
                color: (isConnected ? Colors.greenAccent : Colors.red).withOpacity(0.6),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
