Pokedex App
Descripción
Este proyecto es una aplicación de Pokedex desarrollada en Flutter que utiliza la API de PokeAPI para obtener información sobre Pokémon. La aplicación permite a los usuarios explorar una lista de Pokémon, ver detalles de cada Pokémon, y jugar un juego de adivinanza de Pokémon.

Características
Lista de Pokémon: Explora una lista de Pokémon con filtros por tipo, generación y búsqueda.

Detalles del Pokémon: Visualiza detalles completos de cada Pokémon, incluyendo estadísticas, habilidades, evoluciones y movimientos.

Juego de Adivinanza: Juega un juego donde tienes que adivinar el nombre de un Pokémon oculto.

Favoritos: Marca tus Pokémon favoritos y accede a ellos fácilmente.

Lista de Pokémon
Filtros: Utiliza los filtros en la parte superior para filtrar por tipo y generación.

Búsqueda: Usa la barra de búsqueda para encontrar un Pokémon específico por nombre o número.

Favoritos: Marca un Pokémon como favorito haciendo clic en la Poké Ball en la tarjeta del Pokémon.

Detalles del Pokémon
Estadísticas: Ver las estadísticas base del Pokémon.

Habilidades: Explora las habilidades del Pokémon.

Evoluciones: Ver la cadena de evolución del Pokémon.

Movimientos: Lista de movimientos que el Pokémon puede aprender.

Juego de Adivinanza
Adivina el Pokémon: Selecciona el nombre correcto del Pokémon oculto.

Puntuación: Mantén un récord de tu puntuación y compáralo con tu mejor puntuación.

Archivos del Proyecto
main.dart
Punto de entrada de la aplicación. Configura el cliente GraphQL y lanza la aplicación.

PokeballImage.dart
Widget que muestra una Poké Ball roja o blanca dependiendo de si el Pokémon es favorito o no.

queries.dart
Contiene las consultas GraphQL utilizadas para obtener datos de la API de PokeAPI.

graphql_client.dart
Configura el cliente GraphQL para la aplicación.

pokemon_details_screen.dart
Pantalla que muestra los detalles de un Pokémon específico, incluyendo estadísticas, habilidades, evoluciones y movimientos.

pokemon_list_screen.dart
Pantalla principal que muestra una lista de Pokémon con opciones de filtrado, búsqueda y marcado de favoritos.

WhosThatPokemonScreen.dart
Pantalla del juego "¿Quién es ese Pokémon?" donde el usuario debe adivinar el nombre de un Pokémon oculto.

¡Disfruta explorando y aprendiendo sobre tus Pokémon favoritos!
