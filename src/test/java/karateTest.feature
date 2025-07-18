Feature: PetStore API Test
  Background:
    * def baseUrl = karate.properties['baseUrl'] || 'https://petstore.swagger.io/v2'
    * def randomId = function() { return java.lang.System.currentTimeMillis() % 1000000 }
    * def testPetId = randomId()
    * print 'ID generado para este test', testPetId

  Scenario: Agregar una mascota a la tienda, consulta por ID, actualizar nombre de la mascota, consulta por status
    # 1. Agregar nueva mascota a la tienda
    Given url baseUrl + '/pet'
    And request
    """
    {
      "name": "doggie",
      "photoUrls": [
        "cillum deserunt irure sit",
        "minim consequat"
      ],
      "id": #(testPetId),
      "category": {
        "id": -71766204,
        "name": "labore enim consectetur amet velit"
      },
      "tags": [
        {
          "id": 59431783,
          "name": "nulla exercitation"
        },
        {
          "id": -46476026,
          "name": "est sint tempor minim nulla"
        }
      ],
      "status": "available"
    }
    """
    When method POST
    Then status 200
    * def petId = response.id //ID de la respuesta
    * print 'Mascota creada con ID:', petId
    * karate.pause(25000) // Pausa de 15 segundos para dar tiempo a la API

    #2. Obtener mascota por ID
    Given url baseUrl + '/pet/' + petId
    When method GET
    Then status 200
    And match response.id == petId
    And match response.name == "doggie"
    * print 'Mascota obtenida por ID:', response

    #3. Actualizar el nombre y estatus de la mascota a "sold"
    Given url baseUrl + '/pet'
    And request
    """
    {
"id": #(petId),
      "name": "cat",
      "photoUrls": [
        "cillum deserunt irure sit",
        "minim consequat"
      ],

      "category": {
        "id": -71766204,
        "name": "labore enim consectetur amet velit"
      },
      "tags": [
        {
          "id": 59431783,
          "name": "nulla exercitation"
        },
        {
          "id": -46476026,
          "name": "est sint tempor minim nulla"
        }
      ],
      "status": "sold"
    }
    """
    When method PUT
    Then status 200
    * def updatedPedId = response.id
    And match updatedPedId == petId
    And match response.name == "cat"
    And match response.status == "sold"
    * print 'Mascota actualizada:', response
    * karate.pause(15000) // Pausa de 5 segundos despues del PUT y antes del findbyStatus

    #Obtener la mascota por ID para confirmar el status
    Given url baseUrl + '/pet/' + petId
    When method GET
    Then status 200
    * def updatedPetId = response.id
    And match updatedPetId == petId
    And match response.name == "cat"
    And match response.status == "sold"
    * print 'Mascota vendida por ID:', response

    #4 Buscar mascota por el status "sold" y verificar que la mascota actualizada este ahí
    Given url baseUrl + '/pet/findByStatus'
    And param status = 'sold'
    When method GET
    Then status 200
    * print 'Mascotas con el status "sold"'. response
    #Comprobacion si la mascota se encuantra
    * def soldPetsWithOurId = karate.filter(response, function(x) { return x.id == petId })
    * print 'La mascota (ID: ' + petId + ') esta en lista de "sold":',soldPetsWithOurId