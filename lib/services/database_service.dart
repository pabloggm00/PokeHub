import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokemon_summary.dart';
import '../models/pokemon_detail.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'pokemon.db';

  /// Inicializa la base de datos copiándola desde assets
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    // Verificar si ya existe
    final exists = await databaseExists(path);

    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

    // Determinar si debemos copiar la BD desde assets:
    // - Si no existe la DB en disk
    // - O si el versionCode de la app cambió desde la última instalación (update)
    int currentVersionCode = 0;
    try {
      final pkg = await PackageInfo.fromPlatform();
      currentVersionCode = int.tryParse(pkg.buildNumber) ?? 0;
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    final storedVersion = prefs.getInt('installed_version_code') ?? 0;

    final shouldCopy = !exists || storedVersion != currentVersionCode;

    if (shouldCopy && exists) {
      // Borrar base de datos antigua si existe
      await deleteDatabase(path);
    }

    if (shouldCopy) {
      // Copiar desde assets
      ByteData data = await rootBundle.load('assets/database/$_dbName');
      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(path).writeAsBytes(bytes, flush: true);

      // Guardar versionCode para futuras comprobaciones
      try {
        await prefs.setInt('installed_version_code', currentVersionCode);
      } catch (_) {}
    }

    return await openDatabase(path, readOnly: true);
  }

  /// Obtiene todas las generaciones con sus traducciones
  Future<Map<int, String>> getGenerations([int languageId = 1]) async {
    final db = await database;

    final results = await db.rawQuery(
      '''
      SELECT g.id, COALESCE(gt.name, g.code) as name
      FROM generation g
      LEFT JOIN generation_translation gt ON g.id = gt.generation_id AND gt.language_id = ?
      ORDER BY g.id
    ''',
      [languageId],
    );

    final generations = <int, String>{};
    for (var row in results) {
      final id = row['id'] as int;
      final name = row['name'] as String? ?? 'Gen $id';
      generations[id] = name;
    }

    return generations;
  }

  /// Obtiene todas las regiones con sus traducciones
  Future<Map<int, String>> getRegions([int languageId = 1]) async {
    final db = await database;

    final results = await db.rawQuery(
      '''
      SELECT r.id, r.generation_id, rt.name
      FROM region r
      LEFT JOIN region_translation rt ON r.id = rt.region_id AND rt.language_id = ?
      ORDER BY r.generation_id, r.id
    ''',
      [languageId],
    );

    final regions = <int, String>{};
    for (var row in results) {
      final id = row['id'] as int;
      final name = row['name'] as String? ?? 'Region $id';
      regions[id] = name;
    }

    return regions;
  }

  /// Obtiene todos los tipos con sus traducciones
  Future<Map<String, String>> getTypes([int languageId = 1]) async {
    final db = await database;

    final results = await db.rawQuery(
      '''
      SELECT t.code, tt.name
      FROM type t
      LEFT JOIN type_translation tt ON t.id = tt.type_id AND tt.language_id = ?
      ORDER BY t.code
    ''',
      [languageId],
    );

    final types = <String, String>{};
    for (var row in results) {
      final code = row['code'] as String;
      final name = row['name'] as String? ?? code;
      types[code] = name;
    }

    return types;
  }

  /// Obtiene todas las stats con sus traducciones (abreviaciones)
  Future<Map<String, String>> getStats([int languageId = 1]) async {
    final db = await database;

    final results = await db.rawQuery(
      '''
      SELECT s.code, COALESCE(st.abbreviation, st.name, s.code) as name
      FROM stat s
      LEFT JOIN stat_translation st ON s.id = st.stat_id AND st.language_id = ?
      ORDER BY s.id
    ''',
      [languageId],
    );

    final stats = <String, String>{};
    for (var row in results) {
      final code = row['code'] as String;
      final name = row['name'] as String? ?? code;
      stats[code] = name;
    }

    return stats;
  }

  /// Obtiene todos los Pokémon (Nacional - formas predeterminadas)
  Future<List<PokemonSummary>> getAllPokemon([int languageId = 1]) async {
    final db = await database;

    final results = await db.rawQuery(
      '''
      SELECT
        p.id,
        ps.national_dex_number,
        ps.generation_id as generation_id,
        p.form_name,
        COALESCE(pt.form_display_name, '') as display_name,
        pi.normal_image_url as image_url,
        GROUP_CONCAT(DISTINCT t.code) as types
      FROM pokemon p
      INNER JOIN pokemon_species ps ON p.species_id = ps.id
      LEFT JOIN pokemon_translation pt ON p.id = pt.pokemon_id AND pt.language_id = ?
      LEFT JOIN pokemon_image pi ON p.id = pi.pokemon_id
      INNER JOIN pokemon_type pt2 ON p.id = pt2.pokemon_id
      INNER JOIN type t ON pt2.type_id = t.id
      WHERE p.is_default_form = 1
      GROUP BY p.id, ps.national_dex_number, ps.generation_id, p.form_name, pi.normal_image_url
      ORDER BY ps.national_dex_number
    ''',
      [languageId],
    );

    return results.map((row) {
      final typesStr = row['types'] as String?;
      final types = typesStr?.split(',').map((t) => t.trim()).toList() ?? [];

      final displayName = row['display_name'] as String? ?? '';
      final imageUrl = _normalizeImageUrl(row['image_url'] as String?);

      return PokemonSummary(
        id: row['id'] as int,
        nationalDexNumber: row['national_dex_number'] as int,
        generationId: row['generation_id'] as int,
        name: displayName.isNotEmpty ? displayName : 'Desconocido',
        imageUrl: imageUrl,
        types: types,
      );
    }).toList();
  }

  /// Obtiene todos los Pokémon incluyendo todas las variantes (no solo la forma por defecto)
  Future<List<PokemonSummary>> getAllPokemonIncludeVariants([int languageId = 1]) async {
    final db = await database;

    final results = await db.rawQuery(
      '''
      SELECT
        p.id,
        ps.national_dex_number,
        ps.generation_id as generation_id,
        p.form_name,
        COALESCE(pt.form_display_name, '') as display_name,
        pi.normal_image_url as image_url,
        GROUP_CONCAT(DISTINCT t.code) as types
      FROM pokemon p
      INNER JOIN pokemon_species ps ON p.species_id = ps.id
      LEFT JOIN pokemon_translation pt ON p.id = pt.pokemon_id AND pt.language_id = ?
      LEFT JOIN pokemon_image pi ON p.id = pi.pokemon_id
      INNER JOIN pokemon_type pt2 ON p.id = pt2.pokemon_id
      INNER JOIN type t ON pt2.type_id = t.id
      GROUP BY p.id, ps.national_dex_number, ps.generation_id, p.form_name, pi.normal_image_url
      ORDER BY ps.national_dex_number
    ''',
      [languageId],
    );

    return results.map((row) {
      final typesStr = row['types'] as String?;
      final types = typesStr?.split(',').map((t) => t.trim()).toList() ?? [];

      final displayName = row['display_name'] as String? ?? '';
      final imageUrl = _normalizeImageUrl(row['image_url'] as String?);

      return PokemonSummary(
        id: row['id'] as int,
        nationalDexNumber: row['national_dex_number'] as int,
        generationId: row['generation_id'] as int,
        name: displayName.isNotEmpty ? displayName : 'Desconocido',
        imageUrl: imageUrl,
        types: types,
      );
    }).toList();
  }

  /// Obtiene Pokémon filtrados por región
  Future<List<PokemonSummary>> getPokemonByRegion(
    int regionId, [
    int languageId = 1,
  ]) async {
    final db = await database;

    final results = await db.rawQuery(
      '''
    SELECT
      p.id,
      ps.national_dex_number,
      ps.generation_id as generation_id,
      par.regional_dex_number,
      COALESCE(pt.form_display_name, '') as display_name,
      pi.normal_image_url as image_url,
      GROUP_CONCAT(DISTINCT t.code) as types
    FROM pokemon_available_in_region par
    INNER JOIN pokemon p ON par.pokemon_id = p.id
    INNER JOIN pokemon_species ps ON p.species_id = ps.id
    LEFT JOIN pokemon_translation pt ON p.id = pt.pokemon_id AND pt.language_id = ?
    LEFT JOIN pokemon_image pi ON p.id = pi.pokemon_id
    INNER JOIN pokemon_type ptype ON p.id = ptype.pokemon_id
    INNER JOIN type t ON ptype.type_id = t.id
    WHERE par.region_id = ?
    GROUP BY p.id, ps.national_dex_number, ps.generation_id, par.regional_dex_number
    ORDER BY par.regional_dex_number ASC
  ''',
      [languageId, regionId],
    );

    return results.map((row) {
      final typesStr = row['types'] as String?;
      final types = typesStr?.split(',').map((t) => t.trim()).toList() ?? [];

      final displayName = row['display_name'] as String? ?? '';
      final imageUrl = _normalizeImageUrl(row['image_url'] as String?);

      return PokemonSummary(
        id: row['id'] as int,
        nationalDexNumber: row['national_dex_number'] as int,
        generationId: row['generation_id'] as int,
        name: displayName.isNotEmpty ? displayName : 'Desconocido',
        imageUrl: imageUrl,
        types: types,
      );
    }).toList();
  }

  /// Obtiene Pokémon filtrados por tipo
  Future<List<PokemonSummary>> getPokemonByType(
    String typeCode, [
    int languageId = 1,
  ]) async {
    final db = await database;

    final results = await db.rawQuery(
      '''
      SELECT
        p.id,
        ps.national_dex_number,
        ps.generation_id as generation_id,
        p.form_name,
        COALESCE(pt.form_display_name, '') as display_name,
        pi.normal_image_url as image_url,
        GROUP_CONCAT(DISTINCT t2.code) as types
      FROM pokemon p
      INNER JOIN pokemon_species ps ON p.species_id = ps.id
      LEFT JOIN pokemon_translation pt ON p.id = pt.pokemon_id AND pt.language_id = ?
      LEFT JOIN pokemon_image pi ON p.id = pi.pokemon_id
      INNER JOIN pokemon_type pt1 ON p.id = pt1.pokemon_id
      INNER JOIN type t ON pt1.type_id = t.id
      LEFT JOIN pokemon_type pt2 ON p.id = pt2.pokemon_id
      LEFT JOIN type t2 ON pt2.type_id = t2.id
      WHERE p.is_default_form = 1 AND t.code = ?
      GROUP BY p.id, ps.national_dex_number, ps.generation_id, p.form_name, pi.normal_image_url
      ORDER BY ps.national_dex_number
    ''',
      [languageId, typeCode],
    );

    return results.map((row) {
      final typesStr = row['types'] as String?;
      final types = typesStr?.split(',').map((t) => t.trim()).toList() ?? [];

      final displayName = row['display_name'] as String? ?? '';
      final imageUrl = _normalizeImageUrl(row['image_url'] as String?);

      return PokemonSummary(
        id: row['id'] as int,
        nationalDexNumber: row['national_dex_number'] as int,
        generationId: row['generation_id'] as int,
        name: displayName.isNotEmpty ? displayName : 'Desconocido',
        imageUrl: imageUrl,
        types: types,
      );
    }).toList();
  }

  /// Obtiene los detalles de un Pokémon específico
  Future<PokemonDetail> getPokemonDetails(
    int pokemonId, [
    int languageId = 1,
  ]) async {
    final db = await database;

    // Información básica del Pokémon
    final pokemonResult = await db.rawQuery(
      '''
      SELECT 
        p.id,
        p.species_id,
        p.form_name,
        p.height,
        p.weight,
        COALESCE(pt.form_display_name, 'Desconocido') as display_name,
        COALESCE(pt.description, '') as description,
        pi.normal_image_url as image_url,
        pi.shiny_image_url as shiny_image_url
      FROM pokemon p
      INNER JOIN pokemon_species ps ON p.species_id = ps.id
      LEFT JOIN pokemon_translation pt ON p.id = pt.pokemon_id AND pt.language_id = ?
      LEFT JOIN pokemon_image pi ON p.id = pi.pokemon_id
      WHERE p.id = ?
      LIMIT 1
    ''',
      [languageId, pokemonId],
    );

    if (pokemonResult.isEmpty) {
      throw Exception('Pokémon no encontrado');
    }

    final pokemon = pokemonResult.first;

    // Tipos
    final typesResult = await db.rawQuery(
      '''
      SELECT t.code
      FROM pokemon_type pt
      INNER JOIN type t ON pt.type_id = t.id
      WHERE pt.pokemon_id = ?
      ORDER BY pt.slot
    ''',
      [pokemonId],
    );
    final types = typesResult.map((r) => r['code'] as String).toList();

    // Habilidades con descripciones
    final abilitiesResult = await db.rawQuery(
      '''
      SELECT 
        COALESCE(at.name, 'Habilidad') as name,
        COALESCE(at.description, '') as description,
        pa.is_hidden
      FROM pokemon_ability pa
      INNER JOIN ability a ON pa.ability_id = a.id
      LEFT JOIN ability_translation at ON a.id = at.ability_id AND at.language_id = ?
      WHERE pa.pokemon_id = ?
      ORDER BY pa.is_hidden, a.id
    ''',
      [languageId, pokemonId],
    );

    final abilities = <String>[];
    final abilityDescriptions = <String, String>{};
    for (var row in abilitiesResult) {
      final name = row['name'] as String;
      final desc = row['description'] as String;
      abilities.add(name);
      abilityDescriptions[name] = desc;
    }

    // Stats
    final statsResult = await db.rawQuery(
      '''
      SELECT 
        s.code,
        ps.base_value,
        COALESCE(st.abbreviation, s.code) as stat_name
      FROM pokemon_stat ps
      INNER JOIN stat s ON ps.stat_id = s.id
      LEFT JOIN stat_translation st ON s.id = st.stat_id AND st.language_id = ?
      WHERE ps.pokemon_id = ?
    ''',
      [languageId, pokemonId],
    );
    final stats = <String, int>{};
    final statTranslations = <String, String>{};
    for (var row in statsResult) {
      final code = row['code'] as String;
      stats[code] = row['base_value'] as int;
      statTranslations[code] = row['stat_name'] as String;
    }

    // Evoluciones (cadena evolutiva completa)
    final evolutionResult = await db.rawQuery(
      '''
      SELECT 
        ec.id as chain_id,
        pe.id as evolution_id,
        pe.from_pokemon_id,
        pe.to_pokemon_id,
        COALESCE(pet.condition, '') as condition,
        COALESCE(pt_from.form_display_name, 'Pokémon') as from_name,
        COALESCE(pt_to.form_display_name, 'Pokémon') as to_name,
        pi_from.normal_image_url as from_image,
        pi_to.normal_image_url as to_image
      FROM evolution_chain ec
      INNER JOIN pokemon_evolution pe ON ec.id = pe.chain_id
      LEFT JOIN pokemon_evolution_translation pet ON pe.id = pet.evolution_id AND pet.language_id = ?
      INNER JOIN pokemon p_from ON pe.from_pokemon_id = p_from.id
      INNER JOIN pokemon p_to ON pe.to_pokemon_id = p_to.id
      LEFT JOIN pokemon_translation pt_from ON p_from.id = pt_from.pokemon_id AND pt_from.language_id = ?
      LEFT JOIN pokemon_translation pt_to ON p_to.id = pt_to.pokemon_id AND pt_to.language_id = ?
      LEFT JOIN pokemon_image pi_from ON p_from.id = pi_from.pokemon_id
      LEFT JOIN pokemon_image pi_to ON p_to.id = pi_to.pokemon_id
      WHERE ec.id IN (
        SELECT DISTINCT pe2.chain_id 
        FROM pokemon_evolution pe2 
        WHERE pe2.from_pokemon_id = ? OR pe2.to_pokemon_id = ?
      )
      ORDER BY ec.id, pe.id
    ''',
      [languageId, languageId, languageId, pokemonId, pokemonId],
    );

    // Construir cadenas evolutivas
    final evolutionChainMap = <int, Map<int, String>>{};
    final evolutionImages = <String, String>{};
    final evolutionIds = <String, int>{};
    final evolutionDetails = <String, String>{};
    final evolutionConnections = <int, List<Map<String, dynamic>>>{};

    for (var row in evolutionResult) {
      final chainId = row['chain_id'] as int;
      final fromPokemonId = row['from_pokemon_id'] as int;
      final toPokemonId = row['to_pokemon_id'] as int;
      final fromName = row['from_name'] as String;
      final toName = row['to_name'] as String;
      final fromImage = _normalizeImageUrl(row['from_image'] as String?);
      final toImage = _normalizeImageUrl(row['to_image'] as String?);
      final condition = row['condition'] as String;

      if (!evolutionChainMap.containsKey(chainId)) {
        evolutionChainMap[chainId] = {};
        evolutionConnections[chainId] = [];
      }

      if (fromName.isNotEmpty) {
        evolutionChainMap[chainId]![fromPokemonId] = fromName;
      }
      if (toName.isNotEmpty) {
        evolutionChainMap[chainId]![toPokemonId] = toName;
      }

      evolutionConnections[chainId]!.add({
        'from': fromPokemonId,
        'to': toPokemonId,
        'condition': condition,
        'fromName': fromName,
        'toName': toName,
      });

      if (fromName.isNotEmpty && fromImage.isNotEmpty) {
        evolutionImages[fromName] = fromImage;
        evolutionIds[fromName] = fromPokemonId;
      }
      if (toName.isNotEmpty && toImage.isNotEmpty) {
        evolutionImages[toName] = toImage;
        evolutionIds[toName] = toPokemonId;
      }

      if (condition.isNotEmpty && fromName.isNotEmpty && toName.isNotEmpty) {
        evolutionDetails['$fromName->$toName'] = condition;
      }
    }

    // Construir las cadenas en orden correcto
    final evolutionChain = <List<String>>[];
    for (var chainId in evolutionChainMap.keys) {
      final pokemonMap = evolutionChainMap[chainId]!;
      final connections = evolutionConnections[chainId]!;

      final allFrom = connections.map((c) => c['from'] as int).toSet();
      final allTo = connections.map((c) => c['to'] as int).toSet();
      final starts = allFrom.difference(allTo);

      void exploreBranches(int currentId, List<String> currentChain) {
        if (pokemonMap.containsKey(currentId)) {
          currentChain.add(pokemonMap[currentId]!);
        }

        final nextEvolutions = connections
            .where((c) => c['from'] == currentId)
            .toList();

        if (nextEvolutions.isEmpty) {
          if (currentChain.isNotEmpty) {
            evolutionChain.add(List<String>.from(currentChain));
          }
        } else {
          for (var evolution in nextEvolutions) {
            final nextId = evolution['to'] as int;
            exploreBranches(nextId, List<String>.from(currentChain));
          }
        }
      }

      for (var startId in starts) {
        exploreBranches(startId, []);
      }
    }

    // Variedades (todas las formas alternativas de la misma especie)
    final varietiesResult = await db.rawQuery(
      '''
      SELECT 
        p.id,
        COALESCE(pt.form_display_name, 'Pokémon') as display_name,
        pi.normal_image_url as image_url
      FROM pokemon p
      LEFT JOIN pokemon_translation pt ON p.id = pt.pokemon_id AND pt.language_id = ?
      LEFT JOIN pokemon_image pi ON p.id = pi.pokemon_id
      WHERE p.species_id = ? 
        AND p.id != ?
      ORDER BY p.id
    ''',
      [languageId, pokemon['species_id'], pokemonId],
    );

    final varieties = <String, String>{};
    final varietyIds = <String, int>{};

    for (var row in varietiesResult) {
      final id = row['id'] as int;
      final displayName = row['display_name'] as String;
print(id);
      final imageUrl = _normalizeImageUrl(row['image_url'] as String?);

      
      if (displayName.isNotEmpty) {
        varieties[displayName] = imageUrl;
        varietyIds[displayName] = id;
      }
    }

    return PokemonDetail(
      id: pokemon['id'] as int,
      speciesName: pokemon['display_name'] as String? ?? 'Desconocido',
      formName: pokemon['form_name'] as String? ?? 'normal',
      imageUrl: _normalizeImageUrl(pokemon['image_url'] as String?),
      shinyImageUrl: _normalizeImageUrl(pokemon['shiny_image_url'] as String?),
      types: types,
      height: (pokemon['height'] as num?)?.toDouble() ?? 0.0,
      weight: (pokemon['weight'] as num?)?.toDouble() ?? 0.0,
      abilities: abilities,
      stats: stats,
      description: pokemon['description'] as String? ?? '',
      evolutionChain: evolutionChain,
      evolutionImages: evolutionImages,
      evolutionIds: evolutionIds,
      abilityDescriptions: abilityDescriptions,
      varieties: varieties,
      varietyIds: varietyIds,
      evolutionDetails: evolutionDetails,
    );
  }

  /// Buscar Pokémon por nombre
  Future<List<PokemonSummary>> searchPokemon(
    String query, [
    int languageId = 1,
  ]) async {
    final db = await database;

    final results = await db.rawQuery(
      '''
      SELECT
        p.id,
        ps.national_dex_number,
        ps.generation_id as generation_id,
        p.form_name,
        COALESCE(pt.form_display_name, '') as display_name,
        pi.normal_image_url as image_url,
        GROUP_CONCAT(DISTINCT t.code) as types
      FROM pokemon p
      INNER JOIN pokemon_species ps ON p.species_id = ps.id
      LEFT JOIN pokemon_translation pt ON p.id = pt.pokemon_id AND pt.language_id = ?
      LEFT JOIN pokemon_image pi ON p.id = pi.pokemon_id
      INNER JOIN pokemon_type pt2 ON p.id = pt2.pokemon_id
      INNER JOIN type t ON pt2.type_id = t.id
      WHERE p.is_default_form = 1
        AND (LOWER(pt.form_display_name) LIKE LOWER(?) OR CAST(ps.national_dex_number AS TEXT) LIKE ?)
      GROUP BY p.id, ps.national_dex_number, ps.generation_id, p.form_name, pi.normal_image_url
      ORDER BY ps.national_dex_number
      LIMIT 50
    ''',
      [languageId, '%$query%', '%$query%'],
    );

    return results.map((row) {
      final typesStr = row['types'] as String?;
      final types = typesStr?.split(',').map((t) => t.trim()).toList() ?? [];

      final displayName = row['display_name'] as String? ?? '';
      final imageUrl = _normalizeImageUrl(row['image_url'] as String?);

      return PokemonSummary(
        id: row['id'] as int,
        nationalDexNumber: row['national_dex_number'] as int,
        generationId: row['generation_id'] as int,
        name: displayName.isNotEmpty ? displayName : 'Desconocido',
        imageUrl: imageUrl,
        types: types,
      );
    }).toList();
  }

  /// Normaliza las rutas de imágenes desde la base de datos
  String _normalizeImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return '';
    }
    
    // Si ya contiene el prefijo, retornar como está
    if (imageUrl.startsWith('assets/')) {
      return imageUrl;
    }
    
    // Si la ruta es relativa, agregar el prefijo
    if (!imageUrl.startsWith('/')) {
      return 'assets/imagenes/$imageUrl';
    }
    
    // Si comienza con /, remover y agregar prefijo
    return 'assets/imagenes/${imageUrl.substring(1)}';
  }

  /// Cierra la base de datos
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
