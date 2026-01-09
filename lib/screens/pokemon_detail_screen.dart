import 'package:dex_app/models/pokemon_detail.dart';
import 'package:flutter/material.dart';
import 'package:dex_app/l10n/app_localizations.dart';
import '../services/type_translator.dart';
import '../services/database_service.dart';
import '../theme/app_colors.dart';

class PokemonDetailScreen extends StatefulWidget {
  final PokemonDetail pokemon;
  const PokemonDetailScreen({super.key, required this.pokemon});

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  bool showShiny = false;
  int selectedEvolutionChainIndex = 0;

  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  List<Widget> _buildEvolutionChainForList(List<String> chain) {
    List<Widget> evolutionWidgets = [];

    for (int i = 0; i < chain.length; i++) {
      final name = chain[i];
      final imageUrl = widget.pokemon.evolutionImages[name] ?? '';
      // Debug: mostrar ruta de imagen de la evolución
      print('DEBUG: evolution image for $name -> $imageUrl');

      // Agregar el Pokémon
      evolutionWidgets.add(
        SizedBox(
          width: 90,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () async {
                final pokemonId = widget.pokemon.evolutionIds[name];
                if (pokemonId != null) {
                  // Mostrar indicador de carga
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    // Cargar los detalles del Pokémon
                    final databaseService = DatabaseService();
                    final newPokemon = await databaseService.getPokemonDetails(
                      pokemonId,
                      1,
                    );

                    if (mounted) {
                      Navigator.pop(context); // Cerrar el diálogo de carga
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PokemonDetailScreen(pokemon: newPokemon),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context); // Cerrar el diálogo de carga
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al cargar Pokémon: $e')),
                      );
                    }
                  }
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 70,
                    width: 70,
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
                      child: Center(
                        child: imageUrl.isNotEmpty
                            ? Image.asset(
                                imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/imagenes/placeholder.png',
                                    fit: BoxFit.contain,
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/imagenes/placeholder.png',
                                fit: BoxFit.contain,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name.toUpperCase(),
                    style: AppColors.typeText.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Si hay un siguiente Pokémon en la cadena, mostrar la condición de evolución
      if (i < chain.length - 1) {
        final nextName = chain[i + 1];
        final evolutionKey = '$name->$nextName';
        final evolutionDetail =
            widget.pokemon.evolutionDetails[evolutionKey] ?? '';
        evolutionWidgets.add(
          SizedBox(
            width: 140,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white70,
                    size: 20,
                  ),
                  if (evolutionDetail.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Container(
                      width: 130,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        evolutionDetail,
                        style: AppColors.typeText.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }
    }

    return evolutionWidgets;
  }

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
    // Debug: mostrar qué imagen principal se está usando (normal / shiny)
    final mainImagePath = showShiny ? widget.pokemon.shinyImageUrl : widget.pokemon.imageUrl;
    // Imprime en consola para depuración
    print('DEBUG: main image path="$mainImagePath" showShiny=$showShiny');

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
                            child: Center(
                              child:
                                  (showShiny
                                          ? widget.pokemon.shinyImageUrl
                                          : widget.pokemon.imageUrl)
                                      .isNotEmpty
                                  ? Transform.scale(
                                      scale:
                                          2, // <-- 1.0 = tamaño normal, 1.5 = 50% más grande
                                      child: Image.asset(
                                        showShiny
                                            ? widget.pokemon.shinyImageUrl
                                            : widget.pokemon.imageUrl,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Image.asset(
                                                'assets/imagenes/placeholder.png',
                                                fit: BoxFit.contain,
                                              );
                                            },
                                      ),
                                    )
                                  : Image.asset(
                                      'assets/imagenes/placeholder.png',
                                      fit: BoxFit.contain,
                                    ),
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

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Nombre de la especie
                      Text(
                        widget.pokemon.speciesName.toUpperCase(),
                        style: AppColors.title.copyWith(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
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
                          TypeTranslator.translate(type).toUpperCase(),
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
                            AppLocalizations.of(context)!.height,
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
                            AppLocalizations.of(context)!.weight,
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
                      AppLocalizations.of(context)!.description,
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
                      AppLocalizations.of(context)!.abilities,
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
                          AppLocalizations.of(context)!.descriptionNotAvailable;

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
                      AppLocalizations.of(context)!.stats,
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
                                StatTranslator.translate(e.key).toUpperCase(),
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
                  if (widget.pokemon.evolutionChain.isNotEmpty)
                    Card(
                      color: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.evolution,
                              style: AppColors.title.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Selector de cadenas evolutivas si hay más de una
                            if (widget.pokemon.evolutionChain.length > 1) ...[
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    widget.pokemon.evolutionChain.length,
                                    (index) {
                                      final isSelected =
                                          selectedEvolutionChainIndex == index;
                                      final chain =
                                          widget.pokemon.evolutionChain[index];
                                      final lastPokemon = chain.isNotEmpty
                                          ? chain.last
                                          : '';

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedEvolutionChainIndex =
                                                  index;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Colors.white.withOpacity(
                                                      0.2,
                                                    )
                                                  : Colors.white.withOpacity(
                                                      0.05,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isSelected
                                                    ? Colors.white.withOpacity(
                                                        0.5,
                                                      )
                                                    : Colors.white.withOpacity(
                                                        0.1,
                                                      ),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (widget
                                                    .pokemon
                                                    .evolutionImages
                                                    .containsKey(
                                                      lastPokemon,
                                                    )) ...[
                                                  SizedBox(
                                                    height: 24,
                                                    width: 24,
                                                    child: Image.asset(
                                                      widget
                                                          .pokemon
                                                          .evolutionImages[lastPokemon]!,
                                                      fit: BoxFit.contain,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return const Icon(
                                                              Icons
                                                                  .catching_pokemon,
                                                              size: 16,
                                                              color: Colors
                                                                  .white38,
                                                            );
                                                          },
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                ],
                                                Text(
                                                  lastPokemon,
                                                  style: AppColors.typeText
                                                      .copyWith(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight: isSelected
                                                            ? FontWeight.w600
                                                            : FontWeight.w400,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Mostrar solo la cadena seleccionada
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 0,
                                runSpacing: 8,
                                children: _buildEvolutionChainForList(
                                  widget
                                      .pokemon
                                      .evolutionChain[selectedEvolutionChainIndex],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),

                  // Formas alternativas (Varieties)
                  if (widget.pokemon.varieties.isNotEmpty)
                    Card(
                      color: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.varieties,
                              style: AppColors.title.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 12,
                              runSpacing: 12,
                              children: widget.pokemon.varieties.entries.map((
                                entry,
                              ) {
                                return GestureDetector(
                                  onTap: () async {
                                    // Obtener el ID de la variedad desde varietyIds
                                    final varietyId =
                                        widget.pokemon.varietyIds[entry.key];
                                    if (varietyId == null) return;

                                    final databaseService = DatabaseService();
                                    try {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );

                                      final newPokemon = await databaseService
                                          .getPokemonDetails(varietyId, 1);

                                      if (mounted) {
                                        Navigator.pop(context);
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PokemonDetailScreen(
                                                  pokemon: newPokemon,
                                                ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error al cargar forma: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: Container(
                                    width: 100,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          height: 70,
                                          width: 70,
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
                                            child: Center(
                                              child: (() {
                                                // Debug: mostrar ruta de imagen de la variedad (si está vacía, se mostrará placeholder)
                                                print('DEBUG: variety image for ${entry.key} -> ${entry.value}');
                                                return entry.value.isNotEmpty
                                                    ? Image.asset(
                                                        entry.value,
                                                        fit: BoxFit.contain,
                                                        errorBuilder:
                                                            (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return Image.asset(
                                                            'assets/imagenes/placeholder.png',
                                                            fit: BoxFit.contain,
                                                          );
                                                        },
                                                      )
                                                    : Image.asset(
                                                        'assets/imagenes/placeholder.png',
                                                        fit: BoxFit.contain,
                                                      );
                                              })(),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          entry.key.toUpperCase(),
                                          style: AppColors.typeText.copyWith(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
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
