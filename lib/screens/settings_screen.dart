import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int? _latestVersionCode;
  String? _currentVersion;
  int? _currentVersionCode;
  String? _apkUrl;
  bool _downloading = false;
  double _downloadProgress = 0.0;

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
      setState(() {
        _currentVersion = info.version;
        _currentVersionCode = int.tryParse(info.buildNumber) ?? 0;
      });
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

        // Prefer numeric version_code if provided in JSON
        final vc = jsonData['version_code'];
        if (vc != null) {
          int parsed = 0;
          if (vc is int) parsed = vc;
          else if (vc is String) parsed = int.tryParse(vc) ?? 0;
          _latestVersionCode = parsed;
        }

        if (_latestVersion == null || _apkUrl == null) {
          if (mounted) _showMessage(AppLocalizations.of(context)!.couldNotGetVersionInfo);
        } else if (_latestVersionCode != null && _currentVersionCode != null) {
          if (_latestVersionCode! <= _currentVersionCode!) {
            if (mounted) _showMessage(AppLocalizations.of(context)!.appIsUpToDate);
          }
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
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url));
      final streamedResponse = await client.send(request).timeout(const Duration(seconds: 60));

      if (streamedResponse.statusCode != 200) {
        if (mounted) _showMessage('Error: servidor respondió ${streamedResponse.statusCode}');
        client.close();
        return;
      }

      final contentLength = streamedResponse.contentLength ?? 0;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/update.apk');
      final sink = file.openWrite();

      int received = 0;
      await for (final chunk in streamedResponse.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (contentLength > 0) {
          setState(() => _downloadProgress = received / contentLength);
        }
      }
      await sink.flush();
      await sink.close();

      if (mounted) _showMessage('Guardado temporal: ${file.path}');

      // Intentar instalar usando MethodChannel en Android (FileProvider)
      const platform = MethodChannel('dex_app/update');
      try {
        final res = await platform.invokeMethod('installApk', {'path': file.path});
        if (res == true) {
          if (mounted) _showMessage('Instalador lanzado');
        } else {
          if (mounted) _showMessage('No se pudo iniciar instalador');
        }
      } on PlatformException catch (e) {
        // Fallback: guardar en Downloads y abrir con OpenFile
        try {
          final extDir = await getExternalStorageDirectory();
          if (extDir != null) {
            final downloads = Directory('${extDir.path}/Download');
            if (!await downloads.exists()) await downloads.create(recursive: true);
            final out = File('${downloads.path}/update.apk');
            await out.writeAsBytes(await file.readAsBytes());
            if (mounted) _showMessage('Guardado en Downloads: ${out.path}');
            await OpenFile.open(out.path);
          } else {
            if (mounted) _showMessage('No se pudo obtener carpeta externa para fallback');
          }
        } catch (e) {
          if (mounted) _showMessage('Fallo al intentar abrir instalador: ${e.toString()}');
        }
      } finally {
        client.close();
      }
    } catch (e) {
      if (mounted) _showMessage(AppLocalizations.of(context)!.errorDownloadingApk(e.toString()));
    } finally {
      setState(() {
        _downloading = false;
        _downloadProgress = 0.0;
      });
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
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        ),
                        const SizedBox(width: 10),
                        Text('${(_downloadProgress * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white)),
                      ],
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
