import 'package:dex_app/models/pokemon_detail.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PokemonDetailScreen extends StatefulWidget {
  final PokemonDetail pokemon;
  const PokemonDetailScreen({super.key, required this.pokemon});

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  bool showShiny = false;

  void _showAbilityDescription(String abilityName, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24, width: 2),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título y botón cerrar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        abilityName.toUpperCase(),
                        style: AppColors.title.copyWith(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 24,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Descripción
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    description,
                    style: AppColors.subtitle.copyWith(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),

                const SizedBox(height: 20),

                // Botón de cerrar
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradient = AppColors.typeGradient(widget.pokemon.types);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(gradient: gradient)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Botón atrás
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Imagen flotante con botón shiny
                  Stack(
                    children: [
                      Hero(
                        tag: 'pokemon_${widget.pokemon.id}',
                        child: Container(
                          height: 220,
                          width: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Image.network(
                              showShiny
                                  ? widget.pokemon.shinyImageUrl
                                  : widget.pokemon.imageUrl,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => showShiny = !showShiny),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.star,
                              size: 20,
                              color: showShiny ? Colors.yellow : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Nombre
                  Text(
                    widget.pokemon.name.toUpperCase(),
                    style: AppColors.title.copyWith(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tipos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.pokemon.types.map((type) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              AppColors.typeColors[type.toLowerCase()] ??
                              Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          type.toUpperCase(),
                          style: AppColors.typeText.copyWith(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Altura / Peso
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Altura',
                            style: AppColors.subtitle.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '${widget.pokemon.height} m',
                            style: AppColors.subtitle.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Peso',
                            style: AppColors.subtitle.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '${widget.pokemon.weight} kg',
                            style: AppColors.subtitle.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Descripción
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Descripción',
                      style: AppColors.title.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.pokemon.description,
                    style: AppColors.subtitle.copyWith(color: Colors.white70),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 24),
                  // Habilidades (BOTONES INTERACTIVOS)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Habilidades',
                      style: AppColors.title.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: widget.pokemon.abilities.map((ability) {
                      final description =
                          widget.pokemon.abilityDescriptions[ability] ??
                          'Descripción no disponible';

                      return GestureDetector(
                        onTap: () =>
                            _showAbilityDescription(ability, description),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 40, 40, 40),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                ability,
                                style: AppColors.typeText.copyWith(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.info_outline,
                                size: 14,
                                color: Colors.white70,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Stats
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Stats',
                      style: AppColors.title.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Column(
                    children: widget.pokemon.stats.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: Text(
                                e.key.toUpperCase(),
                                style: AppColors.subtitle.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: e.value / 255),
                                duration: const Duration(milliseconds: 800),
                                builder: (context, value, _) {
                                  return LinearProgressIndicator(
                                    value: value,
                                    color: Colors.white,
                                    backgroundColor: Colors.white12,
                                    minHeight: 8,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 35,
                              child: Text(
                                e.value.toString(),
                                textAlign: TextAlign.right,
                                style: AppColors.subtitle.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),

                  // Línea evolutiva como Card con imágenes
                  const SizedBox(height: 24),
                  if (widget.pokemon.evolutionChain.length > 1)
                    Card(
                      color: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Evolución',
                              style: AppColors.title.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: widget.pokemon.evolutionChain.map((
                                  name,
                                ) {
                                  final imageUrl =
                                      widget.pokemon.evolutionImages[name] ??
                                      '';
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 80,
                                          width: 80,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.white.withOpacity(0.2),
                                                Colors.white.withOpacity(0.05),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: imageUrl.isNotEmpty
                                                ? Image.network(
                                                    imageUrl,
                                                    fit: BoxFit.contain,
                                                  )
                                                : const SizedBox.shrink(),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          name.toUpperCase(),
                                          style: AppColors.typeText.copyWith(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
