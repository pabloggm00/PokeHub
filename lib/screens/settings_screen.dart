import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dex_app/l10n/app_localizations.dart';
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
      if (mounted) _showMessage(AppLocalizations.of(context)!.errorLoadingVersion(e.toString()));
    }
  }

  Future<void> _checkUpdate() async {
    try {
      final response = await http.get(Uri.parse(versionJsonUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        _latestVersion = jsonData['latest_version'];
        _apkUrl = jsonData['apk_url'];

        if (_latestVersion == null || _apkUrl == null) {
          if (mounted) _showMessage(AppLocalizations.of(context)!.couldNotGetVersionInfo);
        } else if (_latestVersion == _currentVersion) {
          if (mounted) _showMessage(AppLocalizations.of(context)!.appIsUpToDate);
        }
        setState(() {});
      } else {
        if (mounted) _showMessage(AppLocalizations.of(context)!.errorCheckingUpdate);
      }
    } catch (e) {
      if (mounted) _showMessage(AppLocalizations.of(context)!.errorGeneral(e.toString()));
    }
  }

  Future<void> _downloadAndInstall(String? url) async {
    if (url == null) {
      if (mounted) _showMessage(AppLocalizations.of(context)!.downloadUrlNotAvailable);
      return;
    }
    setState(() => _downloading = true);
    try {
      if (mounted) _showMessage('Iniciando descarga...');
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        if (mounted) _showMessage('Error: servidor respondió ${response.statusCode}');
        return;
      }

      final bytes = response.bodyBytes;
      if (bytes.isEmpty) {
        if (mounted) _showMessage('Error: archivo descargado vacío');
        return;
      }

      if (mounted) _showMessage('Descargados ${bytes.length} bytes');

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/update.apk');
      await file.writeAsBytes(bytes);

      if (mounted) _showMessage('Guardado: ${file.path}');

      await OpenFile.open(file.path);
    } catch (e) {
      if (mounted) _showMessage(AppLocalizations.of(context)!.errorDownloadingApk(e.toString()));
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
        title: Text(AppLocalizations.of(context)!.settings, style: AppColors.title),
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
                          ? AppLocalizations.of(context)!.updateToVersion(_latestVersion!)
                          : AppLocalizations.of(context)!.alreadyUpdated,
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
