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
        backgroundColor: Colors.red, // Cambia el color de fondo a rojo
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
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.network(
                      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemon['id']}.png',
                      height: 200,
                      width: 200,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Nombre: ${pokemon['name']}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Tipo: ${pokemon['pokemon_v2_pokemontypes'][0]['pokemon_v2_type']['name']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Estadísticas:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...pokemon['pokemon_v2_pokemonstats'].map((stat) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${stat['pokemon_v2_stat']['name']}: ${stat['base_stat']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Slider(
                        value: stat['base_stat'].toDouble(),
                        min: 0,
                        max: 255,
                        divisions: 255,
                        activeColor: Colors.red,
                        inactiveColor: Colors.grey,
                        label: stat['base_stat'].toString(),
                        onChanged: (double value) {},
                      ),
                    ],
                  )),
                  SizedBox(height: 20),
                  Text(
                    'Habilidades:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...pokemon['pokemon_v2_pokemonabilities'].map((ability) => Text(
                    ability['pokemon_v2_ability']['name'],
                    style: TextStyle(fontSize: 16),
                  )),
                  SizedBox(height: 20),
                  Text(
                    'Evoluciones:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...pokemon['pokemon_v2_pokemonspecy']['pokemon_v2_evolutionchain']['pokemon_v2_pokemonspecies'].map((evolution) => Text(
                    evolution['name'],
                    style: TextStyle(fontSize: 16),
                  )),
                  SizedBox(height: 20),
                  Text(
                    'Movimientos:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...pokemon['pokemon_v2_pokemonmoves'].map((move) => Text(
                    move['pokemon_v2_move']['name'],
                    style: TextStyle(fontSize: 16),
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}