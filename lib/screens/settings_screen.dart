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

  final String versionJsonUrl =
      "https://raw.githubusercontent.com/pabloggm00/PokeHub/main/version.json";

  Future<void> _checkUpdate() async {
    setState(() => _checking = true);
    try {
      final response = await http.get(Uri.parse(versionJsonUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        _latestVersion = jsonData['latest_version'];
        _apkUrl = jsonData['apk_url'];

        final info = await PackageInfo.fromPlatform();
        final currentVersion = info.version;

        if (_latestVersion == null || _apkUrl == null) {
          _showMessage("No se pudo obtener información de la versión");
        } else if (_latestVersion == currentVersion) {
          _showMessage("La app ya está actualizada");
        } else {
          _showUpdateDialog(_latestVersion!, _apkUrl!);
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

  Future<void> _downloadAndInstall(String url) async {
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

  void _showUpdateDialog(String version, String url) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text("Actualización disponible",
            style: TextStyle(color: Colors.white)),
        content: Text(
          "Una nueva versión ($version) está disponible. ¿Deseas actualizar?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadAndInstall(url);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.selectedGen,
            ),
            child: _downloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text("Actualizar a $version", style: AppColors.typeText),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: const Text("Configuración", style: AppColors.title),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // botón atrás blanco
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.selectedGen,
            minimumSize: const Size(220, 45),
          ),
          onPressed: _checking ? null : _checkUpdate,
          child: _checking
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  "Buscar actualización",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
