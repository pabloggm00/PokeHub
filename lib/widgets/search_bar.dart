import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PokemonSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function(Map<String, dynamic>) onAdvancedSearch;
  final List<String> availableTypes;

  const PokemonSearchBar({
    super.key,
    required this.onSearch,
    required this.onAdvancedSearch,
    required this.availableTypes,
  });

  @override
  State<PokemonSearchBar> createState() => _PokemonSearchBarState();
}

class _PokemonSearchBarState extends State<PokemonSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minIdController = TextEditingController();
  final TextEditingController _maxIdController = TextEditingController();

  Set<String> _selectedTypes = {};
  int? _selectedGeneration;
  bool _showAdvancedFilters = false;

  void _performSearch() {
    if (_searchController.text.isEmpty && !_showAdvancedFilters) {
      return;
    }

    if (!_showAdvancedFilters) {
      widget.onSearch(_searchController.text);
    } else {
      widget.onAdvancedSearch({
        'nameQuery': _searchController.text.isNotEmpty
            ? _searchController.text
            : null,
        'types': _selectedTypes.isNotEmpty ? _selectedTypes.toList() : null,
        'generation': _selectedGeneration,
        'minId': _minIdController.text.isNotEmpty
            ? int.tryParse(_minIdController.text)
            : null,
        'maxId': _maxIdController.text.isNotEmpty
            ? int.tryParse(_maxIdController.text)
            : null,
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _minIdController.clear();
      _maxIdController.clear();
      _selectedTypes.clear();
      _selectedGeneration = null;
    });
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de búsqueda principal
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar Pokémon...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearFilters,
                    ),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: AppColors.typeColors['fire'] ?? Colors.red,
                ),
                onPressed: _performSearch,
              ),
              IconButton(
                icon: Icon(
                  _showAdvancedFilters
                      ? Icons.filter_list_off
                      : Icons.filter_list,
                  color: AppColors.typeColors['water'] ?? Colors.blue,
                ),
                onPressed: () {
                  setState(() {
                    _showAdvancedFilters = !_showAdvancedFilters;
                  });
                },
              ),
            ],
          ),
        ),

        // Filtros avanzados
        if (_showAdvancedFilters) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtros Avanzados',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Selector de generación
                  DropdownButtonFormField<int>(
                    value: _selectedGeneration,
                    decoration: const InputDecoration(
                      labelText: 'Generación',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todas')),
                      ...List.generate(9, (i) => i + 1).map((gen) {
                        return DropdownMenuItem(
                          value: gen,
                          child: Text('Generación $gen'),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGeneration = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Selector de tipos
                  const Text('Tipos:'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: widget.availableTypes.map((type) {
                      final isSelected = _selectedTypes.contains(type);
                      return FilterChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTypes.add(type);
                            } else {
                              _selectedTypes.remove(type);
                            }
                          });
                        },
                        backgroundColor: isSelected
                            ? AppColors.typeColors[type]?.withOpacity(0.3)
                            : null,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Rango de IDs
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minIdController,
                          decoration: const InputDecoration(
                            labelText: 'ID Mínimo',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _maxIdController,
                          decoration: const InputDecoration(
                            labelText: 'ID Máximo',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _performSearch,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.typeColors['electric'],
                          ),
                          child: const Text(
                            'Aplicar Filtros',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _clearFilters,
                          child: const Text('Limpiar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
