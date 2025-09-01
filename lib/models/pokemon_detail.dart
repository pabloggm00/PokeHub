import 'package:hive/hive.dart';

part 'pokemon_detail.g.dart';

@HiveType(typeId: 1)
class PokemonDetail {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String speciesName; // nombre en español de la especie
  @HiveField(2)
  final String formName; // nombre interno de la forma
  @HiveField(3)
  final String imageUrl;
  @HiveField(4)
  final String shinyImageUrl;
  @HiveField(5)
  final List<String> types;
  @HiveField(6)
  final double height;
  @HiveField(7)
  final double weight;
  @HiveField(8)
  final List<String> abilities;
  @HiveField(9)
  final Map<String, int> stats;
  @HiveField(10)
  final String description;
  @HiveField(11)
  final List<String> evolutionChain;
  @HiveField(12)
  final Map<String, String> evolutionImages;
  @HiveField(13)
  final Map<String, String> abilityDescriptions;
  @HiveField(14)
  final Map<String, String> varieties; // nuevas variedades con imágenes

  PokemonDetail({
    required this.id,
    required this.speciesName,
    required this.formName,
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
    required this.varieties,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    return PokemonDetail(
      id: json['id'],
      speciesName: json['speciesName'],
      formName: json['formName'],
      imageUrl: json['imageUrl'],
      shinyImageUrl: json['shinyImageUrl'],
      types: List<String>.from(json['types']),
      height: json['height'].toDouble(),
      weight: json['weight'].toDouble(),
      abilities: List<String>.from(json['abilities']),
      stats: Map<String, int>.from(json['stats']),
      description: json['description'],
      evolutionChain: List<String>.from(json['evolutionChain']),
      evolutionImages: Map<String, String>.from(json['evolutionImages'] ?? {}),
      abilityDescriptions: Map<String, String>.from(json['abilityDescriptions'] ?? {}),
      varieties: Map<String, String>.from(json['varieties'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'speciesName': speciesName,
      'formName': formName,
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
      'varieties': varieties,
    };
  }
}
