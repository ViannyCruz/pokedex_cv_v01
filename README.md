Pokedex App
Descripción de la Aplicación
La aplicación Pokedex es una aplicación móvil desarrollada en Flutter que permite a los 
usuarios explorar una lista de Pokémon, ver detalles de cada Pokémon, y filtrar y ordenar 
la lista según diferentes criterios. La aplicación está diseñada para proporcionar una 
experiencia de usuario intuitiva y atractiva, con una interfaz de usuario clara y fácil
de usar. Los usuarios pueden navegar fácilmente por la lista de Pokémon, ver imágenes y 
detalles de cada uno, y filtrar la lista por tipo y generación para encontrar rápidamente 
el Pokémon que desean.

Funcionalidades Principales
La aplicación Pokedex ofrece una serie de funcionalidades que mejoran la experiencia del 
usuario:
Interfaz de Usuario: La interfaz de usuario es intuitiva y atractiva, con una lista de 
Pokémon que muestra sus nombres, imágenes y tipos. Además, se ha creado una pantalla de 
detalles mínimos que muestra información detallada de cada Pokémon, incluyendo nombre, 
tipo, estadísticas, habilidades, evoluciones y movimientos.

Sistema de Filtrado y Ordenación: Los usuarios pueden filtrar la lista de Pokémon por 
tipo y generación, lo que facilita la búsqueda de Pokémon específicos. La lista se 
actualiza dinámicamente según los filtros seleccionados, proporcionando una experiencia
de usuario fluida y eficiente.

Uso de GraphQL
La aplicación Pokedex utiliza la API GraphQL de PokeAPI para obtener los datos de los 
Pokémon. GraphQL es una alternativa eficiente y flexible a las APIs REST tradicionales, 
ya que permite a los clientes solicitar exactamente los datos que necesitan, lo que reduce
la sobrecarga de datos y mejora el rendimiento. La integración de GraphQL en la aplicación 
se realiza utilizando la biblioteca graphql_flutter, que proporciona una interfaz fácil de 
usar para realizar consultas GraphQL. Las consultas específicas para obtener la lista de 
Pokémon y sus detalles se definen en el archivo queries.dart, y se ejecutan utilizando el 
widget Query de graphql_flutter. Esta implementación permite una gestión eficiente de los 
datos y una experiencia de usuario más rápida y fluida.
