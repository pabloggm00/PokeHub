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
  String? _apkUrl;
  bool _checking = false;
  bool _downloading = false;

  final String versionJsonUrl = "https://raw.githubusercontent.com/pabloggm00/PokeHub/main/version.json";

  Future<void> _checkUpdate() async {
    setState(() => _checking = true);
    try {
      final response = await http.get(Uri.parse(versionJsonUrl));
      if (response.statusCode == 200) {
        final data = response.body;
        final jsonData = Map<String, dynamic>.from(await http.read(Uri.parse(versionJsonUrl)).then((v) => json.decode(v)));
        _latestVersion = jsonData['latest_version'];
        _apkUrl = jsonData['apk_url'];

        final info = await PackageInfo.fromPlatform();
        final currentVersion = info.version;

        if (_latestVersion == null || _apkUrl == null) {
          _showMessage("No se pudo obtener información de la versión");
        } else if (_latestVersion == currentVersion) {
          _showMessage("La app ya está actualizada");
        } else {
          _showMessage("Nueva versión disponible: $_latestVersion");
        }
      } else {
        _showMessage("Error al consultar actualización");
      }
    } catch (e) {
      _showMessage("Error: $e");
    } finally {
      setState(() => _checking = false);
    }
  }

  Future<void> _downloadAndInstall() async {
    if (_apkUrl == null) return;
    setState(() => _downloading = true);
    try {
      final response = await http.get(Uri.parse(_apkUrl!));
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Configuración", style: AppColors.title),
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.selectedGen,
                minimumSize: const Size(200, 40),
              ),
              onPressed: _checking ? null : _checkUpdate,
              child: _checking
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Buscar actualización"),
            ),
            const SizedBox(height: 20),
            if (_latestVersion != null && _latestVersion != PackageInfo.fromPlatform().then((v) => v.version))
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.selectedGen,
                  minimumSize: const Size(200, 40),
                ),
                onPressed: _downloading ? null : _downloadAndInstall,
                child: _downloading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Actualizar a $_latestVersion"),
              ),
          ],
        ),
      ),
    );
  }
}
