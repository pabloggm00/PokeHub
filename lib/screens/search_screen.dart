import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/pokemon_summary.dart';
import '../widgets/pokemon_card.dart';
import '../theme/app_colors.dart';
import 'pokemon_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final PokeApiService apiService;

  const SearchScreen({super.key, required this.apiService});

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
      final allPokemon = await widget.apiService.getAllPokemon();

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
        title: const Text('Buscar Pokémon', style: AppColors.title),
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
                hintText: 'Buscar por nombre o ID...',
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
                  '${_filteredPokemon.length} Pokémon',
                  style: AppColors.subtitle.copyWith(fontSize: 14),
                ),
                if (_searchController.text.isNotEmpty)
                  Text(
                    'Buscando: "${_searchController.text}"',
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.selectedGen),
            SizedBox(height: 16),
            Text('Cargando todos los Pokémon...', style: AppColors.title),
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
            const Text('Error al cargar Pokémon', style: AppColors.title),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _retryLoading,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.selectedGen,
              ),
              child: const Text(
                'Reintentar',
                style: TextStyle(color: Colors.white),
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
                  ? 'No hay Pokémon para mostrar'
                  : 'No se encontraron Pokémon\ncon "${_searchController.text}"',
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
            final details = await widget.apiService.fetchPokemonDetails(
              pokemon.id,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PokemonDetailScreen(pokemon: details),
              ),
            );
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
