import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _latestVersion;
  String? _currentVersion;
  String? _apkUrl;
  bool _checking = false;
  bool _downloading = false;

  final String versionJsonUrl =
      "https://raw.githubusercontent.com/pabloggm00/PokeHub/main/version.json";

  @override
  void initState() {
    super.initState();
    _loadCurrentVersion();
    _checkUpdate();
  }

  Future<void> _loadCurrentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() => _currentVersion = info.version);
    } catch (e) {
      _showMessage("Error cargando versión actual: $e");
    }
  }

  Future<void> _checkUpdate() async {
    setState(() => _checking = true);
    try {
      final response = await http.get(Uri.parse(versionJsonUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        _latestVersion = jsonData['latest_version'];
        _apkUrl = jsonData['apk_url'];

        if (_latestVersion == null || _apkUrl == null) {
          _showMessage("No se pudo obtener información de la versión");
        } else if (_latestVersion == _currentVersion) {
          _showMessage("✓ La app ya está actualizada");
        }
        setState(() {});
      } else {
        _showMessage("Error al consultar actualización");
      }
    } catch (e) {
      _showMessage("Error: $e");
    } finally {
      setState(() => _checking = false);
    }
  }

  Future<void> _downloadAndInstall(String? url) async {
    if (url == null) {
      _showMessage("URL de descarga no disponible");
      return;
    }
    setState(() => _downloading = true);
    try {
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/update.apk');
      await file.writeAsBytes(bytes);

      await OpenFile.open(file.path);
    } catch (e) {
      _showMessage("Error descargando APK: $e");
    } finally {
      setState(() => _downloading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool updateAvailable =
        _latestVersion != null && _latestVersion != _currentVersion;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: const Text("Configuración", style: AppColors.title),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    updateAvailable ? AppColors.selectedGen : Colors.grey,
                minimumSize: const Size(220, 45),
              ),
              onPressed: updateAvailable && !_downloading ? () => _downloadAndInstall(_apkUrl) : null,
              child: _downloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      updateAvailable
                          ? "Actualizar a $_latestVersion"
                          : "Ya está actualizada",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 30),
            Text(
              "v${_currentVersion ?? "..."}",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
