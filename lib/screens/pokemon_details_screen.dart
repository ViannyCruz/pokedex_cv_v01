import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../queries.dart';

class PokemonDetailsScreen extends StatefulWidget {
  final int id;

  const PokemonDetailsScreen({Key? key, required this.id}) : super(key: key);

  @override
  _PokemonDetailsScreenState createState() => _PokemonDetailsScreenState();
}

class _PokemonDetailsScreenState extends State<PokemonDetailsScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _visible = true;
      });
    });
  }

  void _navigateToPokemon(int id) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PokemonDetailsScreen(id: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokemon Details'),
        backgroundColor: Colors.red,
      ),
      body: Query(
        options: QueryOptions(
          document: gql(getPokemonDetails),
          variables: {'id': widget.id},
        ),
        builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return Center(child: Text(result.exception.toString()));
          }

          if (result.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          var pokemon = result.data?['pokemon_v2_pokemon_by_pk'];
          var evolutions = pokemon['pokemon_v2_pokemonspecy']['pokemon_v2_evolutionchain']['pokemon_v2_pokemonspecies'];

          // Procesar las evoluciones para incluir la información de las evoluciones siguientes
          for (var evolution in evolutions) {
            evolution['evolves_to'] = evolution['evolves_to'].map((evo) => evo).toList();
          }

          // Construir el árbol de evoluciones
          var evolutionTree = _buildEvolutionTree(evolutions);

          // Ordenar las evoluciones por ID
          evolutions.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));

          return AnimatedOpacity(
            opacity: _visible ? 1.0 : 0.0,
            duration: Duration(milliseconds: 500),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Imagen principal
                              Container(
                                height: 140,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      child: Stack(
                                        children: [
                                          // Fondo de la CircleAvatar
                                          Container(
                                            width: 500,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage('assets/background_list/' + pokemon['pokemon_v2_pokemontypes'][0]['pokemon_v2_type']['name'] + '.png'),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          // CircleAvatar con el fondo gris
                                          Positioned(
                                            top: -15,
                                            left: 15,
                                            child: CircleAvatar(
                                              radius: 70,
                                              backgroundColor: const Color(0xFFFAFAFA),
                                              backgroundImage: NetworkImage(
                                                'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemon['id']}.png',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${pokemon['name']}'.toUpperCase(),
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  // Imegenes a la izquierda
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                          '${'assets/types_large/' + pokemon['pokemon_v2_pokemontypes'][0]['pokemon_v2_type']['name']}.png',
                                          height: 32,
                                          width: 100,
                                        ),
                                        const SizedBox(width: 0), // Espacio entre las imagenes
                                        if (pokemon['pokemon_v2_pokemontypes'].length == 2)
                                          Image.asset(
                                            'assets/types_large/${pokemon['pokemon_v2_pokemontypes'][1]['pokemon_v2_type']['name']}.png',
                                            height: 32,
                                            width: 100,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(16.0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              const SizedBox(height: 0),
                              _buildInfoContainer(
                                'Stats',
                                pokemon['pokemon_v2_pokemonstats'].map((stat) => '${stat['pokemon_v2_stat']['name']}: ${stat['base_stat']}').join('\n'),
                              ),
                              const SizedBox(height: 20),
                              _buildInfoContainer(
                                'Abilities',
                                pokemon['pokemon_v2_pokemonabilities'],
                              ),
                              const SizedBox(height: 20),
                              _buildInfoContainer(
                                'Evolutions',
                                _buildEvolutionChain(evolutionTree),
                              ),
                              const SizedBox(height: 20),
                              _buildInfoContainer(
                                'Moves',
                                pokemon['pokemon_v2_pokemonmoves'],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Flecha izquierda
                Positioned(
                  top: MediaQuery.of(context).size.height / 2 - 24, // Centrado verticalmente
                  left: 16, // Margen izquierdo
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      if (widget.id > 1) {
                        _navigateToPokemon(widget.id - 1);
                      }
                    },
                  ),
                ),
                // Flecha derecha
                Positioned(
                  top: MediaQuery.of(context).size.height / 2 - 24, // Centrado verticalmente
                  right: 16, // Margen derecho
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () {
                      _navigateToPokemon(widget.id + 1);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoContainer(String title, dynamic content) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (title == 'Stats')
            _buildStatsSlider(content)
          else if (title == 'Evolutions')
            Center(child: content)
          else if (title == 'Abilities')
              _buildAbilitiesList(content)
            else if (title == 'Moves')
                _buildMovesList(content)
              else
                Text(
                  content,
                  style: const TextStyle(fontSize: 16),
                ),
        ],
      ),
    );
  }

  Widget _buildStatsSlider(String content) {
    List<String> stats = content.split('\n');
    return Column(
      children: stats.map((stat) {
        List<String> parts = stat.split(': ');
        String statName = parts[0];
        int statValue = int.parse(parts[1]);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              statName,
              style: const TextStyle(fontSize: 16),
            ),
            Slider(
              value: statValue.toDouble(),
              min: 0,
              max: 255,
              divisions: 255,
              label: statValue.toString(),
              onChanged: (double value) {},
            ),
          ],
        );
      }).toList(),
    );
  }

  List<dynamic> _buildEvolutionTree(List<dynamic> evolutions) {
    Map<int, dynamic> evolutionMap = {};
    List<dynamic> evolutionTree = [];

    // Crear un mapa de evoluciones por ID
    for (var evolution in evolutions) {
      evolutionMap[evolution['id']] = evolution;
    }

    // Construir el árbol de evoluciones
    for (var evolution in evolutions) {
      if (evolution['evolves_to'] != null && evolution['evolves_to'].isNotEmpty) {
        for (var nextEvolution in evolution['evolves_to']) {
          evolutionMap[nextEvolution['id']]['parent'] = evolution;
          evolution['evolves_to'] = evolution['evolves_to'].map((evo) => evolutionMap[evo['id']]).toList();
        }
      }
    }

    // Encontrar la raíz del árbol
    for (var evolution in evolutions) {
      if (evolution['parent'] == null) {
        evolutionTree.add(evolution);
      }
    }

    return evolutionTree;
  }

  Widget _buildEvolutionChain(List<dynamic> evolutions) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var evolution in evolutions)
            _buildEvolutionNode(evolution),
        ],
      ),
    );
  }

  Widget _buildEvolutionNode(dynamic evolution) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PokemonDetailsScreen(id: evolution['id']),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(
                  'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${evolution['id']}.png',
                ),
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            evolution['name'].toUpperCase(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          if (evolution['evolves_to'] != null && evolution['evolves_to'].isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var nextEvolution in evolution['evolves_to'])
                  _buildEvolutionNode(nextEvolution),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAbilitiesList(List<dynamic> abilities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: abilities.map((ability) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ability['pokemon_v2_ability']['name'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              ability['pokemon_v2_ability']['pokemon_v2_abilityeffecttexts'][0]['effect'],
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildMovesList(List<dynamic> moves) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: moves.map((move) {
        final moveData = move['pokemon_v2_move'];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              moveData['name'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'Accuracy: ${moveData['accuracy'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Power: ${moveData['power'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'PP: ${moveData['pp'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Damage Type: ${moveData['pokemon_v2_movedamageclass']?['name'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
          ],
        );
      }).toList(),
    );
  }
}