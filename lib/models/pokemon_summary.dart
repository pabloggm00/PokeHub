class PokemonSummary {
  final int id;
  final int nationalDexNumber;
  final String name;
  final String imageUrl;
  final List<String> types;

  PokemonSummary({
    required this.id,
    required this.nationalDexNumber,
    required this.name,
    required this.imageUrl,
    required this.types,
  });

  factory PokemonSummary.fromJson(Map<String, dynamic> json) {
    return PokemonSummary(
      id: json['id'],
      nationalDexNumber: json['nationalDexNumber'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      types: List<String>.from(json['types']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nationalDexNumber': nationalDexNumber,
      'name': name,
      'imageUrl': imageUrl,
      'types': types,
    };
  }
}
