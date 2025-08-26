import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class EvolutionService {
  final Box _hiveCache = Hive.box('pokeCache');

  Future<Map<String, String>> getEvolutionChainWithImages(
    Map<String, dynamic> speciesData,
  ) async {
    final evolutionUrl = speciesData['evolution_chain']?['url'];

    if (evolutionUrl == null) {
      final currentName = speciesData['name'] as String;
      return {currentName: await _getEvolutionImage(currentName)};
    }

    try {
      final evolutionData = await _fetchWithCache(evolutionUrl as String);
      final evolutionNames = _parseEvolutionChain(evolutionData['chain']);

      final Map<String, String> evolutionChainWithImages = {};

      for (String name in evolutionNames) {
        final imageUrl = await _getEvolutionImage(name);
        evolutionChainWithImages[name] = imageUrl;
      }

      return evolutionChainWithImages;
    } catch (e) {
      final currentName = speciesData['name'] as String;
      return {currentName: await _getEvolutionImage(currentName)};
    }
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

  List<String> _parseEvolutionChain(Map<String, dynamic> chain) {
    final List<String> result = [];

    void traverse(Map<String, dynamic> node) {
      result.add(node['species']['name'] as String);
      final evolvesTo = node['evolves_to'] as List;
      if (evolvesTo.isNotEmpty) {
        traverse(evolvesTo[0] as Map<String, dynamic>);
      }
    }

    traverse(chain);
    return result;
  }

  Future<String> _getEvolutionImage(String pokemonName) async {
    try {
      final pokemonData = await _fetchWithCache(
        'https://pokeapi.co/api/v2/pokemon/$pokemonName',
      );
      return pokemonData['sprites']['other']?['official-artwork']?['front_default'] ??
          pokemonData['sprites']['front_default'] ??
          '';
    } catch (e) {
      return '';
    }
  }
}
