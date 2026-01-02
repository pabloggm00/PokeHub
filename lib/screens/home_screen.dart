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
  List<PokemonSummary> _pokemons = [];
  int _selectedGen = 1;
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

  @override
  void initState() {
    super.initState();
    _loadGeneration(_selectedGen);
  }

  Future<void> _loadGeneration(int gen) async {
    setState(() {
      _isLoading = true;
      _selectedGen = gen;
      _pokemons = [];
    });

    try {
      final newPokemons = gen == 10
          ? await _api.fetchVariantPokemon()
          : await _api.fetchPokemonFromGeneration(gen);

      setState(() {
        _pokemons = newPokemons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
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
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              itemCount: _genNames.length,
              itemBuilder: (context, index) {
                final gen = index + 1;
                final isSelected = gen == _selectedGen;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: GestureDetector(
                    onTap: () => _loadGeneration(gen),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.selectedGen
                            : AppColors.unselectedGen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          _genNames[gen]!,
                          style: AppColors.title.copyWith(
                            color: AppColors.primaryText,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
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
                    itemCount: _pokemons.length,
                    itemBuilder: (context, index) {
                      return PokemonCard(
                        pokemon: _pokemons[index],
                        onTap: () async {
                          final details = await _api.fetchPokemonDetails(
                            _pokemons[index].id,
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
