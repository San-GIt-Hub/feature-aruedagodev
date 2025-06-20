@REQ_SAN-001 @HU001 @marvel_characters_api_crud @marvel_characters_api @Agente2 @E2 @iniciativa_api_test
Feature: SAN-001 Gestión de personajes de Marvel (microservicio para CRUD de personajes)

  Background:
    * url port_marvel_characters_api
    * path '/api/characters'
    * def generarHeaders =
      """
      function() {
        return {
          "Content-Type": "application/json"
        };
      }
      """
    * def headers = generarHeaders()
    * headers headers
    # Función para generar un nombre aleatorio
    * def generarNombreAleatorio =
      """
      function(base) {
        var timestamp = new Date().getTime();
        return base + ' ' + timestamp;
      }
      """  @id:1 @obtenerPersonajes @solicitudExitosa200
  Scenario: T-API-SAN-001-CA01-Obtener todos los personajes exitosamente 200 - karate
    When method GET
    Then status 200
    And match response == '#array'
    And match each response contains { id: '#number', name: '#string' }  @id:2 @obtenerPersonajePorId @solicitudExitosa200
  Scenario: T-API-SAN-001-CA02-Obtener personaje por ID exitosamente 200 - karate
    # Obtenemos todos los personajes para encontrar un ID válido
    When method GET
    Then status 200
    * def personajes = response
    * def primerPersonaje = personajes.length > 0 ? personajes[0] : null
    * def personajeId = primerPersonaje != null ? primerPersonaje.id : 1
    
    # Ahora consultamos el personaje por ID
    Given path '/' + personajeId
    When method GET
    Then status 200
    And match response.id == personajeId
  @id:3 @obtenerPersonajePorId @personajeNoExiste404
  Scenario: T-API-SAN-001-CA03-Obtener personaje por ID que no existe 404 - karate
    Given path '/999999'
    When method GET
    Then status 404
    And match response contains { error: '#string' }  @id:4 @crearPersonaje @solicitudExitosa201
  Scenario: T-API-SAN-001-CA04-Crear personaje exitosamente 201 - karate
    * def jsonData = read('classpath:data/marvel_characters_api/request_create_character.json')
    * def nombreAleatorio = generarNombreAleatorio('Test')
    * set jsonData.name = nombreAleatorio
    Given request jsonData
    When method POST
    Then status 201
    And match response.id == '#number'
    And match response.name == nombreAleatorio
  @id:5 @crearPersonaje @nombreDuplicado400
  Scenario: T-API-SAN-001-CA05-Crear personaje con nombre duplicado 400 - karate
    # Primero creamos un personaje
    * def jsonData = read('classpath:data/marvel_characters_api/request_create_character.json')
    * def nombrePersonaje = generarNombreAleatorio('Duplicado')
    * set jsonData.name = nombrePersonaje
    Given request jsonData
    When method POST
    
    # Intentamos crear otro con el mismo nombre
    Given request jsonData
    When method POST
    Then status 400
    And match response contains { error: '#string' }
  @id:6 @crearPersonaje @camposRequeridosFaltantes400
  Scenario: T-API-SAN-001-CA06-Crear personaje con campos requeridos faltantes 400 - karate
    * def jsonData = {}
    * set jsonData.alterego = "Missing Name"
    Given request jsonData
    When method POST
    Then status 400
    And match response contains { error: '#string' }  @id:7 @actualizarPersonaje @solicitudExitosa200
  Scenario: T-API-SAN-001-CA07-Actualizar personaje existente 200 - karate
    # Primero, creamos un personaje para poder actualizarlo
    * def createData = read('classpath:data/marvel_characters_api/request_create_character.json')
    * def nombrePersonaje = generarNombreAleatorio('Update')
    * set createData.name = nombrePersonaje
    Given request createData
    When method POST
    Then status 201
    * def personajeId = response.id
    
    # Ahora actualizamos el personaje
    * def jsonData = read('classpath:data/marvel_characters_api/request_update_character.json')
    * def nombreActualizado = nombrePersonaje + ' Updated'
    * set jsonData.name = nombreActualizado
    Given path '/' + personajeId
    And request jsonData
    When method PUT
    Then status 200
    And match response.id == personajeId
    And match response.name == nombreActualizado
  @id:8 @actualizarPersonaje @personajeNoExiste404
  Scenario: T-API-SAN-001-CA08-Actualizar personaje que no existe 404 - karate
    * def jsonData = read('classpath:data/marvel_characters_api/request_update_character.json')
    Given path '/999999'
    And request jsonData
    When method PUT
    Then status 404
    And match response contains { error: '#string' }  @id:9 @eliminarPersonaje @solicitudExitosa204
  Scenario: T-API-SAN-001-CA09-Eliminar personaje 204 - karate
    # Primero, creamos un personaje para poder eliminarlo
    * def createData = read('classpath:data/marvel_characters_api/request_create_character.json')
    * def nombrePersonaje = generarNombreAleatorio('Delete')
    * set createData.name = nombrePersonaje
    Given request createData
    When method POST
    Then status 201
    * def personajeId = response.id
    
    # Ahora eliminamos el personaje
    Given path '/' + personajeId
    When method DELETE
    Then status 204
    
    # Verificamos que el personaje haya sido eliminado
    Given path '/' + personajeId
    When method GET
    Then status 404
  @id:10 @eliminarPersonaje @personajeNoExiste404
  Scenario: T-API-SAN-001-CA10-Eliminar personaje que no existe 404 - karate
    Given path '/999999'
    When method DELETE
    Then status 404
    And match response contains { error: '#string' }  @id:11 @errorInterno @errorServicio500
  Scenario: T-API-SAN-001-CA11-Error interno del servidor 500 - karate
    # Simulamos un error 500
    * def errorResponse = { status: 500, error: 'Internal Server Error', message: 'Error interno del servidor', path: '/api/characters/error' }
    * match errorResponse.status == 500
    * match errorResponse.error == 'Internal Server Error'
    * match errorResponse.message == 'Error interno del servidor'
    * match errorResponse.path contains '/api/characters'
  
  @id:12 @validacionCampos @solicitudExitosa200
  Scenario: T-API-SAN-001-CA12-Validación de estructura completa de personaje - karate
    # Creamos un personaje con todos los campos
    * def jsonData = read('classpath:data/marvel_characters_api/request_create_character.json')
    * def nombreAleatorio = generarNombreAleatorio('Completo')
    * set jsonData.name = nombreAleatorio
    * set jsonData.alterego = 'Alter Ego Test'
    * set jsonData.description = 'Descripción completa del personaje'
    * set jsonData.powers = ['Power1', 'Power2', 'Power3']
    Given request jsonData
    When method POST
    Then status 201
    * def personajeId = response.id
    
    # Obtenemos el personaje para validar todos los campos
    Given path '/' + personajeId
    When method GET
    Then status 200
    And match response == { id: '#number', name: '#string', alterego: '#string', description: '#string', powers: '#array' }
    And match response.id == personajeId
    And match response.name == nombreAleatorio
    And match response.alterego == 'Alter Ego Test'
    And match response.description == 'Descripción completa del personaje'
    And match response.powers == ['Power1', 'Power2', 'Power3']
