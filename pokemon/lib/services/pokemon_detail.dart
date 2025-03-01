class PokemonDetail {
  final int id;
  final String name;
  final int height;
  final int weight;
  final int baseExperience;
  final List<String> types;
  final List<Stat> stats;
  final List<Move> moves;
  final String imageUrl;
  final List<Map<String, String>> evolutionChain; // Con ID y nombre

  PokemonDetail({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.baseExperience,
    required this.types,
    required this.stats,
    required this.moves,
    required this.imageUrl,
    required this.evolutionChain, // Ahora es un mapa con ID y nombre
  });

  // Método para crear el objeto desde JSON
  factory PokemonDetail.fromJson(Map<String, dynamic> json, List<Map<String, String>> evolutionChain) {
    return PokemonDetail(
      id: json['id'],
      name: json['name'],
      height: json['height'],
      weight: json['weight'],
      baseExperience: json['base_experience'] ?? 0,
      types: (json['types'] as List)
          .map((type) => type['type']['name'] as String)
          .toList(),
      stats: (json['stats'] as List)
          .map((stat) => Stat.fromJson(stat))
          .toList(),
      moves: (json['moves'] as List)
          .map((move) => Move.fromJson(move))
          .toList(),
      imageUrl: json['sprites']['other']['official-artwork']['front_default'],
      evolutionChain: evolutionChain,
    );
  }
}

// Modelo para las estadísticas del Pokémon
class Stat {
  final String name;
  final int baseStat;

  Stat({required this.name, required this.baseStat});

  factory Stat.fromJson(Map<String, dynamic> json) {
    return Stat(
      name: json['stat']['name'],
      baseStat: json['base_stat'],
    );
  }
}

// Modelo para los movimientos del Pokémon
class Move {
  final String name;

  Move({required this.name});

  factory Move.fromJson(Map<String, dynamic> json) {
    return Move(
      name: json['move']['name'],
    );
  }
}
