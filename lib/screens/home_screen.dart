import 'package:dex_app/screens/pokemon_detail_screen.dart';
import 'package:dex_app/screens/search_screen.dart';
import 'package:dex_app/screens/settings_screen.dart';
import 'package:dex_app/services/api_service.dart';
import 'package:dex_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../models/pokemon_summary.dart';
import '../widgets/pokemon_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PokeApiService _api = PokeApiService();
  List<PokemonSummary> _allPokemons = [];
  List<PokemonSummary> _filteredPokemons = [];
  int? _selectedGen;
  String? _selectedType;
  bool _isLoading = false;

  final Map<int, String> _genNames = {
    1: "Kanto",
    2: "Johto",
    3: "Hoenn",
    4: "Sinnoh",
    5: "Unova",
    6: "Kalos",
    7: "Alola",
    8: "Galar",
    9: "Paldea",
    10: "Variantes",
  };

  final List<String> _types = [
    "normal", "fire", "water", "electric", "grass", "ice",
    "fighting", "poison", "ground", "flying", "psychic", "bug",
    "rock", "ghost", "dragon", "dark", "steel", "fairy"
  ];

  final Map<String, String> _typeTranslations = {
    "normal": "Normal",
    "fire": "Fuego",
    "water": "Agua",
    "electric": "Eléctrico",
    "grass": "Planta",
    "ice": "Hielo",
    "fighting": "Lucha",
    "poison": "Veneno",
    "ground": "Tierra",
    "flying": "Volador",
    "psychic": "Psíquico",
    "bug": "Bicho",
    "rock": "Roca",
    "ghost": "Fantasma",
    "dragon": "Dragón",
    "dark": "Siniestro",
    "steel": "Acero",
    "fairy": "Hada",
  };

  @override
  void initState() {
    super.initState();
    _loadAllPokemon();
  }

  Future<void> _loadAllPokemon() async {
    setState(() => _isLoading = true);

    try {
      final allPokemon = await _api.getAllPokemon();
      setState(() {
        _allPokemons = allPokemon;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<PokemonSummary> filtered = List.from(_allPokemons);

    // Filtrar por generación
    if (_selectedGen != null) {
      if (_selectedGen == 10) {
        filtered = filtered.where((p) => p.id >= 10001).toList();
      } else {
        // Rangos aproximados de cada generación
        final genRanges = {
          1: [1, 151],
          2: [152, 251],
          3: [252, 386],
          4: [387, 493],
          5: [494, 649],
          6: [650, 721],
          7: [722, 809],
          8: [810, 905],
          9: [906, 1025],
        };
        final range = genRanges[_selectedGen];
        if (range != null) {
          filtered = filtered.where((p) => p.id >= range[0] && p.id <= range[1]).toList();
        }
      }
    }

    // Filtrar por tipo
    if (_selectedType != null) {
      filtered = filtered.where((p) => p.types.contains(_selectedType)).toList();
    }

    setState(() => _filteredPokemons = filtered);
  }

  Future<void> _loadGeneration(int? gen) async {
    setState(() => _selectedGen = gen);
    _applyFilters();
  }

  void _selectType(String? type) {
    setState(() => _selectedType = type);
    _applyFilters();
  }

  void _navigateToSearchScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchScreen(apiService: _api)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: const Text('PokeHub', style: AppColors.title),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // Filtros en desplegables
          Container(
            color: AppColors.cardBackground,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Filtro de Región
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Región",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.unselectedGen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<int?>(
                          value: _selectedGen,
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: AppColors.cardBackground,
                          style: const TextStyle(color: Colors.white),
                          hint: const Text(
                            "Todas",
                            style: TextStyle(color: Colors.white),
                          ),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text("Todas"),
                            ),
                            ..._genNames.entries.map((entry) {
                              return DropdownMenuItem<int?>(
                                value: entry.key,
                                child: Text(entry.value),
                              );
                            }),
                          ],
                          onChanged: (value) => _loadGeneration(value),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Filtro de Tipo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tipo",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.unselectedGen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String?>(
                          value: _selectedType,
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: AppColors.cardBackground,
                          style: const TextStyle(color: Colors.white),
                          hint: const Text(
                            "Todos",
                            style: TextStyle(color: Colors.white),
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text("Todos"),
                            ),
                            ..._types.map((type) {
                              return DropdownMenuItem<String?>(
                                value: type,
                                child: Text(_typeTranslations[type] ?? type),
                              );
                            }),
                          ],
                          onChanged: (value) => _selectType(value),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Listado de Pokémon
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.selectedGen,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filteredPokemons.length,
                    itemBuilder: (context, index) {
                      return PokemonCard(
                        pokemon: _filteredPokemons[index],
                        onTap: () async {
                          final details = await _api.fetchPokemonDetails(
                            _filteredPokemons[index].id,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PokemonDetailScreen(pokemon: details),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToSearchScreen,
        backgroundColor: AppColors.selectedGen,
        child: const Icon(Icons.search, color: Colors.white),
      ),
    );
  }
}
