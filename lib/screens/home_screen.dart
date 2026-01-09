import 'package:dex_app/screens/pokemon_detail_screen.dart';
import 'package:dex_app/screens/search_screen.dart';
import 'package:dex_app/screens/settings_screen.dart';
import 'package:dex_app/services/database_service.dart';
import 'package:dex_app/services/type_translator.dart';
import 'package:dex_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:dex_app/l10n/app_localizations.dart';
import '../models/pokemon_summary.dart';
import '../widgets/pokemon_card.dart';

class HomeScreen extends StatefulWidget {
  final int languageId;
  final VoidCallback onLanguageToggle;

  const HomeScreen({
    super.key,
    required this.languageId,
    required this.onLanguageToggle,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<PokemonSummary> _allPokemons = [];
  List<PokemonSummary> _filteredPokemons = [];
  int? _selectedGen;
  int? _selectedRegion;
  String? _selectedType;
  String? _selectedType2;
  bool _isLoading = false;

  Map<int, String> _genNames = {};
  Map<int, String> _regionNames = {};
  Map<String, String> _typeTranslations = {};
  List<String> _types = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.languageId != widget.languageId) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Cargar generaciones, regiones y tipos desde la BD
      _genNames = await _dbService.getGenerations(widget.languageId);
      _regionNames = await _dbService.getRegions(widget.languageId);
      _typeTranslations = await _dbService.getTypes(widget.languageId);
      _types = _typeTranslations.keys.toList();

      // Establecer traducciones globales
      TypeTranslator.setTranslations(_typeTranslations);

      // Cargar traducciones de stats
      final statTranslations = await _dbService.getStats(widget.languageId);
      StatTranslator.setTranslations(statTranslations);

      // Cargar todos los Pokémon
      final allPokemon = await _dbService.getAllPokemon(widget.languageId);

      setState(() {
        _allPokemons = allPokemon;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorLoadingData(e.toString()),
            ),
          ),
        );
      }
    }
  }

  void _applyFilters() async {
    setState(() => _isLoading = true);

    try {
      List<PokemonSummary> filtered;

      // Base: start with region if selected for efficient narrowing
      if (_selectedRegion != null) {
        filtered = await _dbService.getPokemonByRegion(
          _selectedRegion!,
          widget.languageId,
        );
      } else if (_selectedType != null && _selectedType2 == null) {
        // If only one type selected and no region, hit DB for that type
        filtered = await _dbService.getPokemonByType(
          _selectedType!,
          widget.languageId,
        );
      } else if (_selectedType2 != null && _selectedType == null) {
        // Only secondary type selected
        filtered = await _dbService.getPokemonByType(
          _selectedType2!,
          widget.languageId,
        );
      } else {
        // No region/type DB filter available — use full list
        filtered = _allPokemons;
      }

      // Apply type filters in Dart (supports selecting both types)
      if (_selectedType != null) {
        filtered = filtered
            .where((p) => p.types.contains(_selectedType))
            .toList();
      }
      if (_selectedType2 != null) {
        filtered = filtered
            .where((p) => p.types.contains(_selectedType2))
            .toList();
      }

      // Filtrar por generación si está seleccionada (usar generationId desde la BD)
      if (_selectedGen != null) {
        filtered = filtered
            .where((p) => p.generationId == _selectedGen)
            .toList();
      }

      setState(() {
        _filteredPokemons = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _filteredPokemons = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _loadGeneration(int? gen) async {
    setState(() => _selectedGen = gen);
    _applyFilters();
  }

  Future<void> _loadRegion(int? region) async {
    setState(() => _selectedRegion = region);
    _applyFilters();
  }

  void _selectType(String? type) {
    setState(() => _selectedType = type);
    _applyFilters();
  }

  void _selectType2(String? type) {
    setState(() => _selectedType2 = type);
    _applyFilters();
  }

  void _resetFilters() {
    setState(() {
      _selectedGen = null;
      _selectedRegion = null;
      _selectedType = null;
      _selectedType2 = null;
    });
    _applyFilters();
  }

  void _navigateToSearchScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(dbService: _dbService),
      ),
    );
  }

  void _toggleLanguage() {
    widget.onLanguageToggle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          AppLocalizations.of(context)!.appTitle,
          style: AppColors.title,
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetFilters,
            tooltip: 'Reiniciar filtros',
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _toggleLanguage,
            tooltip: widget.languageId == 1
                ? AppLocalizations.of(context)!.spanish
                : AppLocalizations.of(context)!.english,
          ),
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
            child: Column(
              children: [
                Row(
                  children: [
                    // Filtro de Generación
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Generación',
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
                            child: SizedBox(
                              width: double.infinity,
                              child: ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButton<int?>(
                                  value: _selectedGen,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  dropdownColor: AppColors.cardBackground,
                                  style: const TextStyle(color: Colors.white),
                                  hint: Text(
                                    AppLocalizations.of(context)!.all,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  items: [
                                    DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text(
                                        AppLocalizations.of(context)!.all,
                                      ),
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
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Filtro de Región
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.region,
                            style: const TextStyle(
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
                            child: SizedBox(
                              width: double.infinity,
                              child: ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButton<int?>(
                                  value: _selectedRegion,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  dropdownColor: AppColors.cardBackground,
                                  style: const TextStyle(color: Colors.white),
                                  hint: Text(
                                    AppLocalizations.of(context)!.all,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  items: [
                                    DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text(
                                        AppLocalizations.of(context)!.all,
                                      ),
                                    ),
                                    ..._regionNames.entries.map((entry) {
                                      return DropdownMenuItem<int?>(
                                        value: entry.key,
                                        child: Text(entry.value),
                                      );
                                    }),
                                  ],
                                  onChanged: (value) => _loadRegion(value),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Filtro de Tipo (dos columnas)
                Row(
                  children: [
                    // Tipo principal
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.type,
                            style: const TextStyle(
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
                            child: SizedBox(
                              width: double.infinity,
                              child: ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButton<String?>(
                                  value: _selectedType,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  dropdownColor: AppColors.cardBackground,
                                  style: const TextStyle(color: Colors.white),
                                  hint: Text(
                                    AppLocalizations.of(context)!.allTypes,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  items: [
                                    DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text(
                                        AppLocalizations.of(context)!.allTypes,
                                      ),
                                    ),
                                    ..._types.map((type) {
                                      return DropdownMenuItem<String?>(
                                        value: type,
                                        child: Text(
                                          _typeTranslations[type] ?? type,
                                        ),
                                      );
                                    }),
                                  ],
                                  onChanged: (value) => _selectType(value),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Tipo secundario
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tipo 2',
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
                            child: SizedBox(
                              width: double.infinity,
                              child: ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButton<String?>(
                                  value: _selectedType2,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  dropdownColor: AppColors.cardBackground,
                                  style: const TextStyle(color: Colors.white),
                                  hint: Text(
                                    AppLocalizations.of(context)!.allTypes,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  items: [
                                    DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text(
                                        AppLocalizations.of(context)!.allTypes,
                                      ),
                                    ),
                                    ..._types.map((type) {
                                      return DropdownMenuItem<String?>(
                                        value: type,
                                        child: Text(
                                          _typeTranslations[type] ?? type,
                                        ),
                                      );
                                    }),
                                  ],
                                  onChanged: (value) => _selectType2(value),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                : _filteredPokemons.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.noPokemonAvailable,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filteredPokemons.length,
                    itemBuilder: (context, index) {
                      return PokemonCard(
                        pokemon: _filteredPokemons[index],
                        onTap: () async {
                          try {
                            final details = await _dbService.getPokemonDetails(
                              _filteredPokemons[index].id,
                              widget.languageId,
                            );
                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PokemonDetailScreen(pokemon: details),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.errorLoadingDetails(e.toString()),
                                  ),
                                ),
                              );
                            }
                          }
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
