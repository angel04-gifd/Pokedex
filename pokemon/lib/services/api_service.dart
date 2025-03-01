import 'dart:convert';
import 'package:http/http.dart' as http;
import 'pokemon_detail.dart';

class ApiService {
  final String baseUrl = 'https://pokeapi.co/api/v2';

  /// Obtener lista de Pokémon (por defecto 251 para incluir hasta la segunda generación)
  Future<List<dynamic>> fetchPokemonList() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pokemon?limit=251'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['results']; // Devuelve la lista de Pokémon
      } else {
        throw Exception('Error al cargar la lista de Pokémon');
      }
    } catch (e) {
      print('Excepción al obtener la lista de Pokémon: $e');
      throw Exception('Error al obtener la lista de Pokémon');
    }
  }

  /// Obtener detalles de un Pokémon incluyendo su cadena evolutiva
  Future<PokemonDetail> fetchPokemonDetail(String name) async {
    try {
      // Obtener detalles del Pokémon
      final response = await http.get(Uri.parse('$baseUrl/pokemon/$name'));

      if (response.statusCode != 200) {
        throw Exception('Error al cargar los detalles del Pokémon');
      }

      final data = jsonDecode(response.body);

      // Obtener la URL para la especie del Pokémon
      final speciesResponse = await http.get(Uri.parse(data['species']['url']));
      if (speciesResponse.statusCode != 200) {
        throw Exception('Error al obtener la especie del Pokémon');
      }
      final speciesData = jsonDecode(speciesResponse.body);

      // Obtener la cadena evolutiva desde la especie
      final evolutionResponse = await http.get(Uri.parse(speciesData['evolution_chain']['url']));
      if (evolutionResponse.statusCode != 200) {
        throw Exception('Error al obtener la cadena evolutiva');
      }
      final evolutionData = jsonDecode(evolutionResponse.body);

      // Parsear la cadena evolutiva con IDs
      List<Map<String, String>> evolutionChain = [];
      var currentEvolution = evolutionData['chain'];

      do {
        // Extraer ID desde la URL de la especie
        final speciesUrl = currentEvolution['species']['url'];
        final regex = RegExp(r'pokemon-species\/(\d+)\/');
        final match = regex.firstMatch(speciesUrl);
        final id = match != null ? match.group(1) : '0';

        evolutionChain.add({
          'id': id!,
          'name': currentEvolution['species']['name'],
        });

        if (currentEvolution['evolves_to'].isNotEmpty) {
          currentEvolution = currentEvolution['evolves_to'][0];
        } else {
          currentEvolution = null;
        }
      } while (currentEvolution != null);

      // Crear y devolver el objeto PokemonDetail
      return PokemonDetail.fromJson(data, evolutionChain);
    } catch (e) {
      print('Excepción al obtener detalles del Pokémon: $e');
      throw Exception('Error al obtener detalles del Pokémon');
    }
  }
}
