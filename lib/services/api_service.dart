import 'dart:convert';
import 'dart:io';
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

  final Map<String, String> _headers = {
    HttpHeaders.userAgentHeader: 'PokeApp/1.0 (Flutter)',
  };

  /// Limita las peticiones concurrentes para no saturar la API
  Future<void> _runBatched<T>(
    List<T> items,
    int batchSize,
    Future<void> Function(T item) task,
  ) async {
    for (int i = 0; i < items.length; i += batchSize) {
      final batch = items.skip(i).take(batchSize);
      await Future.wait(batch.map(task));
    }
  }

  /// Obtiene un recurso de la API o desde el caché
  Future<Map<String, dynamic>> _fetchWithCache(String url) async {
    final key = url.hashCode.toString();

    if (_hiveCache.containsKey(key)) {
      try {
        return Map<String, dynamic>.from(_hiveCache.get(key));
      } catch (_) {
        _hiveCache.delete(key); 
      }
    }

    final response = await http.get(Uri.parse(url), headers: _headers);
    if (response.statusCode != 200) {
      throw HttpException('Error ${response.statusCode} al cargar $url');
    }

    final data = jsonDecode(response.body);
    _hiveCache.put(key, data);
    return data;
  }

  /// Pokémon por generación
  Future<List<PokemonSummary>> fetchPokemonFromGeneration(int gen) async {
    try {
      final url = Uri.parse('$_baseUrl/generation/$gen');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode != 200) {
        throw HttpException(
          'Error ${response.statusCode} al cargar generación $gen',
        );
      }

      final data = jsonDecode(response.body);
      final speciesList = data['pokemon_species'] as List;

      speciesList.sort((a, b) {
        final idA = int.parse(a['url'].split('/')[6]);
        final idB = int.parse(b['url'].split('/')[6]);
        return idA.compareTo(idB);
      });

      final results = <PokemonSummary>[];

      await _runBatched(speciesList, 10, (species) async {
        final id = int.parse(species['url'].split('/')[6]);
        final pokemonUrl = '$_baseUrl/pokemon/$id';

        try {
          final details = await _fetchWithCache(pokemonUrl);
          results.add(
            PokemonSummary(
              id: id,
              name: details['species']['name'],
              imageUrl: details['sprites']['front_default'] ?? '',
              types: (details['types'] as List)
                  .map((typeInfo) => typeInfo['type']['name'] as String)
                  .toList(),
            ),
          );
        } catch (_) {
          // Ignorar errores individuales
        }
      });

      results.sort((a, b) => a.id.compareTo(b.id));
      return results;
    } catch (e) {
      throw Exception('Error al cargar generación $gen: $e');
    }
  }

  Future<PokemonDetail> fetchPokemonDetails(int id) async {
    try {
      final pokemonData = await _fetchWithCache('$_baseUrl/pokemon/$id');
      final speciesUrl = pokemonData['species']['url'];
      final speciesData = await _descriptionService.fetchSpeciesWithCache(
        speciesUrl,
      );

      // Stats, tipos, habilidades, etc.
      final abilitiesWithDescriptions = await _abilityService
          .getAbilitiesWithDescriptions(pokemonData);
      final description = _descriptionService.getSpanishDescription(
        speciesData,
      );
      final (evolutionChainsRaw, evolutionImages, evolutionDetails) = await _evolutionService
          .getEvolutionChainWithImagesAndDetails(speciesData);

      // Convertir las cadenas evolutivas al tipo correcto y asegurar que son List<List<String>>
      final List<List<String>> evolutionChains = evolutionChainsRaw
          .map((chain) => (chain as List).map((name) => name.toString()).toList())
          .toList();

      // Eliminar duplicados manteniendo el orden
      final List<List<String>> uniqueChains = [];
      for (var chain in evolutionChains) {
        if (!uniqueChains.any((existing) => 
          existing.length == chain.length && 
          existing.every((item) => chain.contains(item)))) {
          uniqueChains.add(chain);
        }
      }

      // Asegurar que siempre hay al menos una cadena evolutiva vacía
      final List<List<String>> evolutionChain = uniqueChains.isNotEmpty ? uniqueChains : [[]];

      // Formas/varieties
      final varietiesMap = <String, String>{};
      for (var v in speciesData['varieties']) {
        final formName = v['pokemon']['name'];
        final details = await _fetchWithCache('$_baseUrl/pokemon/$formName');
        final image =
            details['sprites']['other']?['official-artwork']?['front_default'] ??
            details['sprites']['front_default'] ??
            '';
        varietiesMap[formName] = image;
      }

      // Datos de la forma actual
      final formName = pokemonData['name'];
      final imageUrl =
          pokemonData['sprites']['other']?['official-artwork']?['front_default'] ??
          pokemonData['sprites']['front_default'] ??
          '';
      final shinyImageUrl =
          pokemonData['sprites']['other']?['official-artwork']?['front_shiny'] ??
          pokemonData['sprites']['front_shiny'] ??
          '';

      return PokemonDetail(
        id: pokemonData['id'] as int,
        speciesName: pokemonData['species']['name'] as String,
        formName: formName,
        imageUrl: imageUrl,
        shinyImageUrl: shinyImageUrl,
        types: (pokemonData['types'] as List)
            .map((t) => t['type']['name'] as String)
            .toList(),
        height: (pokemonData['height'] as int) / 10,
        weight: (pokemonData['weight'] as int) / 10,
        abilities: abilitiesWithDescriptions.keys.toList(),
        stats: Map.fromEntries(
          (pokemonData['stats'] as List).map(
            (s) => MapEntry(s['stat']['name'] as String, s['base_stat'] as int),
          ),
        ),
        description: description,
        evolutionChain: evolutionChain,
        evolutionImages: Map<String, String>.from(evolutionImages),
        abilityDescriptions: Map<String, String>.from(abilitiesWithDescriptions),
        varieties: Map<String, String>.from(varietiesMap),
        evolutionDetails: Map<String, String>.from(evolutionDetails),
      );
    } catch (e) {
      throw Exception('Error al cargar detalles del Pokémon con ID $id: $e');
    }
  }

  /// Todos los Pokémon (intenta por endpoint general, si falla usa generaciones)
  Future<List<PokemonSummary>> getAllPokemon() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/pokemon?limit=2000'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw HttpException('Error al obtener todos los Pokémon');
      }

      final data = jsonDecode(response.body);
      final results = data['results'] as List;
      final allPokemon = <PokemonSummary>[];

      await _runBatched(results, 10, (pokemon) async {
        final url = pokemon['url'];
        final id = int.parse(url.split('/')[6]);

        try {
          final details = await _fetchWithCache(url);
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
        } catch (_) {}
      });

      allPokemon.sort((a, b) => a.id.compareTo(b.id));
      return allPokemon;
    } catch (e) {
      print('Fallo al cargar todos los Pokémon: $e');
      return _getAllPokemonByGenerations();
    }
  }

  /// Fallback: cargar por generaciones
  Future<List<PokemonSummary>> _getAllPokemonByGenerations() async {
    final allPokemon = <PokemonSummary>[];

    for (int gen = 1; gen <= 9; gen++) {
      try {
        final genPokemon = await fetchPokemonFromGeneration(gen);
        allPokemon.addAll(genPokemon);
      } catch (e) {
        print('Error cargando generación $gen: $e');
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final uniquePokemon = allPokemon.toSet().toList();
    uniquePokemon.sort((a, b) => a.id.compareTo(b.id));

    return uniquePokemon;
  }

  /// Variantes de Pokémon (ID > 10000)
  Future<List<PokemonSummary>> fetchVariantPokemon() async {
    const int variantStartId = 10001;
    const int maxVariants = 400;

    final variants = <PokemonSummary>[];
    final ids = List.generate(maxVariants, (i) => variantStartId + i);

    await _runBatched(ids, 10, (id) async {
      try {
        final details = await _fetchWithCache('$_baseUrl/pokemon/$id');
        variants.add(
          PokemonSummary(
            id: id,
            name: details['name'],
            imageUrl: details['sprites']['front_default'] ?? '',
            types: (details['types'] as List)
                .map((typeInfo) => typeInfo['type']['name'] as String)
                .toList(),
          ),
        );
      } catch (_) {
        // ID no válido
      }
    });

    variants.sort((a, b) => a.id.compareTo(b.id));
    return variants;
  }
}
