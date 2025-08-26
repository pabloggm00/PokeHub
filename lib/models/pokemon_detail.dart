import 'package:hive/hive.dart';

part 'pokemon_detail.g.dart';

@HiveType(typeId: 1)
class PokemonDetail {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String imageUrl;
  @HiveField(3)
  final String shinyImageUrl;
  @HiveField(4)
  final List<String> types;
  @HiveField(5)
  final double height;
  @HiveField(6)
  final double weight;
  @HiveField(7)
  final List<String> abilities;
  @HiveField(8)
  final Map<String, int> stats;
  @HiveField(9)
  final String description;
  @HiveField(10)
  final List<String> evolutionChain;
  @HiveField(11)
  final Map<String, String> evolutionImages;
  @HiveField(12)
  final Map<String, String> abilityDescriptions;

  PokemonDetail({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.shinyImageUrl,
    required this.types,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.stats,
    required this.description,
    required this.evolutionChain,
    required this.evolutionImages,
    required this.abilityDescriptions,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    return PokemonDetail(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      shinyImageUrl: json['shinyImageUrl'],
      types: List<String>.from(json['types']),
      height: json['height'],
      weight: json['weight'],
      abilities: List<String>.from(json['abilities']),
      stats: Map<String, int>.from(json['stats']),
      description: json['description'],
      evolutionChain: List<String>.from(json['evolutionChain']),
      evolutionImages: Map<String, String>.from(json['evolutionImages'] ?? {}),
      abilityDescriptions: Map<String, String>.from(json['abilityDescriptions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'shinyImageUrl': shinyImageUrl,
      'types': types,
      'height': height,
      'weight': weight,
      'abilities': abilities,
      'stats': stats,
      'description': description,
      'evolutionChain': evolutionChain,
      'evolutionImages': evolutionImages,
      'abilityDescriptions': abilityDescriptions,
    };
  }
}
