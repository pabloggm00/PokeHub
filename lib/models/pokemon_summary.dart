import 'package:hive/hive.dart';

part 'pokemon_summary.g.dart';

@HiveType(typeId: 0)
class PokemonSummary {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String imageUrl;
  @HiveField(3)
  final List<String> types;

  PokemonSummary({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
  });

  factory PokemonSummary.fromJson(Map<String, dynamic> json) {
    return PokemonSummary(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      types: List<String>.from(json['types']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'types': types,
    };
  }
}
