import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class EvolutionService {
  final Box _hiveCache = Hive.box('pokeCache');

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

  Future<String> _getEvolutionImage(String pokemonName) async {
    try {
      final pokemonData = await _fetchWithCache(
        'https://pokeapi.co/api/v2/pokemon/$pokemonName',
      );
      final imageUrl = pokemonData['sprites']['other']?['official-artwork']?['front_default'] ??
          pokemonData['sprites']['front_default'];
      
      // Only return non-empty URLs
      if (imageUrl != null && imageUrl.toString().isNotEmpty && imageUrl.toString().startsWith('http')) {
        return imageUrl.toString();
      }
      return '';
    } catch (e) {
      print('Error getting evolution image for $pokemonName: $e');
      return '';
    }
  }

  String _formatItemName(String name) {
    final translations = {
      'fire-stone': 'Piedra Fuego',
      'water-stone': 'Piedra Agua',
      'thunder-stone': 'Piedra Trueno',
      'leaf-stone': 'Piedra Hoja',
      'moon-stone': 'Piedra Luna',
      'sun-stone': 'Piedra Solar',
      'shiny-stone': 'Piedra Día',
      'dusk-stone': 'Piedra Noche',
      'dawn-stone': 'Piedra Alba',
      'ice-stone': 'Piedra Hielo',
    };
    return translations[name] ?? name.replaceAll('-', ' ').toUpperCase();
  }

  String _formatMoveName(String name) {
    return name.replaceAll('-', ' ').toUpperCase();
  }

  Future<(List<List<String>>, Map<String, String>, Map<String, String>)> getEvolutionChainWithImagesAndDetails(
    Map<String, dynamic> speciesData,
  ) async {
    final evolutionUrl = speciesData['evolution_chain']?['url'];
    print('Evolution URL: $evolutionUrl');

    if (evolutionUrl == null) {
      final currentName = speciesData['name'] as String;
      return (
        [[currentName]],
        {currentName: await _getEvolutionImage(currentName)},
        <String, String>{},
      );
    }

    try {
      final rawData = await _fetchWithCache(evolutionUrl);
      print('Raw Evolution Data: $rawData');
      
      final allEvolutionChains = <List<String>>[];
      final evolutionImages = <String, String>{};
      final evolutionDetails = <String, String>{};
      final processedPokemon = <String>{};

      // Función recursiva local para procesar la cadena evolutiva
      void processChain(Map<dynamic, dynamic> chain, List<String> currentChain, [String? previousPokemon]) {
        if (chain['species'] == null) return;
        
        final speciesData = chain['species'] as Map<dynamic, dynamic>;
        final currentPokemon = speciesData['name'] as String;
        print('Processing Pokemon: $currentPokemon in chain: $currentChain');
        
        if (!processedPokemon.contains(currentPokemon)) {
          processedPokemon.add(currentPokemon);
        }

        // Procesar detalles de evolución si este no es el Pokémon base
        if (previousPokemon != null) {
          final details = chain['evolution_details'] as List<dynamic>?;
          if (details != null && details.isNotEmpty) {
            final detail = details[0] as Map<dynamic, dynamic>;
            String evolutionMethod = '';

            if (detail['min_level'] != null) {
              evolutionMethod = 'Nivel ${detail['min_level']}';
            } else if (detail['item'] != null) {
              final item = detail['item'] as Map<dynamic, dynamic>;
              evolutionMethod = 'Usar ${_formatItemName(item['name'] as String)}';
            } else if (detail['min_happiness'] != null) {
              evolutionMethod = 'Felicidad ${detail['min_happiness']}';
            } else if (detail['min_affection'] != null) {
              evolutionMethod = 'Amistad ${detail['min_affection']}';
            } else if (detail['time_of_day'] != null && detail['time_of_day'].toString().isNotEmpty) {
              evolutionMethod = 'Durante ${detail['time_of_day'] == 'day' ? 'el día' : 'la noche'}';
            } else if (detail['known_move'] != null) {
              final move = detail['known_move'] as Map<dynamic, dynamic>;
              evolutionMethod = 'Conocer ${_formatMoveName(move['name'] as String)}';
            } else if (detail['trade_species'] != null) {
              evolutionMethod = 'Intercambio';
            } else if (detail['held_item'] != null) {
              final item = detail['held_item'] as Map<dynamic, dynamic>;
              evolutionMethod = 'Intercambio con ${_formatItemName(item['name'] as String)}';
            } else if (detail['trigger'] != null) {
              final trigger = detail['trigger'] as Map<dynamic, dynamic>;
              final triggerName = trigger['name'] as String;
              if (triggerName == 'trade') {
                evolutionMethod = 'Intercambio';
              } else if (triggerName == 'level-up') {
                evolutionMethod = 'Subir de nivel';
              }
            }

            if (evolutionMethod.isNotEmpty) {
              evolutionDetails[previousPokemon] = evolutionMethod;
              print('Added evolution method for $previousPokemon -> $currentPokemon: $evolutionMethod');
            }
          }
        }

        currentChain.add(currentPokemon);

        // Procesar evoluciones siguientes
        final evolvesTo = chain['evolves_to'] as List<dynamic>?;
        if (evolvesTo != null && evolvesTo.isNotEmpty) {
          if (evolvesTo.length > 1) {
            // Si hay múltiples evoluciones, crear una nueva cadena para cada una
            print('Found branching evolution for $currentPokemon with ${evolvesTo.length} branches');
            for (var evolution in evolvesTo) {
              final newChain = List<String>.from(currentChain);
              processChain(evolution as Map<dynamic, dynamic>, newChain, currentPokemon);
            }
          } else {
            // Si solo hay una evolución, continuar con la cadena actual
            processChain(evolvesTo[0] as Map<dynamic, dynamic>, currentChain, currentPokemon);
            if (currentChain.length > 1 && !allEvolutionChains.any((chain) =>
                chain.length == currentChain.length &&
                chain.every((pokemon) => currentChain.contains(pokemon)))) {
              allEvolutionChains.add(List<String>.from(currentChain));
            }
          }
        } else if (currentChain.length > 1 && !allEvolutionChains.any((chain) =>
            chain.length == currentChain.length &&
            chain.every((pokemon) => currentChain.contains(pokemon)))) {
          // Si es el final de una cadena, añadirla solo si no existe ya
          allEvolutionChains.add(List<String>.from(currentChain));
        }
      }

      // Comenzar el procesamiento desde la base de la cadena
      processChain(rawData['chain'] as Map<dynamic, dynamic>, []);
      print('All Evolution Chains: $allEvolutionChains');

      // Si no hay cadenas ramificadas pero hay Pokémon procesados, usar todos como una cadena
      if (allEvolutionChains.isEmpty && processedPokemon.isNotEmpty) {
        allEvolutionChains.add(processedPokemon.toList());
      }

      // Obtener las imágenes para todos los Pokémon procesados
      for (String name in processedPokemon) {
        try {
          final imageUrl = await _getEvolutionImage(name);
          evolutionImages[name] = imageUrl;
          print('Added evolution image for $name: $imageUrl');
        } catch (e) {
          print('Error getting image for $name: $e');
          evolutionImages[name] = '';
        }
      }

      print('Evolution Chains: $allEvolutionChains');
      print('Evolution Details: $evolutionDetails');
      print('Evolution Images: $evolutionImages');

      if (allEvolutionChains.isEmpty) {
        throw Exception('No evolution chain found');
      }

      return (allEvolutionChains, evolutionImages, evolutionDetails);
    } catch (e) {
      print('Error processing evolution chain: $e');
      final currentName = speciesData['name'] as String;
      final image = await _getEvolutionImage(currentName);
      return (
        [[currentName]],
        {currentName: image},
        <String, String>{},
      );
    }
  }
}
