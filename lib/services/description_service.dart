import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class DescriptionService {
  final Box _hiveCache = Hive.box('pokeCache');

  Future<Map<String, dynamic>> fetchSpeciesWithCache(String url) async {
    final key = url.hashCode.toString();
    if (_hiveCache.containsKey(key)) {
      return Map<String, dynamic>.from(_hiveCache.get(key));
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load data from $url');
    }
    final data = jsonDecode(response.body);
    _hiveCache.put(key, data);
    return data;
  }

  String getSpanishDescription(Map<String, dynamic> speciesData) {
    final flavorEntries = speciesData['flavor_text_entries'] as List;

    // Buscar en español
    for (var entry in flavorEntries) {
      if (entry['language']['name'] == 'es') {
        return (entry['flavor_text'] as String)
            .replaceAll('\n', ' ')
            .replaceAll('\f', ' ');
      }
    }

    // Buscar en inglés
    for (var entry in flavorEntries) {
      if (entry['language']['name'] == 'en') {
        return (entry['flavor_text'] as String)
            .replaceAll('\n', ' ')
            .replaceAll('\f', ' ');
      }
    }

    return 'No description available';
  }
}