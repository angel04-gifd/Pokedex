import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'pages/pokemon_detail_screen.dart';

void main() {
  runApp(PokedexApp());
}

class PokedexApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: PokemonListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PokemonListScreen extends StatefulWidget {
  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> _pokemonList;
  List<dynamic> _allPokemon = []; // Para almacenar todos los Pokémon

  @override
  void initState() {
    super.initState();
    _pokemonList = apiService.fetchPokemonList();
    _pokemonList.then((list) {
      setState(() {
        _allPokemon = list;
      });
    });
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        backgroundColor: Color.fromARGB(255, 96, 179, 214),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: PokemonSearch(_allPokemon),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _pokemonList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los Pokémon'));
          } else {
            final pokemons = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: pokemons.length,
              itemBuilder: (context, index) {
                final pokemon = pokemons[index];
                final id = index + 1;
                final imageUrl =
                    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PokemonDetailScreen(name: pokemon['name']),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '#${id.toString().padLeft(3, '0')} ${capitalize(pokemon['name'])}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

/// ----------------------------------------------
/// Clase PokemonSearch para el Buscador
/// ----------------------------------------------
class PokemonSearch extends SearchDelegate<String> {
  final List<dynamic> pokemonList;

  PokemonSearch(this.pokemonList);

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<dynamic> filteredPokemon = pokemonList.where((pokemon) {
      return pokemon['name'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return _buildPokemonList(filteredPokemon, context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<dynamic> suggestedPokemon = pokemonList.where((pokemon) {
      return pokemon['name'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return _buildPokemonList(suggestedPokemon, context);
  }

  Widget _buildPokemonList(List<dynamic> pokemons, BuildContext context) {
    if (pokemons.isEmpty) {
      return const Center(child: Text('No se encontraron Pokémon'));
    }

    return ListView.builder(
      itemCount: pokemons.length,
      itemBuilder: (context, index) {
        final pokemon = pokemons[index];
        final id = pokemonList.indexOf(pokemon) + 1;
        final imageUrl =
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

        return ListTile(
          leading: Image.network(imageUrl, width: 50, height: 50),
          title: Text(capitalize(pokemon['name'])),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PokemonDetailScreen(name: pokemon['name']),
              ),
            );
          },
        );
      },
    );
  }
}
