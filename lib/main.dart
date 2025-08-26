import 'package:dex_app/screens/home_screen.dart';
import 'package:dex_app/screens/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<void> _openHiveBox() async {
    await Hive.openBox('pokeCache');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: _openHiveBox(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const HomeScreen();
          }
          return const LoadingScreen(status: "Inicializando base de datos...");
        },
      ),
    );
  }
}
