import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../queries.dart';

class PokemonDetailsScreen extends StatefulWidget {
  final int id;

  const PokemonDetailsScreen({Key? key, required this.id}) : super(key: key);

  @override
  _PokemonDetailsScreenState createState() => _PokemonDetailsScreenState(); // crear una instancia del estado asociado a este widget
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
                                pokemon['pokemon_v2_pokemonabilities'].map((ability) => ability['pokemon_v2_ability']['name']).join('\n'),
                              ),
                              const SizedBox(height: 20),
                              _buildInfoContainer(
                                'Evolutions',
                                pokemon['pokemon_v2_pokemonspecy']['pokemon_v2_evolutionchain']['pokemon_v2_pokemonspecies'].map((evolution) => evolution['name']).join('\n'),
                              ),
                              const SizedBox(height: 20),
                              _buildInfoContainer(
                                'Moves',
                                pokemon['pokemon_v2_pokemonmoves'].map((move) => move['pokemon_v2_move']['name']).join('\n'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoContainer(String title, String content) {
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
}