import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../../queries.dart';

class WhosThatPokemonScreen extends StatefulWidget {
  @override
  _WhosThatPokemonScreenState createState() => _WhosThatPokemonScreenState();
}

class _WhosThatPokemonScreenState extends State<WhosThatPokemonScreen> {
  int _pokemonId = 0;
  String _pokemonName = '';
  List<String> _options = [];
  int _score = 0;
  int _highScore = 0; // Nuevo campo para el High Score
  bool _isLoading = false;
  Future<void>? _fetchPokemonFuture;
  bool _isImageRevealed = false;
  bool _showDialog = false;
  String _dialogMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPokemonFuture = null;
    _loadHighScore(); // Cargar el high score al iniciar la aplicación
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchPokemonFuture = _generateNewPokemon();
  }

  Future<void> _generateNewPokemon() async {
    setState(() {
      _isLoading = true;
      _pokemonId = Random().nextInt(898) + 1;
      _options.clear();
      _isImageRevealed = false;
    });

    final queryOptions = QueryOptions(
      document: gql(getPokemonName),
      variables: {'id': _pokemonId},
    );

    final client = GraphQLProvider.of(context).value;
    final result = await client.query(queryOptions);

    if (!result.hasException && result.data != null) {
      setState(() {
        _pokemonName = result.data!['pokemon_v2_pokemon_by_pk']['name'];
        _generateOptions();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _generateOptions() async {
    List<int> incorrectIds = [];
    while (incorrectIds.length < 3) {
      int id = Random().nextInt(898) + 1;
      if (id != _pokemonId && !incorrectIds.contains(id)) {
        incorrectIds.add(id);
      }
    }

    final queryOptions = QueryOptions(
      document: gql(getPokemonNames),
      variables: {'ids': incorrectIds},
    );

    final client = GraphQLProvider.of(context).value;
    final result = await client.query(queryOptions);

    if (!result.hasException && result.data != null) {
      List<String> incorrectNames = List<String>.from(result.data!['pokemon_v2_pokemon'].map((pokemon) => pokemon['name']));
      setState(() {
        _options = [...incorrectNames, _pokemonName]..shuffle();
      });
    }
  }

  void _checkAnswer(String selectedName) async {
    if (selectedName == _pokemonName) {
      setState(() {
        _score++;
        if (_score > _highScore) {
          _highScore = _score; // Actualizar el High Score si es necesario
          _saveHighScore(_highScore); // Guardar el nuevo high score
        }
        _isImageRevealed = true;
        _showDialog = true;
        _dialogMessage = '¡Correcto! Es ' + _pokemonName + "!";
      });
    } else {
      setState(() {
        _score = 0;
        _isImageRevealed = true;
        _showDialog = true;
        _dialogMessage = '¡Incorrecto! El pokemon era $_pokemonName. El puntaje se ha reiniciado.';
      });
    }
  }

  Future<void> _saveHighScore(int score) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', score);
  }

  Future<void> _loadHighScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('highScore') ?? 0; // Cargar el high score o 0 si no existe
    });
  }

  void _closeDialog() {
    setState(() {
      _showDialog = false;
      _fetchPokemonFuture = _generateNewPokemon();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Who\'s That Pokémon?'),
        backgroundColor: Colors.red,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/general/bgPoke.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SCORE: $_score',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                  ),
                  Text(
                    'HIGH SCORE: $_highScore',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
            FutureBuilder(
              future: _fetchPokemonFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40),
                      Container(
                        width: 300,
                        height: 300,
                        child: _isImageRevealed
                            ? Image.network(
                          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$_pokemonId.png',
                          fit: BoxFit.contain,
                        )
                            : ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              colors: [Colors.black, Colors.black],
                              stops: [0.0, 1.0],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.srcATop,
                          child: Image.network(
                            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$_pokemonId.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      Column(
                        children: _options.map((option) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SizedBox(
                              width: 300,
                              child: ElevatedButton(
                                onPressed: () => _checkAnswer(option),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: Text(
                                  option.toUpperCase(),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
            if (_showDialog)
              Positioned(
                bottom: 50,
                left: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _dialogMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _closeDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text(
                          'Continuar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}