import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/ssh_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/lg_controller.dart';
import '../../helpers/snackbar_helper.dart';

/// Settings screen for LG connection configuration.
/// Persists all values via SettingsController → shared_preferences.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const routeName = '/settings';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey   = GlobalKey<FormState>();
  final _ipCtrl    = TextEditingController();
  final _portCtrl  = TextEditingController();
  final _userCtrl  = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _rigsCtrl  = TextEditingController();

  bool _obscurePass = true;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsController>();
    _ipCtrl.text   = settings.lgIp;
    _portCtrl.text = settings.lgPort;
    _userCtrl.text = settings.lgUsername;
    _passCtrl.text = settings.lgPassword;
    _rigsCtrl.text = settings.lgRigs.toString();
  }

  @override
  void dispose() {
    _ipCtrl.dispose();
    _portCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    _rigsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final settings = context.read<SettingsController>();
    await settings.updateLgIp(_ipCtrl.text.trim());
    await settings.updateLgPort(_portCtrl.text.trim());
    await settings.updateLgUsername(_userCtrl.text.trim());
    await settings.updateLgPassword(_passCtrl.text);
    await settings.updateLgRigs(int.tryParse(_rigsCtrl.text.trim()) ?? 3);
    if (mounted) showSnackBar(context: context, message: 'Settings saved ✓', color: Colors.green);
  }

  Future<void> _connect() async {
    await _save();
    if (!mounted) return;
    await context.read<LgController>().connectWithSettings(context);
  }

  Future<void> _disconnect() async {
    await context.read<SshController>().disconnect();
    if (mounted) showSnackBar(context: context, message: 'Disconnected', color: Colors.orange);
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<SshController>().isConnected;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('LG Settings', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ConnectionBadge(isConnected: isConnected),
              const SizedBox(height: 24),
              _field(label: 'LG Master IP',     controller: _ipCtrl,   hint: '192.168.1.100',
                     validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
              _field(label: 'SSH Port',          controller: _portCtrl, hint: '22',    keyboardType: TextInputType.number),
              _field(label: 'Username',          controller: _userCtrl, hint: 'lg'),
              _field(label: 'Password',          controller: _passCtrl, obscure: _obscurePass,
                     suffixIcon: IconButton(
                       icon: Icon(_obscurePass ? Icons.visibility : Icons.visibility_off, color: Colors.white54),
                       onPressed: () => setState(() => _obscurePass = !_obscurePass),
                     )),
              _field(label: 'Number of Rigs',   controller: _rigsCtrl, hint: '3', keyboardType: TextInputType.number),
              const SizedBox(height: 32),
              Row(children: [
                Expanded(child: _btn('Save', Icons.save, Colors.blueGrey, _save)),
                const SizedBox(width: 12),
                Expanded(child: _btn(
                  isConnected ? 'Disconnect' : 'Connect',
                  isConnected ? Icons.link_off : Icons.link,
                  isConnected ? Colors.orange : Colors.green,
                  isConnected ? _disconnect : _connect,
                )),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: Colors.white54),
          hintStyle: const TextStyle(color: Colors.white24),
          suffixIcon: suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white24),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(8),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _btn(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
    );
  }
}

class _ConnectionBadge extends StatelessWidget {
  final bool isConnected;
  const _ConnectionBadge({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isConnected ? Colors.green : Colors.red.shade400,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isConnected ? Icons.check_circle : Icons.cancel,
            color: isConnected ? Colors.green : Colors.red.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            isConnected ? 'Connected to Liquid Galaxy' : 'Not connected',
            style: TextStyle(
              color: isConnected ? Colors.green : Colors.red.shade300,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
