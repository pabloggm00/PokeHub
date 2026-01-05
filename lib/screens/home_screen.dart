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
          SnackBar(content: Text(AppLocalizations.of(context)!.errorLoadingData(e.toString()))),
        );
      }
    }
  }

  void _applyFilters() async {
    setState(() => _isLoading = true);

    try {
      List<PokemonSummary> filtered;

      if (_selectedRegion != null && _selectedType != null) {
        // Filtrar por región y tipo
        filtered = await _dbService.getPokemonByRegion(_selectedRegion!, widget.languageId);
        filtered = filtered.where((p) => p.types.contains(_selectedType)).toList();
      } else if (_selectedRegion != null) {
        // Solo por región
        filtered = await _dbService.getPokemonByRegion(_selectedRegion!, widget.languageId);
      } else if (_selectedType != null) {
        // Solo por tipo
        filtered = await _dbService.getPokemonByType(_selectedType!, widget.languageId);
      } else {
        // Sin filtros
        filtered = _allPokemons;
      }
      
      // Filtrar por generación si está seleccionada
      if (_selectedGen != null) {
        filtered = filtered.where((p) {
          // Filtrar por national_dex_number según la generación
          final dex = p.nationalDexNumber;
          switch (_selectedGen!) {
            case 1: return dex >= 1 && dex <= 151;
            case 2: return dex >= 152 && dex <= 251;
            case 3: return dex >= 252 && dex <= 386;
            case 4: return dex >= 387 && dex <= 493;
            case 5: return dex >= 494 && dex <= 649;
            case 6: return dex >= 650 && dex <= 721;
            case 7: return dex >= 722 && dex <= 809;
            case 8: return dex >= 810 && dex <= 905;
            case 9: return dex >= 906 && dex <= 1025;
            default: return true;
          }
        }).toList();
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

  void _navigateToSearchScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchScreen(dbService: _dbService)),
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
        title: Text(AppLocalizations.of(context)!.appTitle, style: AppColors.title),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _toggleLanguage,
            tooltip: widget.languageId == 1 ? AppLocalizations.of(context)!.spanish : AppLocalizations.of(context)!.english,
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
                                  child: Text(AppLocalizations.of(context)!.all),
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
                                  child: Text(AppLocalizations.of(context)!.all),
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
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Filtro de Tipo
                Row(
                  children: [
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
                                  child: Text(AppLocalizations.of(context)!.allTypes),
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
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
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
                                      content: Text(AppLocalizations.of(context)!.errorLoadingDetails(e.toString())),
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
