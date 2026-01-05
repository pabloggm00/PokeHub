import 'package:dex_app/screens/home_screen.dart';
import 'package:dex_app/screens/loading_screen.dart';
import 'package:dex_app/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dex_app/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Locale _locale = const Locale('es'); // Español por defecto
  int _languageId = 1; // 1 = español, 2 = inglés

  void _changeLanguage() {
    setState(() {
      if (_languageId == 1) {
        _languageId = 2;
        _locale = const Locale('en');
      } else {
        _languageId = 1;
        _locale = const Locale('es');
      }
    });
  }

  Future<void> _initDatabase() async {
    final dbService = DatabaseService();
    await dbService.database; // Inicializar la BD
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
      ],
      home: FutureBuilder(
        future: _initDatabase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return LoadingScreen(
                status: "Error: ${snapshot.error}",
              );
            }
            return HomeScreen(
              languageId: _languageId,
              onLanguageToggle: _changeLanguage,
            );
          }
          return const LoadingScreen(status: "Loading...");
        },
      ),
    );
  }
}
