import 'package:flutter/material.dart';

class AppColors {
  // Fondos
  static const background = Color(0xFF121212);
  static const cardBackground = Color(0xFF1E1E1E);

  // Texto
  static const primaryText = Colors.white;
  static const secondaryText = Color.fromARGB(255, 192, 192, 192);
  static const accentText = Colors.redAccent;

  // Selector de generaciones
  static const selectedGen = Colors.redAccent;
  static const unselectedGen = Color(0xFF2C2C2C);

  // Tipos Pokémon: colores base y gradientes
  static const Map<String, Color> typeColors = {
    'normal': Color(0xFF9E9E9E),
    'fire': Color(0xFFFF7043),
    'water': Color(0xFF42A5F5),
    'electric': Color(0xFFFFEB3B),
    'grass': Color(0xFF66BB6A),
    'ice': Color(0xFF4DD0E1),
    'fighting': Color(0xFFD32F2F),
    'poison': Color(0xFFAB47BC),
    'ground': Color(0xFFA1887F),
    'flying': Color(0xFF7986CB),
    'psychic': Color(0xFFE91E63),
    'bug': Color(0xFF8BC34A),
    'rock': Color(0xFFBCAAA4),
    'ghost': Color(0xFF5E35B1),
    'dragon': Color(0xFF3949AB),
    'dark': Color(0xFF424242),
    'steel': Color(0xFF90A4AE),
    'fairy': Color(0xFFF48FB1),
  };

  // Gradiente según tipos
  static LinearGradient typeGradient(List<String> types) {
    Color start = typeColors[types[0].toLowerCase()] ?? Colors.grey;
    Color end = start;
    if (types.length > 1) {
      end = typeColors[types[1].toLowerCase()] ?? start;
    }
    return LinearGradient(
      colors: [start.withOpacity(0.7), end.withOpacity(0.95)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Estilos de texto
  static const TextStyle title = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: primaryText,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: secondaryText,
  );

  static const TextStyle typeText = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
