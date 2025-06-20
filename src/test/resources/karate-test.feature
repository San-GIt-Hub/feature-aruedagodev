@REQ_HU-01 @karate @marvel
Feature: Test de API súper simple

  Background:
    * configure ssl = true
    * def random = java.util.UUID.randomUUID().toString()

  @id:1 @ListCharactersSuccess
  Scenario: T-API-HU-01-CA1-Character Exitoso Verificar que el endpoint responde 200 y el body es un array
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/aruedago/api/characters'
    When method get
    Then status 200
    And match response == '#[]'

  @id:2 @GetCharacterById
  Scenario: T-API-HU-01-CA2-Character Crear personaje y Obtener por Id
    * def name = 'Iron Man ' + random.substring(0, 5)
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/aruedago/api/characters'
    And request
    """
    {
      "name": "#(name)",
      "alterego": "Tony Stark",
      "description": "Genius billionaire",
      "powers": ["Armor", "Flight"]
    }
    """
    When method post
    Then status 201
    * def characterId = response.id

    Given url `http://bp-se-test-cabcd9b246a5.herokuapp.com/aruedago/api/characters/${characterId}`
    When method get
    Then status 200

  @id:3 @GetCharacterByIdNotExists
  Scenario: T-API-HU-01-CA3-Character Obtener por id que no existe
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/aruedago/api/characters/4500'
    When method get
    Then status 404
    And match response.error == "Character not found"

  @id:4 @CreateCharacter
  Scenario: T-API-HU-01-CA4-Character Crear personaje Iron Man
    * def name = 'Iron Man ' + random.substring(0, 5)
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/aruedago/api/characters'
    And request
    """
    {
      "name": "#(name)",
      "alterego": "Tony Stark",
      "description": "Genius billionaire",
      "powers": ["Armor", "Flight"]
    }
    """
    When method post
    Then status 201

  @id:5 @CreateCharacterWithNameAlreadyExists
  Scenario: T-API-HU-01-CA5-Character Crear personaje con nombre que ya existe
    * def name = 'Iron Man ' + random.substring(0, 5)
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/aruedago/api/characters'
    And request
    """
    {
      "name": "#(name)",
      "alterego": "Tony Stark",
      "description": "Genius billionaire",
      "powers": ["Armor", "Flight"]
    }
    """
    When method post
    Then status 201

    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/aruedago/api/characters'
    And request
    """
    {
      "name": "#(name)",
      "alterego": "Tony Stark",
      "description": "Genius billionaire",
      "powers": ["Armor", "Flight"]
    }
    """
    When method post
    Then status 400
    And match response.error == "Character name already exists"

  @id:6 @CreateCharacterMissingParameters
  Scenario: T-API-HU-01-CA6-Character Crear personaje sin enviar parametros requeridos
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/aruedago/api/characters'
    And request
    """
    {
      "name": "",
      "alterego": "",
      "description": "",
      "powers": []
    }
    """
    When method post
    Then status 400
    And match response.name == "Name is required"
    And match response.description == "Description is required"
    And match response.alterego == "Alterego is required"
    And match response.powers == "Powers are required"

  @id:7 @UpdateCharacter
  Scenario: T-API-HU-01-CA7-Character Crear y Actualizar personaje creado
    * def name = 'Iron Man ' + random.substring(0, 5)
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/aruedago/api/characters'
    And request
    """
    {
      "name": "#(name)",
      "alterego": "Tony Stark",
      "description": "Genius billionaire",
      "powers": ["Armor", "Flight"]
    }
    """
    When method post
    Then status 201
    * def characterId = response.id

    Given url `http://bp-se-test-cabcd9b246a5.herokuapp.com/aruedago/api/characters/${characterId}`
    And request
    """
    {
      "name": "Iron Man Avengers Updated",
      "alterego": "Tony Stark",
      "description": "Updated description",
      "powers": ["Armor", "Flight"]
    }
    """
    When method put
    Then status 200
    And match response.name == "Iron Man Avengers Updated"

  @id:8 @UpdateCharacterNotExists
  Scenario: T-API-HU-01-CA8-Character Actualizar personaje que no existe
    * def name = 'Iron Man ' + random.substring(0, 5)
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/aruedago/api/characters/83919'
    And request
    """
    {
      "name": "Iron Man Avengers Updated",
      "alterego": "Tony Stark",
      "description": "Updated description",
      "powers": ["Armor", "Flight"]
    }
    """
    When method put
    Then status 404
    And match response.error == "Character not found"

  @id:9 @DeleteCharacter
  Scenario: T-API-HU-01-CA9-Character Crear y eliminar Character
    * def name = 'Iron Man ' + random.substring(0, 5)
    Given url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/aruedago/api/characters'
    And request
    """
    {
      "name": "#(name)",
      "alterego": "Tony Stark",
      "description": "Genius billionaire",
      "powers": ["Armor", "Flight"]
    }
    """
    When method post
    Then status 201
    * def characterId = response.id

    Given url `http://bp-se-test-cabcd9b246a5.herokuapp.com/aruedago/api/characters/${characterId}`
    When method delete
    Then status 204

