import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/pokemon_detail.dart';

class PokemonDetailScreen extends StatefulWidget {
  final String name;

  const PokemonDetailScreen({Key? key, required this.name}) : super(key: key);

  @override
  _PokemonDetailScreenState createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  late Future<PokemonDetail> _pokemonDetail;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _pokemonDetail = apiService.fetchPokemonDetail(widget.name);
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PokemonDetail>(
      future: _pokemonDetail,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error al cargar detalles')),
          );
        } else {
          final pokemon = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text(capitalize(pokemon.name)),
              backgroundColor: _getColorFromType(pokemon.types.first),
              elevation: 0,
            ),
            backgroundColor: _getColorFromType(pokemon.types.first).withOpacity(0.3),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Image.network(
                    pokemon.imageUrl,
                    height: 200,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoCard(pokemon),
                  const SizedBox(height: 16),
                  _buildStatsCard(pokemon),
                  const SizedBox(height: 16),
                  _buildEvolutionChain(pokemon),
                  const SizedBox(height: 16),
                  _buildMovesCard(pokemon),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  /// Info básica del Pokémon
  Widget _buildInfoCard(PokemonDetail pokemon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              capitalize(pokemon.name),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("ID: ${pokemon.id}"),
                Text("Altura: ${pokemon.height / 10} m"),
                Text("Peso: ${pokemon.weight / 10} kg"),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: pokemon.types.map((type) {
                final color = _getColorFromType(type);
                final icon = _getTypeIcon(type);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Chip(
                    backgroundColor: color,
                    label: Row(
                      children: [
                        Icon(icon, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          capitalize(type),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Text("EXP Base: ${pokemon.baseExperience}"),
          ],
        ),
      ),
    );
  }

  /// Estadísticas del Pokémon con Sliders
  Widget _buildStatsCard(PokemonDetail pokemon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Estadísticas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            ...pokemon.stats.map((stat) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${capitalize(stat.name)}: ${stat.baseStat}'),
                    Slider(
                      value: stat.baseStat.toDouble().clamp(0.0, 200.0),
                      max: 200,
                      min: 0,
                      activeColor: _getColorFromType(pokemon.types.first),
                      onChanged: (_) {},
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  /// Mostrar la cadena evolutiva
  Widget _buildEvolutionChain(PokemonDetail pokemon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Línea Evolutiva',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: pokemon.evolutionChain.map((evo) {
                final evoId = evo['id'];
                final evoName = evo['name'];

                final imageUrl =
                    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$evoId.png';

                return Column(
                  children: [
                    Image.network(imageUrl, height: 80, width: 80),
                    const SizedBox(height: 5),
                    Text(capitalize(evoName!)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Movimientos del Pokémon
  Widget _buildMovesCard(PokemonDetail pokemon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Movimientos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: pokemon.moves.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(capitalize(pokemon.moves[index].name)),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Método auxiliar para colores según el tipo
  Color _getColorFromType(String type) {
    switch (type) {
      case 'fire':
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.yellow;
      case 'psychic':
        return Colors.purple;
      case 'rock':
        return Colors.brown;
      case 'ghost':
        return Colors.deepPurple;
      case 'dragon':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  /// Método auxiliar para iconos según el tipo
/// Método auxiliar para iconos según el tipo
IconData _getTypeIcon(String type) {
  switch (type) {
    case 'fire':
      return Icons.local_fire_department;
    case 'water':
      return Icons.water;
    case 'grass':
      return Icons.eco;
    case 'electric':
      return Icons.flash_on;
    case 'rock':
      return Icons.landscape;
    case 'psychic':
      return Icons.remove_red_eye;
    case 'ghost':
      return Icons.nightlight_round;
    case 'dragon':
      return Icons.ac_unit;
    case 'fairy':
      return Icons.star;
    case 'ground':
      return Icons.public;
    case 'ice':
      return Icons.ac_unit;
    case 'poison':
      return Icons.science;
    case 'fighting':
      return Icons.sports_kabaddi;
    case 'normal':
      return Icons.circle;
    case 'steel':
      return Icons.build;
    case 'flying':
      return Icons.airplanemode_active;
    case 'bug':
      return Icons.bug_report;
    case 'dark':
      return Icons.brightness_3;
    default:
      return Icons.help_outline;
  }
}

}
