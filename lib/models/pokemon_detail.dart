class PokemonDetail {
  final int id;
  final String speciesName;
  final String formName;
  final String imageUrl;
  final String shinyImageUrl;
  final List<String> types;
  final double height;
  final double weight;
  final List<String> abilities;
  final Map<String, int> stats;
  final String description;
  final List<List<String>> evolutionChain;
  final Map<String, String> evolutionImages;
  final Map<String, int> evolutionIds;
  final Map<String, String> abilityDescriptions;
  final Map<String, String> varieties;
  final Map<String, int> varietyIds;
  final Map<String, String> evolutionDetails;

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
    required this.evolutionIds,
    required this.abilityDescriptions,
    required this.varieties,
    required this.varietyIds,
    required this.evolutionDetails,
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
      evolutionChain: (json['evolutionChain'] as List).map((chain) => 
        List<String>.from(chain as List)).toList(),
      evolutionImages: Map<String, String>.from(json['evolutionImages'] ?? {}),
      evolutionIds: Map<String, int>.from(json['evolutionIds'] ?? {}),
      abilityDescriptions: Map<String, String>.from(json['abilityDescriptions'] ?? {}),
      varieties: Map<String, String>.from(json['varieties'] ?? {}),
      varietyIds: Map<String, int>.from(json['varietyIds'] ?? {}),
      evolutionDetails: Map<String, String>.from(json['evolutionDetails'] ?? {}),
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
      'evolutionIds': evolutionIds,
      'abilityDescriptions': abilityDescriptions,
      'varieties': varieties,
      'varietyIds': varietyIds,
      'evolutionDetails': evolutionDetails,
    };
  }
}
