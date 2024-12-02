import 'package:flutter/material.dart';

class PokeballImage extends StatelessWidget {
  final int pokemonId;
  final List<int> favoritePokemons;

  PokeballImage({required this.pokemonId, required this.favoritePokemons});

  @override
  Widget build(BuildContext context) {
    String imagePath = favoritePokemons.contains(pokemonId)
        ? "assets/general/red_pokeball.png"
        : "assets/general/white_pokeball.png";
    return CircleAvatar(
      radius: 15,
      backgroundImage: AssetImage(imagePath),
      backgroundColor: Colors.transparent,
    );
  }
}