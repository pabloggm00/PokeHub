import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class AbilityService {
  final Box _hiveCache = Hive.box('pokeCache');

  Future<Map<String, String>> getAbilitiesWithDescriptions(
    Map<String, dynamic> pokemonData,
  ) async {
    final abilities = pokemonData['abilities'] as List;
    final Map<String, String> abilitiesWithDescriptions = {};

    for (var ability in abilities) {
      final abilityUrl = ability['ability']['url'] as String;

      try {
        final abilityData = await _fetchWithCache(abilityUrl);
        final spanishName = _getSpanishName(abilityData);
        final description = _getSpanishDescription(abilityData);

        abilitiesWithDescriptions[spanishName] = description;
      } catch (e) {
        final englishName = ability['ability']['name'] as String;
        abilitiesWithDescriptions[englishName] =
            'No se pudo cargar la descripción';
      }
    }

    return abilitiesWithDescriptions;
  }

  Future<Map<String, dynamic>> _fetchWithCache(String url) async {
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

  String _getSpanishName(Map<String, dynamic> abilityData) {
    final names = abilityData['names'] as List;

    for (var name in names) {
      if (name['language']['name'] == 'es') {
        return name['name'] as String;
      }
    }

    return abilityData['name'] as String;
  }

  String _getSpanishDescription(Map<String, dynamic> abilityData) {
    final flavorTextEntries = abilityData['flavor_text_entries'] as List;

    for (var entry in flavorTextEntries) {
      if (entry['language']['name'] == 'es') {
        return (entry['flavor_text'] as String)
            .replaceAll('\n', ' ')
            .replaceAll('\f', ' ');
      }
    }

    for (var entry in flavorTextEntries) {
      if (entry['language']['name'] == 'en') {
        return (entry['flavor_text'] as String)
            .replaceAll('\n', ' ')
            .replaceAll('\f', ' ');
      }
    }

    return 'Descripción no disponible';
  }
}