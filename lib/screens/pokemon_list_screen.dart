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
  String _searchQuery = ''; // Consulta de búsqueda
  List<dynamic>? _originalPokemons; // Lista original de Pokémon
  List<dynamic>? _filteredPokemons; // Lista filtrada de Pokémon
  Key _listViewKey = UniqueKey(); // Clave única para el ListView
  ScrollController _scrollController = ScrollController(); // Controlador de scroll
  TextEditingController _searchController = TextEditingController(); // Controlador de texto para búsqueda

  List<dynamic> filterByType(List<dynamic> pokemons, String type) {
    if (type.isEmpty) {
      return pokemons;
    }
    return pokemons.where((pokemon) {
      return pokemon['pokemon_v2_pokemontypes'].any((typeInfo) => typeInfo['pokemon_v2_type']['name'] == type);
    }).toList();
  }

  List<dynamic> filterBySearchQuery(List<dynamic> pokemons, String query) {
    if (query.isEmpty) {
      return pokemons;
    }
    return pokemons.where((pokemon) {
      return pokemon['name'].toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<dynamic> filterByGeneration(List<dynamic> pokemons, int generation) {
    if (generation == 0) {
      return pokemons;
    }
    return pokemons.where((pokemon) {
      return pokemon['pokemon_v2_pokemonspecy']['generation_id'] == generation;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('POKEDEX', style: TextStyle(
            color: Colors.red, fontWeight: FontWeight.bold, fontSize: 25),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController, // Controlador de texto para búsqueda
              cursorColor: Colors.red, // Cambia el color del cursor a rojo
              decoration: InputDecoration(
                hintText: 'Buscar un pokemon...',
                prefixIcon: const Icon(Icons.search, color: Colors.red),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value; // Actualiza la consulta de búsqueda
                  if (_originalPokemons != null) {
                    _filteredPokemons = filterByType(_originalPokemons!, _filterType);
                    _filteredPokemons = filterBySearchQuery(_filteredPokemons!, _searchQuery);
                    _filteredPokemons = filterByGeneration(_filteredPokemons!, _filterGeneration);
                  }
                  _scrollController.jumpTo(0); // Volver al inicio de la lista
                });
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Flexible(
                  child: Container(
                    height: 40,// Ajusta el ancho del dropdown
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButton<String>(
                      value: _filterType,
                      hint: Text('Tipo', style: TextStyle(color: Colors.grey)),
                      underline: Container(), // Elimina la línea debajo del dropdown
                      isExpanded: true, // Permite que el dropdown se expanda
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
                          child: Container(
                            width: 140,
                            height: 32,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: value.isEmpty
                                    ? const AssetImage('assets/types_large/all.png') // Imagen para valor nulo
                                    : AssetImage('assets/types_large/$value.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _filterType = newValue!;
                          if (_originalPokemons != null) {
                            _filteredPokemons = filterByType(_originalPokemons!, _filterType);
                            _filteredPokemons = filterBySearchQuery(_filteredPokemons!, _searchQuery);
                            _filteredPokemons = filterByGeneration(_filteredPokemons!, _filterGeneration);
                          }
                          _scrollController.jumpTo(0); // Volver al inicio de la lista
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Container(
                    height: 40,// Ajusta el ancho del dropdown
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButton<int>(
                      value: _filterGeneration,
                      hint: const Text('Generación', style: TextStyle(color: Colors.grey)),
                      underline: Container(), // Elimina la línea debajo del dropdown
                      isExpanded: true, // Permite que el dropdown se expanda
                      items: <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Container(
                            width: 140,
                            height: 32,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: value == 0
                                    ? const AssetImage('assets/types_large/all.png') // Imagen para valor nulo
                                    : AssetImage('assets/generations/gen$value.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          _filterGeneration = newValue!;
                          if (_filteredPokemons != null) {
                            _filteredPokemons = _filteredPokemons!.where((pokemon) {
                              bool generationMatch = _filterGeneration == 0 ||
                                  pokemon['pokemon_v2_pokemonspecy']['generation_id'] ==
                                      _filterGeneration;
                              return generationMatch;
                            }).toList();
                          }
                          _scrollController.jumpTo(0); // Volver al inicio de la lista
                        });
                      },
                    ),
                  ),
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
                  return const Center(child: CircularProgressIndicator());
                }

                _originalPokemons = result.data?['pokemon_v2_pokemon'];

                // Filtrar por tipo
                _filteredPokemons = filterByType(_originalPokemons!, _filterType);

                // Filtrar por búsqueda
                _filteredPokemons = filterBySearchQuery(_filteredPokemons!, _searchQuery);

                // Filtrar por generación
                _filteredPokemons = filterByGeneration(_filteredPokemons!, _filterGeneration);

                return ListView.builder(
                  key: _listViewKey, // Usa la clave única para forzar la reconstrucción
                  controller: _scrollController, // Usa el controlador de scroll
                  itemCount: _filteredPokemons?.length ?? 0,
                  itemBuilder: (context, index) {
                    if (_filteredPokemons == null || _filteredPokemons!.isEmpty) {
                      return Center(child: Text('No Pokémon found'));
                    }
                    var pokemon = _filteredPokemons![index];
                    String pokemonName = pokemon['name'].toUpperCase();
                    if (pokemonName.length > 12) {
                      pokemonName = '${pokemonName.substring(0, 12)}...';
                    }
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PokemonDetailsScreen(id: pokemon['id']),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/background_list/' + pokemon['pokemon_v2_pokemontypes'][0]['pokemon_v2_type']['name'] + '.png'),
                            fit: BoxFit.cover, // Asegura que la imagen ocupe todo el contenedor
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 8,
                              right: 14,
                              child: Text(
                                '# ${pokemon['id'].toString().padLeft(4, '0')}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 14,
                              child: GestureDetector(
                                onTap: () { // Al pulsar la pokeball
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('ID: ${pokemon['id']}'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: const CircleAvatar(
                                  radius: 15,
                                  backgroundImage: AssetImage("assets/general/white_pokeball.png"),
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundImage: NetworkImage(
                                          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemon['id']}.png',
                                        ),
                                        backgroundColor: Colors.white,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            FittedBox(
                                              fit: BoxFit.scaleDown, // Ajusta el texto para que no se desborde
                                              child: Text(
                                                pokemonName,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20, // Tamaño máximo del texto
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 15,
                                                  backgroundImage: AssetImage('${'assets/types_icons/' + pokemon['pokemon_v2_pokemontypes'][0]['pokemon_v2_type']['name']}.png'),
                                                  backgroundColor: Colors.white,
                                                ),
                                                const SizedBox(width: 8),
                                                CircleAvatar(
                                                  radius: 15,
                                                  backgroundImage: pokemon['pokemon_v2_pokemontypes'].length == 2
                                                      ? AssetImage('${'assets/types_icons/' + pokemon['pokemon_v2_pokemontypes'][1]['pokemon_v2_type']['name']}.png')
                                                      : null,
                                                  backgroundColor: pokemon['pokemon_v2_pokemontypes'].length == 2
                                                      ? Colors.white
                                                      : Colors.transparent,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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