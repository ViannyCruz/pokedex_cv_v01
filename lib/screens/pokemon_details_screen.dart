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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Pokémon'),
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.network(
                    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemon['id']}.png',
                  ),
                  Text('Nombre: ${pokemon['name']}'),
                  Text('Tipo: ${pokemon['pokemon_v2_pokemontypes'][0]['pokemon_v2_type']['name']}'),
                  Text('Estadísticas:'),
                  ...pokemon['pokemon_v2_pokemonstats'].map((stat) => Text('${stat['pokemon_v2_stat']['name']}: ${stat['base_stat']}')),
                  Text('Habilidades:'),
                  ...pokemon['pokemon_v2_pokemonabilities'].map((ability) => Text(ability['pokemon_v2_ability']['name'])),
                  Text('Evoluciones:'),
                  ...pokemon['pokemon_v2_pokemonspecy']['pokemon_v2_evolutionchain']['pokemon_v2_pokemonspecies'].map((evolution) => Text(evolution['name'])),
                  Text('Movimientos:'),
                  ...pokemon['pokemon_v2_pokemonmoves'].map((move) => Text(move['pokemon_v2_move']['name'])),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}