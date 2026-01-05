import 'package:dex_app/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:dex_app/l10n/app_localizations.dart';
import '../models/pokemon_summary.dart';
import '../widgets/pokemon_card.dart';
import '../theme/app_colors.dart';
import 'pokemon_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final DatabaseService dbService;

  const SearchScreen({super.key, required this.dbService});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<PokemonSummary> _allPokemon = [];
  List<PokemonSummary> _filteredPokemon = [];
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadAllPokemon();
    _setupSearchListener();
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      _filterPokemon(_searchController.text);
    });
  }

  Future<void> _loadAllPokemon() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final allPokemon = await widget.dbService.getAllPokemon();

      setState(() {
        _allPokemon = allPokemon;
        _filteredPokemon = allPokemon;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _filterPokemon(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredPokemon = _allPokemon;
      });
      return;
    }

    final searchQuery = query.toLowerCase();
    final filtered = _allPokemon.where((pokemon) {
      return pokemon.name.toLowerCase().contains(searchQuery) ||
          pokemon.id.toString().contains(searchQuery);
    }).toList();

    setState(() {
      _filteredPokemon = filtered;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredPokemon = _allPokemon;
    });
  }

  void _retryLoading() {
    _loadAllPokemon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: Text(AppLocalizations.of(context)!.searchPokemon, style: AppColors.title),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onTapOutside: (event) {
                FocusScope.of(context).unfocus();
              },
              style: const TextStyle(color: AppColors.primaryText),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchByNameOrId,
                hintStyle: const TextStyle(color: AppColors.secondaryText),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: AppColors.secondaryText),
                ),
                filled: true,
                fillColor: AppColors.cardBackground,
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.secondaryText,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.secondaryText,
                        ),
                        onPressed: _clearSearch,
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),

          // Contador de resultados
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.pokemonCount(_filteredPokemon.length),
                  style: AppColors.subtitle.copyWith(fontSize: 14),
                ),
                if (_searchController.text.isNotEmpty)
                  Text(
                    AppLocalizations.of(context)!.searching(_searchController.text),
                    style: AppColors.subtitle.copyWith(fontSize: 12),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Resultados
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.selectedGen),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.loadingAllPokemon, style: AppColors.title),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.accentText,
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.errorLoadingPokemon, style: AppColors.title),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _retryLoading,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.selectedGen,
              ),
              child: Text(
                AppLocalizations.of(context)!.retry,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredPokemon.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.secondaryText,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? AppLocalizations.of(context)!.noPokemonToShow
                  : AppLocalizations.of(context)!.noPokemonFound(_searchController.text),
              style: AppColors.title,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: _filteredPokemon.length,
      itemBuilder: (context, index) {
        final pokemon = _filteredPokemon[index];
        return PokemonCard(
          pokemon: pokemon,
          onTap: () async {
            try {
              final details = await widget.dbService.getPokemonDetails(
                pokemon.id,
              );
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PokemonDetailScreen(pokemon: details),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.errorLoadingDetails(e.toString()))),
                );
              }
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
