import 'package:flutter/material.dart';
import 'ssh_controller.dart';
import 'settings_controller.dart';
import '../helpers/kml_helper.dart';
import '../helpers/snackbar_helper.dart';
import '../constants/app_constants.dart';

/// Orchestrates all Liquid Galaxy hardware operations.
/// Depends on SshController for SSH transport and SettingsController for config.
/// Does NOT build KML strings — delegates that to KmlHelper.
class LgController extends ChangeNotifier {
  final SshController sshController;
  final SettingsController settingsController;

  LgController({
    required this.sshController,
    required this.settingsController,
  });

  // ─── Connection helpers ───────────────────────────────────────────────────

  /// Convenience: connect using stored settings.
  Future<void> connectWithSettings(BuildContext context) async {
    try {
      await sshController.connect(
        host: settingsController.lgIp,
        port: int.tryParse(settingsController.lgPort) ?? 22,
        username: settingsController.lgUsername,
        password: settingsController.lgPassword,
      );
      showSnackBar(
          context: context, message: 'Connected to LG ✓', color: Colors.green);
    } catch (e) {
      showSnackBar(
          context: context,
          message: 'Connection failed: $e',
          color: Colors.red);
    }
  }

  // ─── KML delivery ────────────────────────────────────────────────────────

  /// Writes [kmlString] to /var/www/html/kml/[filename] on LG master,
  /// then registers its URL in kmls.txt so Google Earth loads it.
  Future<void> sendKml({
    required BuildContext context,
    required String kmlString,
    required String filename,
  }) async {
    try {
      final remotePath = '${kAppKmlDir}$filename';
      final url =
          'http://${settingsController.lgIp}:$kAppWebPort/kml/$filename';

      // Use quoted heredoc to prevent shell expansion inside KML
      await sshController.runCommand(
        "bash -c 'cat > \"$remotePath\" << \"KMLEOF\"\n$kmlString\nKMLEOF'",
      );
      await sshController.runCommand(
        "echo '$url' > $kAppKmlsTxt",
      );

      debugPrint('[LgController] KML sent: $url');
    } catch (e) {
      debugPrint('[LgController] sendKml failed: $e');
      showSnackBar(
          context: context,
          message: 'KML upload failed: $e',
          color: Colors.red);
    }
  }

  // ─── Camera control ──────────────────────────────────────────────────────

  /// Flies Google Earth to [lat],[lon] using the correct LookAt XML format.
  /// [zoom] is range in metres. [tilt] 0=top-down, 60=angled. [heading] 0=north.
  Future<void> flyTo({
    required BuildContext context,
    required double lat,
    required double lon,
    double range = kDefaultFlyToRange,
    double heading = 0,
    double tilt = 60,
  }) async {
    try {
      //flytoview=${KmlHelper.orbitLookAtLinear(18.5246, 73.8786, 7000, 45, 0)}
      await sshController.runCommand(
          "echo 'flytoview=${KmlHelper.flyToQuery(lat, lon, range, heading, tilt)}' > $kAppQueryTxt");
      debugPrint('[LgController] flyTo $lat,$lon range=$range');
    } catch (e) {
      debugPrint('[LgController] flyTo failed: $e');
      showSnackBar(
          context: context, message: 'FlyTo failed: $e', color: Colors.red);
    }
  }

  // ─── Slave screens ───────────────────────────────────────────────────────

  /// Sends a logo screen overlay to the left slave screen.
  Future<void> sendLogoToLeftSlave({
    required BuildContext context,
    String logoUrl = kLgLogoUrl,
  }) async {
    try {
      final leftSlave = _leftSlaveIndex();
      final path = '${kAppKmlDir}slave_$leftSlave.kml';
      final kml = KmlHelper.logoOverlayKml(logoUrl);
      await sshController.runCommand(
        "bash -lc 'cat > \"$path\" << \"KMLEOF\"\n$kml\nKMLEOF'",
      );
      await _setSlaveRefresh(context);
      debugPrint('[LgController] Logo sent to slave $leftSlave');
      showSnackBar(
          context: context,
          message: 'Logo Sent to left slave',
          color: Colors.green);
    } catch (e) {
      debugPrint('[LgController] sendLogoToLeftSlave failed: $e');
      showSnackBar(
          context: context, message: 'Logo failed: $e', color: Colors.red);
    }
  }

  // ─── Clean up ────────────────────────────────────────────────────────────

  /// Clears all KML content from the LG screens.
  Future<void> cleanAll(BuildContext context) async {
    try {
      await sshController.runCommand(
          "echo '${KmlHelper.getSlaveDefaultKml(3)}' > /var/www/html/kml/slave_3.kml");

      await _setSlaveRefresh(context);
      showSnackBar(
          context: context, message: 'LG screens cleared', color: Colors.green);
      debugPrint('[LgController] All KML cleared');
    } catch (e) {
      debugPrint('[LgController] cleanAll failed: $e');
      showSnackBar(
          context: context, message: 'Clear failed: $e', color: Colors.red);
    }
  }

  // ─── LG system commands ──────────────────────────────────────────────────

  Future<void> relaunchLG(BuildContext context) async {
    try {
      final pass = settingsController.lgPassword;
      await sshController.runCommand(
        "echo '$pass' | sudo -S systemctl restart lightdm",
      );
      showSnackBar(
          context: context, message: 'Relaunching LG…', color: Colors.orange);
    } catch (e) {
      showSnackBar(
          context: context, message: 'Relaunch failed: $e', color: Colors.red);
    }
  }

  Future<void> shutDownLG(BuildContext context) async {
    try {
      final pass = settingsController.lgPassword;
      await sshController.runCommand(
        "echo '$pass' | sudo -S shutdown -h now",
      );
      showSnackBar(
          context: context, message: 'Shutting down LG…', color: Colors.red);
    } catch (e) {
      showSnackBar(
          context: context, message: 'Shutdown failed: $e', color: Colors.red);
    }
  }

  // ─── Private helpers ─────────────────────────────────────────────────────

  /// Left slave index formula used across all LG apps.
  int _leftSlaveIndex() => (settingsController.lgRigs / 2).floor() + 2;

  Future<void> _setSlaveRefresh(BuildContext context) async {
    try {
      final rigs = settingsController.lgRigs;
      final pass = settingsController.lgPassword;
      for (int i = 2; i <= rigs; i++) {
        final search = '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href>';
        final replace =
            '$search<refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';
        final cmd =
            """sshpass -p '$pass' ssh -o StrictHostKeyChecking=no lg$i 'echo "$pass" | sudo -S sed -i "s/$replace/$search/g" ~/earth/kml/slave/myplaces.kml; echo "$pass" | sudo -S sed -i "s/$search/$replace/g" ~/earth/kml/slave/myplaces.kml'""";
        await sshController.runCommand(cmd);
      }
    } catch (e) {
      debugPrint('[LgController] setSlaveRefresh failed: $e');
    }
  }
}
