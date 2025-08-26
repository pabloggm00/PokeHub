const String pokeApiBase = 'https://pokeapi.co/api/v2';
const String spritesBase = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork';

String officialArtworkUrl(int id) => '$spritesBase/$id.png';
