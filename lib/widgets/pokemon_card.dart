import 'package:flutter/material.dart';
import '../models/pokemon_summary.dart';
import '../services/type_translator.dart';
import '../theme/app_colors.dart';

class PokemonCard extends StatelessWidget {
  final PokemonSummary pokemon;
  final VoidCallback? onTap; // Callback para detalle

  const PokemonCard({super.key, required this.pokemon, this.onTap});

  Widget _buildPlaceholder() {
    return Image.asset(
      "assets/imagenes/placeholder.png",
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.black12,
          child: const Icon(Icons.image_not_supported, color: Colors.white30),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradient = AppColors.typeGradient(pokemon.types);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Container(
                height: 70,
                width: 70,
                color: Colors.black12,
                child: Builder(
                  builder: (context) {
                    // Mostrar en consola la ruta de la imagen
                    // ignore: avoid_print
                    //print('PokemonCard imageUrl: \\${pokemon.imageUrl}');
                    return pokemon.imageUrl.isNotEmpty
                        ? Image.asset(
                            pokemon.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder();
                            },
                          )
                        : _buildPlaceholder();
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('#${pokemon.nationalDexNumber.toString().padLeft(3, '0')}',
                      style: AppColors.subtitle.copyWith(fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(pokemon.name.toUpperCase(),
                      style: AppColors.title.copyWith(fontSize: 14)),
                  const SizedBox(height: 6),
                  Row(
                    children: pokemon.types.map((type) {
                      return Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              AppColors.typeColors[type.toLowerCase()] ?? Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(TypeTranslator.translate(type).toUpperCase(),
                            style: AppColors.typeText.copyWith(fontSize: 9)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
