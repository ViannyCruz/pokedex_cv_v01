import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../queries.dart';
import 'pokemon_details_screen.dart';

class PokemonListScreen extends StatefulWidget {
  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  String _filterType = '';
  int _filterGeneration = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokédex'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: _filterType,
                  hint: Text('Tipo'),
                  items: <String>[
                    '',
                    'normal',
                    'fire',
                    'water',
                    'grass',
                    'flying',
                    'fighting',
                    'poison',
                    'electric',
                    'ground',
                    'rock',
                    'psychic',
                    'ice',
                    'bug',
                    'ghost',
                    'steel',
                    'dragon',
                    'dark',
                    'fairy'
                  ]
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _filterType = newValue!;
                    });
                  },
                ),
                SizedBox(width: 10),
                DropdownButton<int>(
                  value: _filterGeneration,
                  hint: Text('Generación'),
                  items: <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                      .map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('Gen $value'),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _filterGeneration = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Query(
              options: QueryOptions(
                document: gql(getPokemonList),
              ),
              builder: (QueryResult result,
                  {VoidCallback? refetch, FetchMore? fetchMore}) {
                if (result.hasException) {
                  return Center(child: Text(result.exception.toString()));
                }

                if (result.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                List? pokemons = result.data?['pokemon_v2_pokemon'];

                pokemons = pokemons?.where((pokemon) {
                  bool typeMatch = _filterType.isEmpty ||
                      pokemon['pokemon_v2_pokemontypes'].any((type) =>
                      type['pokemon_v2_type']['name'] == _filterType);
                  bool generationMatch = _filterGeneration == 0 ||
                      pokemon['pokemon_v2_pokemonspecy']['generation_id'] ==
                          _filterGeneration;
                  return typeMatch && generationMatch;
                }).toList();

                return ListView.builder(
                  itemCount: pokemons?.length,
                  itemBuilder: (context, index) {
                    var pokemon = pokemons?[index];
                    return ListTile(
                      leading: Image.network(
                        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemon['id']}.png',
                      ),
                      title: Text(pokemon['name']),
                      subtitle: Text(
                          pokemon['pokemon_v2_pokemontypes'][0]['pokemon_v2_type']['name']),
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation,
                                secondaryAnimation) =>
                                PokemonDetailsScreen(id: pokemon['id']),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              var begin = const Offset(1.0, 0.0);
                              var end = Offset.zero;
                              var tween = Tween(begin: begin, end: end);
                              var offsetAnimation = animation.drive(tween);

                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}