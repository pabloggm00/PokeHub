import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../models/pokemon_summary.dart';
import '../models/pokemon_detail.dart';
import 'ability_service.dart';
import 'evolution_service.dart';
import 'description_service.dart';

class PokeApiService {
  final String _baseUrl = 'https://pokeapi.co/api/v2';
  final Box _hiveCache = Hive.box('pokeCache');

  final AbilityService _abilityService = AbilityService();
  final EvolutionService _evolutionService = EvolutionService();
  final DescriptionService _descriptionService = DescriptionService();

  Future<List<PokemonSummary>> fetchPokemonFromGeneration(int gen) async {
    final url = Uri.parse('$_baseUrl/generation/$gen');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load generation $gen');
    }

    final data = jsonDecode(response.body);
    final speciesList = data['pokemon_species'] as List;

    speciesList.sort((a, b) {
      final idA = int.parse(a['url'].split('/')[6]);
      final idB = int.parse(b['url'].split('/')[6]);
      return idA.compareTo(idB);
    });

    final List<PokemonSummary> results = [];
    final List<Future> futures = [];

    for (var species in speciesList) {
      final id = int.parse(species['url'].split('/')[6]);
      final pokemonUrl = '$_baseUrl/pokemon/$id';

      futures.add(
        _fetchWithCache(pokemonUrl).then((details) {
          results.add(
            PokemonSummary(
              id: id,
              name: species['name'],
              imageUrl: details['sprites']['front_default'] ?? '',
              types: (details['types'] as List)
                  .map((typeInfo) => typeInfo['type']['name'] as String)
                  .toList(),
            ),
          );
        }),
      );
    }

    await Future.wait(futures);
    results.sort((a, b) => a.id.compareTo(b.id));
    return results;
  }

  Future<PokemonDetail> fetchPokemonDetails(int id) async {
    
    final pokemonData = await _fetchWithCache('$_baseUrl/pokemon/$id');
    String urlSpecies = '$_baseUrl/pokemon-species/$id';

    if (id > 10000){
      urlSpecies = '$_baseUrl/pokemon-species/${pokemonData['species']['url'].split('/')[6]}';
    }

    final speciesData = await _fetchWithCache(urlSpecies);

    // Obtener datos en paralelo
    final abilitiesWithDescriptions = await _abilityService
        .getAbilitiesWithDescriptions(pokemonData);
    final description = _descriptionService.getSpanishDescription(speciesData);
    final evolutionChain = await _evolutionService.getEvolutionChainWithImages(
      speciesData,
    );

    return PokemonDetail(
      id: pokemonData['id'],
      name: pokemonData['name'],
      imageUrl:
          pokemonData['sprites']['other']?['official-artwork']?['front_default'] ??
          pokemonData['sprites']['front_default'] ??
          '',
      shinyImageUrl:
          pokemonData['sprites']['other']?['official-artwork']?['front_shiny'] ??
          pokemonData['sprites']['front_shiny'] ??
          '',
      types: (pokemonData['types'] as List)
          .map((t) => t['type']['name'] as String)
          .toList(),
      height: (pokemonData['height'] as int).toDouble() / 10,
      weight: (pokemonData['weight'] as int).toDouble() / 10,
      abilities: abilitiesWithDescriptions.keys.toList(),
      stats: Map.fromEntries(
        (pokemonData['stats'] as List).map(
          (s) => MapEntry(s['stat']['name'] as String, s['base_stat'] as int),
        ),
      ),
      description: description,
      evolutionChain: evolutionChain.keys.toList(),
      evolutionImages: evolutionChain,
      abilityDescriptions: abilitiesWithDescriptions,
    );
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

  Future<List<PokemonSummary>> getAllPokemon() async {
    // Primero intentar cargar todos los Pokémon de una vez
    try {
      final url = Uri.parse(
        '$_baseUrl/pokemon?limit=2000',
      ); // Número alto para obtener todos
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to load all Pokémon');
      }

      final data = jsonDecode(response.body);
      final results = data['results'] as List;

      final List<PokemonSummary> allPokemon = [];
      final List<Future> futures = [];

      for (var pokemon in results) {
        final url = pokemon['url'] as String;
        final id = int.parse(url.split('/')[6]); // Extraer ID de la URL

        futures.add(
          _fetchWithCache(url).then((details) {
            allPokemon.add(
              PokemonSummary(
                id: id,
                name: pokemon['name'],
                imageUrl: details['sprites']['front_default'] ?? '',
                types: (details['types'] as List)
                    .map((typeInfo) => typeInfo['type']['name'] as String)
                    .toList(),
              ),
            );
          }),
        );
      }

      await Future.wait(futures);
      allPokemon.sort((a, b) => a.id.compareTo(b.id));
      return allPokemon;
    } catch (e) {
      return _getAllPokemonByGenerations();
    }
  }

  // Método fallback: cargar todas las generaciones
  Future<List<PokemonSummary>> _getAllPokemonByGenerations() async {
    final List<PokemonSummary> allPokemon = [];

    for (int gen = 1; gen <= 9; gen++) {
      try {
        final genPokemon = await fetchPokemonFromGeneration(gen);
        allPokemon.addAll(genPokemon);
      } catch (e) {
        print('Error loading generation $gen: $e');
      }
      // Pequeña pausa para no saturar la API
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Eliminar duplicados y ordenar
    final uniquePokemon = allPokemon.toSet().toList();
    uniquePokemon.sort((a, b) => a.id.compareTo(b.id));

    return uniquePokemon;
  }
}
