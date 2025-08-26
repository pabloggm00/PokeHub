import 'package:flutter/material.dart';
import '../models/pokemon_summary.dart';
import '../theme/app_colors.dart';

class PokemonCard extends StatelessWidget {
  final PokemonSummary pokemon;
  final VoidCallback? onTap; // Callback para detalle

  const PokemonCard({super.key, required this.pokemon, this.onTap});

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
              child: Image.network(
                pokemon.imageUrl,
                height: 70,
                width: 70,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    height: 70,
                    width: 70,
                    child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error_outline, size: 70, color: Colors.red),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('#${pokemon.id.toString().padLeft(3, '0')}',
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
                        child: Text(type.toUpperCase(),
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
