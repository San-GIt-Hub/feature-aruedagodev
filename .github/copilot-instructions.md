# Guía Senior para Automatización con Karate Framework

## Estructura estándar del proyecto

```
src/
├── main/
│   └── java/
│       └── com/
│           └── pichincha/
│               ├── database/
│               ├── model/
│               └── utils/
└── test/
    ├── java/
    │   ├── karate-config.js
    │   ├── logback-test.xml
    │   └── com/
    │       └── pichincha/
    │           ├── TestRunner.java
    │           ├── features/  <-- UBICACIÓN ESTÁNDAR PARA TODOS LOS FEATURES
    │           │   ├── proyecto1/
    │           │   │   └── crearUsuario.feature
    │           │   └── proyecto2/
    │           │       └── consultarProducto.feature
    │           └── utils/
    └── resources/
        └── data/  <-- UBICACIÓN ESTÁNDAR PARA TODOS LOS DATOS
            ├── microservicio1/
            │   └── request_data.json
            ├── microservicio2/
            │   └── response_data.json
            └── utility/
                └── common_data.json
```

> **IMPORTANTE**: 
> 1. Todos los archivos `.feature` DEBEN crearse en la ruta `src/test/java/com/pichincha/features/[nombre_microservicio]/`.
> 2. Todos los archivos de datos JSON DEBEN ubicarse en `src/test/resources/data/[nombre_microservicio]/`.
> 3. Estas rutas son estándar para TODOS los proyectos y NO deben modificarse.

---

## Objetivo

Crear escenarios `.feature` con enfoque senior: estandarizado, limpio, escalable y mantenible.

### Fuentes de entrada y estrategias de generación

- **Si la entrada es una colección Postman:** Se usarán sus requests y ejemplos de respuesta para generar los JSON necesarios en `src/test/resources/data` y construir los escenarios para cada caso de uso.

- **Si la entrada es un comando cURL:** Se generarán automáticamente al menos 3 escenarios base:
  - 200 (respuesta exitosa)
  - 400 (datos inválidos)
  - 500 (error interno del sistema)

- **Si la entrada es un contrato OpenAPI (.yaml o .yml):** Se recorrerán los endpoints definidos para:
  - Generar automáticamente los escenarios por cada operationId
  - Crear los JSON de ejemplo desde requestBody y responses
  - Incluir validaciones de código de estado y estructura esperada del JSON

---

## 1. Convenciones y nombres

| Elemento            | Convención                      | Ejemplo                                 |
|---------------------|----------------------------------|-----------------------------------------|
| Archivo `.feature`  | nombreCamelCase.feature         | crearCuentaNuevaApi.feature           |
| Carpeta de features | nombre del proyecto o servicio  | src/test/java/com/pichincha/features/tre_msa_savings_account |
| Carpeta de JSON     | nombre del servicio             | src/test/resources/data/tre_msa_savings_account |
| Archivos JSON       | snake_case_descriptivo          | request_creation_account.json           |
| Tags principales    | @REQ_ID @HU_ID @descripcion @micro @default   | @REQ_BTPMCDP-118 @HU118 @account_creation @tre_msa_savings_account @Agente2 @E2 @iniciativa_cuentas |
| Tags escenario      | @id:N @descripcion @resultado   | @id:1 @crearCuentaKyc @solicitudExitosa200 |
| Escenarios          | T-API-ID-CAN-Descripción        | T-API-BTPMCDP-118-CA01-Crear cuenta exitosamente 201 - karate |

> **Nota importante:** En los ejemplos, "BTPMCDP-118" es el identificador de una historia de usuario específica. Cuando crees tu feature, debes reemplazarlo por el número de la historia de usuario que estés automatizando. Pregunta al usuario por el ID de la historia de usuario si no lo tienes.
>
> **Nota sobre microservicios:** Si el nombre del microservicio te viene con formato de guiones (ej: `tre-msa-savings-account`), debes convertirlo a snake_case (ej: `tre_msa_savings_account`) para usarlo en los tags y en las variables de entorno. Todos los tags y variables de entorno deben seguir el formato snake_case, independientemente del formato original del nombre. Ejemplo:
> - Nombre original: `cdp-msa-bs-scheduled-savings-account`
> - En tags: `@cdp_msa_bs_scheduled_savings_account`
> - En variable de entorno: `port_cdp_msa_bs_scheduled_savings_account`
> - En Background: `* url port_cdp_msa_bs_scheduled_savings_account`
>
> **Nota sobre variables de entorno:** Es OBLIGATORIO usar las variables definidas en `karate-config.js` para las URLs de los microservicios. Estas variables deben tener el prefijo `port_` seguido del nombre del microservicio en snake_case. Si la variable que necesitas no existe en `karate-config.js`, debes añadirla siguiendo esta convención.
>
> **Nota sobre archivos .feature:** El nombre del archivo `.feature` debe estar en formato camelCase y ser descriptivo de la funcionalidad que se está automatizando. Por ejemplo, `crearCuentaCliente.feature`, `consultarProductoActivo.feature`, `validarTransaccionSegura.feature`. Asegúrate de que el nombre refleje claramente el propósito de las pruebas contenidas en el archivo.

---

## 2. Plantilla estándar de Feature

```gherkin
@REQ_[HISTORIA-ID] @HU[ID-SIN-PREFIJO] @descripcion_historia @nombre_microservicio @Agente2 @E2 @iniciativa_descripcion
Feature: [HISTORIA-ID] Nombre de la funcionalidad (microservicio para...)
  Background:
    * url port_nombre_microservicio
    * path '/ruta/a/endpoint'
    * def generarHeaders =
      """
      function() {
        return {
          "X-Guid": "88212f38-cc02-4083-a763-8cc09a933840",
          "X-Flow": "onboard",
          "Content-Type": "application/json"
        };
      }
      """
    * def headers = generarHeaders()
    * headers headers    @id:1 @tag_descriptivo @resultado_esperado
  Scenario: T-API-[HISTORIA-ID]-CA01-Descripción acción resultado código - karate
    * def jsonData = read('classpath:data/microservicio/datos_request.json')
    And request jsonData
    When method POST
    Then status 200
    # And match response != null
    # And match response.data != null

    Examples:
      | read('classpath:data/microservicio/datos_ejemplo.json') |
```

> **Importante:** Todos los features DEBEN incluir los siguientes tags en la primera línea:
> - `@REQ_[HISTORIA-ID]`: Número de la historia de usuario (ej: @REQ_BTPMCDP-118)
> - `@HU[ID-SIN-PREFIJO]`: ID de la historia de usuario sin prefijo (ej: @HU118)
> - `@descripcion_historia`: Descripción breve de la historia de usuario en snake_case (ej: @account_creation_savings)
> - `@nombre_microservicio`: Nombre del microservicio con guion bajo (ej: @tre_msa_savings_account). Si el nombre original contiene guiones, debe convertirse a guiones bajos.
> - `@Agente2 @E2`: Tags fijos que deben ir siempre
> - `@iniciativa_descripcion`: Descripción corta de la iniciativa en snake_case (ej: @iniciativa_cuentas)
>
> Donde `[HISTORIA-ID]` debe ser reemplazado con el ID real de la historia de usuario que estás automatizando (ej: BTPMCDP-118).

---

## 3. JSON de ejemplo (`src/test/resources/data/usuarios/usuarios_validos.json`)

```json
[
  {
    "nombre": "Marco Clavijo",
    "email": "marco@test.com",
    "rol": "admin"
  },
  {
    "nombre": "Erick Torres",
    "email": "etorres@test.com",
    "rol": "usuario"
  }
]
```

---

## 4. Buenas prácticas de código limpio

- Reutiliza `Background` para `baseUrl`, autenticación y headers comunes.
- Divide escenarios por criterio de aceptación (no más de uno por escenario).
- Centraliza y reutiliza datos de prueba en `src/test/resources/data/...`.
- No hardcodees valores repetitivos (usar `karate-config.js` o archivos JSON).
- Usa `Scenario Outline` cuando haya múltiples combinaciones de datos.
- Agrupa features por proyecto en `src/test/java/com/pichincha/features`.
- **Cada feature debe tener los tags obligatorios**: `@REQ_[HISTORIA-ID] @funcionalidad @nombre_microservicio @Agente2 @E2`
- **Los escenarios deben tener el formato**: `T-API-[HISTORIA-ID]-CAXX-Descripción acción resultado código - karate`
- **Cada feature debe incluir por defecto al menos estos escenarios**:
  - Escenario para errores de validación (HTTP status 400)
  - Escenario para errores internos del servidor (HTTP status 500)
- **Solicita siempre el ID de la historia de usuario** antes de comenzar a crear un feature, para poder incluirlo correctamente en todos los lugares necesarios.
- **Gestión de variables de entorno**:
  - Las URL de los microservicios DEBEN definirse en `karate-config.js` con el formato `port_nombre_microservicio`
  - Nunca usar URLs hardcodeadas en los features, siempre usar las variables definidas en `karate-config.js`
  - Al empezar un nuevo proyecto, verificar si el microservicio ya está definido en `karate-config.js` y añadirlo si no lo está
  - Usar siempre snake_case (guiones bajos) para los nombres de microservicios, independientemente de su nombre original

---

## 5. Validaciones estándar recomendadas

| Tipo de validación | Ejemplo                                           |
|--------------------|---------------------------------------------------|
| Status             | `Then status 201`                                 |
| Campo presente     | `# And match response.id != null`                 |
| Error específico   | `Then status 409`<br>`# And match response.message == 'Ya existe'` |
| Esquema JSON       | `# And match response == karate.read('schema.json')`|
| Múltiples validaciones | `# And match response.status == 200`<br>`# And match response.data != null` |

> **Importante:** Todas las validaciones de tipo `match` deben estar comentadas en la plantilla inicial como sugerencias. Para cada escenario, se deben incluir exactamente 2 matchers comentados que sean específicos para ese caso. El desarrollador debe descomentarlas según sus necesidades específicas y puede añadir validaciones adicionales si lo requiere.

---

## 6. karate-config.js base (`src/test/java/karate-config.js`)

```javascript
function fn() {
  var env = karate.env || 'local';
  
  // Configuración base para todos los entornos
  var config = {
    baseUrl: 'http://localhost:8080'
  };
  
  // URLs para todos los microservicios (nombrados con formato port_nombre_microservicio)
  config.port_tre_msa_savings_account = 'http://localhost:8081/tre-msa-savings-account';
  config.port_onb_msa_bs_rt_account_detail = 'http://localhost:8082/onb-msa-bs-rt-account-detail';
  config.port_cdp_msa_bs_scheduled_savings_account = 'http://localhost:8083/cdp-msa-bs-scheduled-savings-account';
  config.port_tre_msa_brms = 'http://localhost:8084/tre-msa-brms';
  // Agrega todos los microservicios que utiliza tu proyecto
  
  // Configuración específica por entorno
  if (env == 'dev') {
    config.baseUrl = 'https://api-dev.empresa.com';
    config.port_tre_msa_savings_account = 'https://api-dev.empresa.com/tre-msa-savings-account';
    config.port_onb_msa_bs_rt_account_detail = 'https://api-dev.empresa.com/onb-msa-bs-rt-account-detail';
    config.port_cdp_msa_bs_scheduled_savings_account = 'https://api-dev.empresa.com/cdp-msa-bs-scheduled-savings-account';
    config.port_tre_msa_brms = 'https://api-dev.empresa.com/tre-msa-brms';
    // Actualiza las URLs para cada microservicio en este entorno
  } 
  else if (env == 'qa') {
    config.baseUrl = 'https://api-qa.empresa.com';
    config.port_tre_msa_savings_account = 'https://api-qa.empresa.com/tre-msa-savings-account';
    config.port_onb_msa_bs_rt_account_detail = 'https://api-qa.empresa.com/onb-msa-bs-rt-account-detail';
    config.port_cdp_msa_bs_scheduled_savings_account = 'https://api-qa.empresa.com/cdp-msa-bs-scheduled-savings-account';
    config.port_tre_msa_brms = 'https://api-qa.empresa.com/tre-msa-brms';
    // Actualiza las URLs para cada microservicio en este entorno
  }
  
  return config;
}
```

> **IMPORTANTE sobre las variables de microservicios:**
> 
> 1. **Convención de nombres:** Todas las variables de URL de microservicios deben seguir el formato `port_nombre_microservicio` donde:
>    - El prefijo `port_` es obligatorio para todos los microservicios
>    - `nombre_microservicio` debe estar en snake_case (usar guiones bajos en lugar de guiones)
>    - Ejemplo: Para el microservicio `cdp-msa-bs-scheduled-savings-account`, la variable debe ser `port_cdp_msa_bs_scheduled_savings_account`
>
> 2. **Uso en los Features:** Para usar estas variables en los features, simplemente utiliza `url port_nombre_microservicio` en el Background:
>    ```gherkin
>    Background:
>      * url port_cdp_msa_bs_scheduled_savings_account
>      * path '/api/v1/scheduled-savings'
>    ```
>
> 3. **Agregar nuevos microservicios:** Cuando necesites agregar un nuevo microservicio:
>    - Agrega la variable con el prefijo `port_` en el archivo `karate-config.js`
>    - Define su valor para cada entorno (local, dev, qa, etc.)
>    - Asegúrate de seguir el formato snake_case para el nombre del microservicio
>
> 4. **Actualización de microservicios existentes:** Antes de comenzar a automatizar un nuevo proyecto, verifica que todos los microservicios necesarios estén definidos en `karate-config.js`

---

## 7. Formato estándar para escenarios

### Ejemplo completo basado en la Historia de Usuario BTPMCDP-118

> **Nota:** BTPMCDP-118 es un ejemplo de ID de historia de usuario. Siempre solicita al usuario el ID real de la historia que se está automatizando.

```gherkin
@REQ_BTPMCDP-118 @HU118 @account_creation_savings @tre_msa_savings_account @Agente2 @E2 @iniciativa_cuentas
Feature: BTPMCDP-118 Crear cuenta exitosamente (microservicio transversal para crear cuentas)
  Background:
    * url port_tre_msa_savings_account
    * path '/api/v1/retail/savings-account/SavingsAccount/Initiate'
    * def generarHeaders =
      """
      function() {
        return {
          "X-Guid": "88212f38-cc02-4083-a763-8cc09a933840",
          "X-Flow": "onboard",
          "X-Process": "transaccional",
          "x-request-id": "db8172fc-01e1-47e4-beaf-6791db628363",
          "x-session": "0163e87a-699b-4ff9-8116-91193b583def",
          "x-agency": "223",
          "x-channel": "02",
          "X-Application": "02",
          "X-Medium": "020200",
          "Content-Type": "application/json"
        };
      }
      """
    * def headers = generarHeaders()
    * headers headers
  @id:1 @crearCuentaKyc @solicitudExitosa200
  Scenario: T-API-BTPMCDP-118-CA01-Crear cuenta exitosamente 201 - karate
    * def jsonData = read('classpath:data/tre_msa_savings_account/request_creation_account.json')
    * def result = call read('classpath:com/pichincha/features/utility/generar_compliance_id.feature@generar_compliance_id')
    * set jsonData.savingsAccountFacility.customerReference.complianceId = result.response.regulatoryComplianceId    
    And request jsonData
    When method POST
    Then status 200
    # And match response != null
    # And match response.accountId != null
  @id:2 @crearCuentaKyc @errorValidacion400
  Scenario: T-API-BTPMCDP-118-CA02-Crear cuenta con datos inválidos 400 - karate
    * def jsonData = read('classpath:data/tre_msa_savings_account/request_creation_account.json')
    * set jsonData.savingsAccountFacility.customerReference.customerId = null    
    And request jsonData
    When method POST
    Then status 400
    # And match response.message contains 'Error de validación'
    # And match response.status == 400
  @id:3 @crearCuentaKyc @errorServicio500
  Scenario: T-API-BTPMCDP-118-CA03-Crear cuenta con error interno 500 - karate
    * def jsonData = read('classpath:data/tre_msa_savings_account/request_creation_account.json')
    * set jsonData.savingsAccountFacility.customerReference.customerId = '9999999999'
    And request jsonData
    When method POST
    Then status 400
    # And match response.status == 400
    # And match response.message contains 'Error interno del servidor'
```

> **Nota:** Siempre considera añadir más escenarios para cubrir casos adicionales como validaciones de campos, límites de caracteres y casos de seguridad.

### Elementos obligatorios a considerar:

1. **Primera línea con tags obligatorios**:
   ```
   @REQ_[HISTORIA-ID] @HU[ID-SIN-PREFIJO] @descripcion_historia @nombre_microservicio @Agente2 @E2 @iniciativa_descripcion
   ```
   _Donde [HISTORIA-ID] debe ser reemplazado con el ID real de la historia de usuario (ej: BTPMCDP-118)_

   **Ejemplo real**: 
   ```
   @REQ_BTPMCDP-416 @HU416 @account_detail_hash_mask_account @onb_msa_bs_rt_account_detail @Agente2 @E2 @iniciativa_detalle_cuenta
   ```

   **Explicación de cada tag**:
   - `@REQ_BTPMCDP-416`: ID completo de la historia de usuario con su prefijo
   - `@HU416`: ID numérico de la historia sin prefijo
   - `@account_detail_hash_mask_account`: Descripción funcional de la historia en snake_case
   - `@onb_msa_bs_rt_account_detail`: Nombre del microservicio en snake_case
   - `@Agente2 @E2`: Tags fijos obligatorios
   - `@iniciativa_detalle_cuenta`: Descripción corta de la iniciativa relacionada

2. **Formato del Feature**:
   ```
   Feature: [HISTORIA-ID] Nombre descriptivo (microservicio para...)
   ```
   _Incluye el ID de la historia al inicio del título del Feature_

3. **Formato de escenarios**:
   ```
   Scenario: T-API-[HISTORIA-ID]-CAXX-Descripción acción resultado código - karate
   ```
   _Donde XX es el número secuencial del caso de aceptación_

   **Nota sobre escenarios obligatorios**: Por defecto, todo feature debe incluir al menos estos escenarios:
   - Escenario exitoso (status 200/201)
   - Escenario de error de validación (status 400)
   - Escenario de error interno del servidor (status 500)

4. **Tags de escenario**:
   ```
   @id:X @funcionalidad @resultadoEsperado
   ```
   _X debe ser un número secuencial_

5. **Rutas de archivos JSON**:
   ```
   classpath:data/nombre_microservicio/archivo.json
   ```
   _Siempre usa la ruta completa desde la raíz classpath. Los archivos JSON deben estar ubicados en `src/test/resources/data/nombre_microservicio/`_

---

## 8. Ubicación estándar de archivos

Para garantizar la consistencia en todos los proyectos, es fundamental seguir estrictamente estas convenciones de ubicación:

### Archivos Feature

- **Ubicación obligatoria**: `src/test/java/com/pichincha/features/[nombre_microservicio]/`
- **Ejemplo**: `src/test/java/com/pichincha/features/tre_msa_savings_account/crearCuentaAhorros.feature`

### Archivos JSON de datos

- **Ubicación obligatoria**: `src/test/resources/data/[nombre_microservicio]/`
- **Ejemplo**: `src/test/resources/data/tre_msa_savings_account/request_creation_account.json`

### Archivos de utilidad

- **Ubicación de Karate config**: `src/test/java/karate-config.js`
- **Ubicación de funciones de utilidad**: `src/main/java/com/pichincha/utils/`

> **IMPORTANTE**: 
> - Nunca crear carpetas en ubicaciones diferentes a las especificadas.
> - La estructura de carpetas debe ser idéntica en todos los proyectos.
> - Cada microservicio debe tener su propia carpeta dentro de features y data.
> - En caso de encontrar un proyecto con una estructura diferente, debe ser actualizado para cumplir con este estándar.
> - Al comenzar un nuevo proyecto, verificar que todos los microservicios a utilizar estén definidos en `karate-config.js`. Si alguno no está definido, añadirlo siguiendo el formato estándar.

---

## 9. Lista de verificación para nuevos proyectos

Antes de comenzar a trabajar en un nuevo proyecto, verifica los siguientes puntos:

1. **Verificación de estructura de carpetas**:
   - Confirmar que existe la estructura estándar según la sección 1 de esta guía
   - Crear carpetas faltantes si es necesario

2. **Verificación de karate-config.js**:
   - Confirmar que el archivo existe en `src/test/java/karate-config.js`
   - Verificar que incluye la configuración básica de entornos (local, dev, qa)
   - **Importante**: Verificar que todos los microservicios que se van a utilizar estén definidos con el formato `port_nombre_microservicio`
   - Añadir los microservicios faltantes siguiendo el formato estándar

3. **Verificación de carpetas de datos**:
   - Confirmar que existe la estructura para datos en `src/test/resources/data/`
   - Crear las carpetas necesarias para los microservicios que se van a utilizar

4. **Verificación de features**:
   - Confirmar que existe la estructura para features en `src/test/java/com/pichincha/features/`
   - Crear las carpetas necesarias para los microservicios que se van a utilizar

5. **Recordatorio de convenciones de nombres**:
   - Variables de entorno: `port_nombre_microservicio` (snake_case)
   - Carpetas de microservicio: `nombre_microservicio` (snake_case)
   - Archivos feature: `nombreCamelCase.feature` (camelCase)
   - Archivos JSON: `nombre_descriptivo.json` (snake_case)

Al seguir esta lista de verificación, garantizarás que el proyecto sigue los estándares establecidos y que no faltarán las variables de entorno necesarias para los microservicios.

---

## Créditos

Guía estandarizada por el equipo QA/Dev de [Tu Empresa].  
Responsable técnico: Marco Clavijo  
Contacto para dudas: [Tu correo o canal interno]