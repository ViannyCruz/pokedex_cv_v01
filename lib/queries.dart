const String getPokemonList = r'''
query GetPokemonList {
  pokemon_v2_pokemon {
    id
    name
    pokemon_v2_pokemontypes {
      pokemon_v2_type {
        name
      }
    }
    pokemon_v2_pokemonspecy {
      generation_id
    }
  }
}
''';

const String getPokemonDetails = r'''
query GetPokemonDetails($id: Int!) {
  pokemon_v2_pokemon_by_pk(id: $id) {
    id
    name
    pokemon_v2_pokemontypes {
      pokemon_v2_type {
        name
      }
    }
    pokemon_v2_pokemonstats {
      base_stat
      pokemon_v2_stat {
        name
      }
    }
    pokemon_v2_pokemonabilities {
      pokemon_v2_ability {
        name
      }
    }
    pokemon_v2_pokemonspecy {
      pokemon_v2_evolutionchain {
        pokemon_v2_pokemonspecies {
          name
        }
      }
    }
    pokemon_v2_pokemonmoves {
      pokemon_v2_move {
        name
      }
    }
  }
}
''';