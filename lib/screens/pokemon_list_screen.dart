import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../queries.dart';
import 'WhosThatPokemonScreen.dart';
import 'pokemon_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../PokeballImage.dart';

class PokemonListScreen extends StatefulWidget {
  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

enum FavoriteFilter { all, favorites }
enum SortType { indice, name }

class _PokemonListScreenState extends State<PokemonListScreen> {
  String _filterType = '';
  int _filterGeneration = 0;
  String _searchQuery = '';
  List<dynamic>? _originalPokemons;
  List<dynamic>? _filteredPokemons;
  ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  int _limit = 20;
  int _offset = 0;
  List<dynamic> _Pokemons = [];
  bool _isLoadingMore = false;
  int _totalPokemons = 0;
  FetchMore? fetchMore;
  Future<void>? _fetchPokemonsFuture;
  List<int> _favoritePokemons = [];
  FavoriteFilter _favoriteFilter = FavoriteFilter.all;
  SortType _sortType = SortType.indice;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadFavorites(); // Cargar los favoritos al iniciar la aplicación
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoadingMore && _Pokemons.length < _totalPokemons) {
      _loadMorePokemons();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure _fetchPokemonsFuture is not initialized multiple times
    if (_fetchPokemonsFuture == null) {
      _fetchPokemonsFuture = _fetchPokemons();
    }
  }

  Future<void> _fetchPokemons() async {
    GraphQLClient client = GraphQLProvider.of(context).value;
    final result = await client.query(
      QueryOptions(
        document: gql(getPokemonList),
        variables: {'limit': _limit, 'offset': _offset},
      ),
    );

    try {
      // Imprimir la respuesta antes de decodificarla
      print('Response: ${result.data}');

      if (result.hasException) {
        setState(() {
          _isLoadingMore = false;
        });
        return;
      }

      setState(() {
        if (_offset == 0) {
          _originalPokemons = result.data?['pokemon_v2_pokemon'] ?? [];
          _totalPokemons = result.data?['pokemon_v2_pokemon_aggregate']['aggregate']['count'] ?? 0;
          _Pokemons = filterPokemons(_originalPokemons!);
        } else {
          _originalPokemons!.addAll(result.data?['pokemon_v2_pokemon'] ?? []);
          _Pokemons = filterPokemons(_originalPokemons!);
        }
        _isLoadingMore = false;
      });
    } on FormatException catch (e) {
      print('FormatException: $e');
      // Manejar la excepción de manera adecuada
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMorePokemons() async {
    if (_isLoadingMore || _Pokemons.length >= _totalPokemons) {
      return;
    }
    setState(() {
      _isLoadingMore = true;
      _offset += _limit;
    });
    await _fetchPokemons();
  }

  List<dynamic> filterPokemons(List<dynamic> pokemons) {
    List<dynamic> filtered = filterByType(pokemons, _filterType);
    filtered = filterBySearchQuery(filtered, _searchQuery);
    filtered = filterByGeneration(filtered, _filterGeneration);

    if (_favoriteFilter == FavoriteFilter.favorites) {
      filtered = filtered.where((pokemon) => _favoritePokemons.contains(pokemon['id'])).toList();
    }

    if(_sortType == SortType.indice){
      filtered.sort((a, b) => a['id'].compareTo(b['id']));
    } else if(_sortType == SortType.name){
      filtered.sort((a, b) => a['name'].compareTo(b['name']));
    }

    return filtered;
  }

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
      bool byName = pokemon['name'].toLowerCase().contains(query.toLowerCase());
      bool byNumber = pokemon['id'].toString().contains(query);
      return byName || byNumber;
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

  Future<void> _applyFilters() async {
    setState(() {
      _offset = 0;
      _limit = 50;
      _originalPokemons = [];
      _Pokemons = [];
    });
    _fetchPokemonsFuture = _fetchPokemons();

    // Cargar más Pokémon hasta que se alcance el total o se carguen 50
    while (_Pokemons.length < 50 && _Pokemons.length < _totalPokemons) {
      await _loadMorePokemons();
    }

    // Asegurarse de que el último Pokémon se cargue
    if (_Pokemons.length < _totalPokemons) {
      await _loadMorePokemons();
    }

    // Ir al comienzo de la lista después de aplicar los filtros
    _scrollController.jumpTo(0);
  }

  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoritePokemons = prefs.getStringList('favoritePokemons')?.map((id) => int.parse(id)).toList() ?? [];
    });
  }

  Future<void> _saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoritePokemons', _favoritePokemons.map((id) => id.toString()).toList());
  }

  void _toggleFavorite(int pokemonId) {
    setState(() {
      if (_favoritePokemons.contains(pokemonId)) {
        _favoritePokemons.remove(pokemonId);
      } else {
        _favoritePokemons.add(pokemonId);
      }
    });
    _saveFavorites();
  }

  String getPokeballImage(int pokemonId) {
    return _favoritePokemons.contains(pokemonId)
        ? "assets/general/red_pokeball.png"
        : "assets/general/white_pokeball.png";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('POKEDEX', style: TextStyle(
            color: Colors.red, fontWeight: FontWeight.bold, fontSize: 25),
        ),
        actions: [
          IconButton(
            icon: Icon(_favoriteFilter == FavoriteFilter.all ? Icons.favorite_border : Icons.favorite, color: Colors.red),
            onPressed: () {
              setState(() {
                _favoriteFilter = _favoriteFilter == FavoriteFilter.all ? FavoriteFilter.favorites : FavoriteFilter.all;
              });
              _applyFilters();
            },
          ),
          IconButton(
            icon: Icon(_sortType == SortType.indice ? Icons.sort_by_alpha : Icons.sort, color: Colors.red),
            onPressed: () {
              setState(() {
                _sortType = _sortType == SortType.indice ? SortType.name : SortType.indice;
              });
              _applyFilters();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              cursorColor: Colors.red,
              decoration: InputDecoration(
                hintText: 'Search for a pokemon...',
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
                  _searchQuery = value;
                });
                _applyFilters();
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
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButton<String>(
                      value: _filterType,
                      hint: const Text('Tipo', style: TextStyle(color: Colors.grey)),
                      underline: Container(),
                      isExpanded: true,
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
                                    ? const AssetImage('assets/types_large/all.png')
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
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButton<int>(
                      value: _filterGeneration,
                      hint: const Text('Generación', style: TextStyle(color: Colors.grey)),
                      underline: Container(),
                      isExpanded: true,
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
                                    ? const AssetImage('assets/types_large/all.png')
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
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _fetchPokemonsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: _Pokemons.length,
                  itemBuilder: (context, index) {
                    if (_Pokemons == null || _Pokemons!.isEmpty) {
                      return const Center(child: Text('No Pokémon found'));
                    }
                    /*if (index == _Pokemons!.length - 1 && _isLoadingMore) {
                      return const Center(child: CircularProgressIndicator());
                    }*/
                    var pokemon = _Pokemons![index];
                    String pokemonName = pokemon['name'].toUpperCase();
                    if (pokemonName.length > 12) {
                      pokemonName = '${pokemonName.substring(0, 12)}...';
                    }
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => PokemonDetailsScreen(id: pokemon['id']),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              var begin = const Offset(1.0, 0.0);
                              var end = Offset.zero;
                              var curve = Curves.ease;
                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/background_list/' + pokemon['pokemon_v2_pokemontypes'][0]['pokemon_v2_type']['name'] + '.png'),
                            fit: BoxFit.cover,
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
                                '# ${pokemon['id'].toString().padLeft(5, '0')}',
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
                                onTap: () {
                                  _toggleFavorite(pokemon['id']);
                                },
                                child: PokeballImage(
                                  pokemonId: pokemon['id'],
                                  favoritePokemons: _favoritePokemons,
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
                                          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${pokemon['id']}.png',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WhosThatPokemonScreen()),
          );
        },
        child: Icon(Icons.gamepad), // Icono de juego
        backgroundColor: Colors.red, // Color de fondo del botón
      ),
    );
  }
}

