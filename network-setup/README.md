# PADFED-NETWORK-SETUP

## Introducción

`padfed-network-setup` (en adelante `NS`) es un proyecto bash que permite configurar peers y orderers para la red de blockchain del Padrón Federal con la siguiente configuración inicial:

- Red Hyperledger Fabric 1.4.3
- Un orderer SOLO corriendo en la organización AFIP (preparado para migrar a RAFT)
- Un channel `padfedchannel`
- Organizaciones corriendo uno o mas peers (típicamente 2)
- Servicio `TLS` con autenticación de cliente
- Servicio `OPERATIONS` opcional en cada nodo
- State database `LevelDB`
- Chaincode `padfedcc` desarrollado en `Golang`
- Un Admin por cada organización que corre nodos
- No se utilizan colecciones privadas de datos, las organizaciones agregadas a la red pueden ver todos los datos del Padrón Federal

---

## Síntesis de las prestaciones disponibles en NS

- Creación de CAs (Certificate Authorities) raíces/intermedias.
- Generación de material cryptográfico para las distintas identidades de los componentes de la organización
- Inicialización de los nodos (peer | orderer)
- Prueba end2end para modo test

Las prestaciones son opcionales y adaptables segun los requerimientos de cada organización.

---

## Requisitos de instalación

### Hardware

- Equipo dedicado, puede ser virtual
- 4 a 8 vCPU
- 8 a 16 GB de RAM
- 1TB GB en disco

### Software

- RHEL, Ubuntu, Debian
- DOCKER 18.09 o superior
- DOCKER-COMPOSE 1.23.1 o superior
- Imágenes `hyperledger/fabric`: La primera vez que corran, los nodos intentarán bajar las siguientes imágenes desde `docker-hub`

| imagen                             | peer | orderer |
| ---------------------------------- | ---- | ------- |
| `hyperledger/fabric-tools 1.4.3`   | x    |         |
| `hyperledger/fabric-peer 1.4.3`    | x    |         |
| `hyperledger/fabric-orderer 1.4.3` | x    | x       |
| `hyperledger/fabric-ccenv 1.4.3`   | x    |         |
| `hyperledger/fabric-baseos 1.4.3`  | x    |         |

Los nodos peers intentarán bajar `fabric-ccenv` y `fabric-baseos` la primera vez que ejecuten el chaincode.

- Binarios de Fabric: Los scripts de instalación intentarán bajar los siguientes binarios desde https://nexus.hyperledger.org/

| binario                            | peer0 | orderer0 |
| ---------------------------------- | ----  | -------  |
| `configtxgen`                      | x     | x        |
| `configtxlator`                    | x     |          |

- `openssl` para la generación del material crpytográfico.
- `jq` para procesamiento de json.
- `cURL`: para bajar los binarios de Fabric y para testear el servicio `OPERATIONS`.

### Networking

- Nodos con IP fija, pública y DNS Name válido en internet
- Puerto accesible desde internet en los peers: `7051/tcp`
- Puerto accesible desde internet en los orderers: `7050/tcp`
- Opcional: puerto para `OPERATIONS` (defualt `9443/tcp`) no expuesto a internet.
- Acceso a los peers y orderers de las restantes organizaciones mediante protocolo `gRPCs` con `TLS`.

## Material criptográfico

Fabric implementa 3 tipos de servicios:

- `MSP`: [Servicio de membresia](https://hyperledger-fabric.readthedocs.io/en/release-1.4/msp.html)
- `TLS`: [Servicio de seguridad para la capa de transporte](https://hyperledger-fabric.readthedocs.io/en/release-1.4/enable_tls.html)
- `OPERATIONS`: (opcional) [Servicio de monitoreo](https://hyperledger-fabric.readthedocs.io/en/release-1.4/operations_service.html)

Las organizaciones que corren nodos trabajan con sus propias entidades emisoras de certificados. Fabric requiere con una CA distinta para cada servicio, o bien, una única CA raíz y CAs intermedias para cada servicio.

Para obtener mas información sobre las características del material criptográfico requerido por Fabric: 
[link ESPECIFICACION DEL MATERIAL CRIPTOGRAFICO](MATERIAL_CRIPTOGRAFICO_ESPECIFICACION.md).

Opcionalmente se puede utilizar `NS` para crear las CAs y/o para generar el material criptográfico (claves y requests CSR) necesario para cada identidad de la organización (nodos, admin y clientes).
[link EMISION_DE_CERTIFICADOS_UTILIZANDO_NS_CAS](EMISION_DE_CERTIFICADOS_UTILIZANDO_NS_CAS.md).

## Opciones de configuración

Antes de comenzar la instalación la organización debe determinar un conjunto de opciones de configuración. Estas opciones se establecen en `NS` moificando el archivo `setup.conf`.

Las opciones son:

| opción              | descripción                                                                                                                                                                                                                                                               |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `MSPID`             | Asignado a la organización (ej: `AFIP`, `ARBA`, `COMARB`, `CBA`, ...). [link ORGANIZACIONES](ORGANIZACIONES.md)                                                                                                                                                                    |
| `DOMAIN`            | Nombre que se utilizará para los nodos (ej: `blockchain-tributaria.arba.gob.ar`)                                                                                                                                                                                          |
| `NODE_NAMESEP`      | Caracter separador entre los prefijos `peer[n]` y el `DOMAIN` para conformar el nombre definitivo de los peers (ej `NODE_NAMESEP` establecido con guión: `peer0-blockchain-tributaria.arba.gob.ar`, establecido con punto: `peer0.blockchain-tributaria.arba.gob.ar`) |
| `CA_MODE`           | Puede ser `ROOTCAS` (una CA raíz para cada servicio) o `INTERMEDIATECAS` (una CA raíz con intermedias para cada servicio)                                                                                                                                                 |
| `OPERATIONS_ENABLE` | `true` \| `false` para indicar si se habilita el servicio `OPERATIONS`                                                                                                                                                                                                     |

A nivel de cada nodo se debe establecer las siguientes opciones:

| opción                     | descripción                                                                                                                                                                                |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `FABRIC_INSTANCE_PATH`     | Directorio donde va a establecerse el entorno de runtime del peer. Default `./fabric-instance` |
| `FABRIC_LEDGER_STORE_PATH` | Directorio donde el nodo persistirá el `ledger` y el `state`. Default `./fabric-storage`                                                                                                   |
| `CRYPTO_STAGE_PATH`        | Directorio que se utiliza durante la instalación para trabajar con el material cryptográfico. Default `./crypto-stage`                                                                     |
| `OPERATIONS_PORT`          | Puerto para el sericio `OPERATIONS` en caso que se habilite. Defualt `9443`                                                                                                               |
`ORDERER_NAME` | Nombre del nodo `orderer0` de la red.
`ORDERER_TLSCA_CRT_FILENAME` | Nombre del pem que contiene el certificado de `TLS` de la organización que correr el `orderer0`. En la la configuración inicial debe ser el certificado de `TLS` de `AFIP`. El archivo debe residir en `./config/`

En caso que se utilice `NS` para generar los requests (Certificate Signed Request) de otras identidades de la organización, se debe establecer las siguientes opciones:

| opción           | descripción                                                                                                                                                                                                                                                                                                                                              |
| ---------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `USERS_BASENAME` | Lista de nombres de aplicaciones clientes separados por un espacio, delimitada entre doble comillas. Ej: `"blockconsumer proxy user1"`. A estos clientes se les generará requests CSR para los servicios de `MSP` y `TLS`. Para obtener los nombres definitivos de los clientes se agrega `@DOMAIN`. Ej: `blockconsumer@blockchain-tributaria.arba.gob.ar` |
| `OPERS_BASENAME` | Lista de nombres de clientes para el servicio `OPERATIONS`. Ej: `"oper1 oper2"`. Para obtener los nombres definitivos de los clientes se agrega `@DOMAIN`. Ej: `oper1@blockchain-tributaria.arba.gob.ar`                                                                                                                                                   |
`ORG_CUIT` | (opcional) CUIT de la organización para setear en el `serialNumber` del `Subject`. Para los certificados emitidos por las CAs de AFIP es una norma.                     |

## Instalación paso a paso

#### PASO 1 - Instalación de peer0

Conectarse al equipo donde va a correr el `peer0` 
(**NOTA:** en `AFIP` la instalación comienza en el equipo `orderer0`).

Copiar la carpeta `padfed-network-setup/src/prod` en un directorio.

`prod` contiene:

- `setup.sh`: script de instalación
- `setup.conf`: archivo de configuración de la instalación.
- `scripts/`: scripts utilizados por `setup.sh`
- `config/`: templates y scripts administrativos

Establecer las opciones de instalación editando el `setup.conf`

Generar los pares key/requests para el material criptográfico del nodo.

    ./setup.sh make_requests peer0

El comando genera pares key/requests en `$CRYPTO_STAGE_PATH/$MSPID-peer0` para el `admin` de la organización y para el `peer0`. Opcionalmente según la configuración establecida en `setup.conf`, tambien generará pares key/requests para aplicaciones y para clientes de `OPERATIONS`.

Asimimo genera una directorio `$MSPID-peer0-crypto-requests` conteniendo exclusivamente los requests generados.

A continuación cada organización según sus propios procedimientos deberá obtener los certificados correspondientes a los requests generados.

Opcionalmente, se puede utilizar `NS` para crear las CAs y emitir los certificados.
[link EMISION DE CERTIFICADOS UTILIZANDO NS CAS](EMISION_DE_CERTIFICADOS_UTILIZANDO_NS_CAS.md).

Una vez emitidos los certificados deben copiarse en `$CRYPTO_STAGE_PATH/$MSPID-peer0`, para lo cual es importante respetar la convención de nombres para el material crytográfico utililizada por `NS`. 
[link MATERIAL CRIPTOGRAFICO - CONVENCION DE NOMRBES DE ARCHIVOS](MATERIAL_CRIPTOGRAFICO_NOMBRES_ARCHIVOS.md).

Inicializar el peer ejecutando el comando:

    ./setup.sh init peer0

El comando realiza las siguientes acciones:

- Organiza el entorno de runtime del `peer0` en el directorio `$FABRIC_INSTANCE_PATH/$MSPID-peer0`. [link ENTORNO DE RUNTIME DEL PEER](ENTORNO_DE_RUNTIME_DEL_PEER.md)
- Genera un archivo `$MSPID-configtx-msp-dir/$MSPID-configtx-msp-dir.[timestamp].tar.xz` conteniendo los certificados necesarios para incorporar la organización al channel del Padrón Federal.
- Genera un directorio `$MSPID-peer0-crypto-admin` conteniendo el material cryptográfico del `admin` de la organización necesario para configurar el `peer1`.
- Corre el docker `peer0` y el docker cli para administración del peer (imagen `fabric-tool`)

Para correr el peer el comando se posiciona en `$FABRIC_INSTANCE_PATH/$MSPID-peer0` y ejecuta el comando `docker-compose up -d`.

Ahora el `peer0` quedó configurado y corriendo en forma autónoma, aun sin conexión al channel del Padrón Federal.

Opcionalmente se puede probar la configuración ejecutando el comando:

    ./setup.sh test peer0

El comando intenta conectar al cli con el `peer0` y ademas, en caso que se haya optado por habilitar el servicio `OPERATIONS`, utiliza `cURL` para invocar al endpoint de health.

#### PASO 2 - Instalación de peer1

El procedimiento de instalación en `peer1` es similar al de `peer0`.

Diferencia: La instalación sobre `peer1` en vez de generar el material criptográfico del `admin`, dado que ya fue generado en `peer0`, va a necesitar que se lo dejemos disponible, copiando el directorio `MSPID-peer0-crypto-admin` desde el `peer0` hacia `peer1`.

#### PASO 3 - Incorporación de la organización al channel del Padrón Federal

La organización debe enviar a la AFIP el archivo `$MSPID-configtx-msp-dir/$MSPID-configtx-msp-dir.[timestamp].tar.xz` generado durante la instalación del `peer0`.

El tar contiene los certificados de las CAs y del Admin de la organización.

La organización debe esperar el OK de AFIP para continuar con el próximo paso.

#### PASO 4 - Joinear los peers al channel

En `peer0` posicionarse en `$FABRIC_INSTANCE_PATH/$MSPID-peer0` y ejecutar el siguiente comando:

    ./ch.join.ch

Repetir el procedimiento en `peer1`.

#### PASO 5 - Instalar el chaincode los peers

En `peer0` posicionarse en `$FABRIC_INSTANCE_PATH/$MSPID-peer0`.

El chaincode esta empaquetado en un `tar.xz` que tiene el siguiemte formato de nombre: `padfed-chaincode-$VERSION.tar.xz`

Ej: `padfed-chaincode-0.7.0.tar.xz`

Copiar el chaincode en `$FABRIC_INSTANCE_PATH/$MSPID-peer0/gopath/download`.

Ejecutar el siguiente comando:

    ./cc.install.sh <VERSION>

Repetir el procedimiento en `peer1`.

#### PASO 6 - Configurar aplicaciones y clientes de OPERATIONS

Las aplicaciones (ej: `hlfproxy`, `blockconsumer`, ...) para conectarse a la red requieren:

- su par clave/certificado para `MSP`
- su par clave/certificado para `TLS`
- certificados de la CA de `TLS` de los nodos a los cuales se conectará

En caso que se habilite `OPERATIONS` los clientes de monitoreo requieren:

- su par clave/certificado para `OPERATIONS`.

En caso que no se hayan generado sus pares key/requests en el `PASO 1`, se puede utilizar `NS` para generar los requests. Se debe copiar el proyecto en un equipo linux con `openssl`.

Establecer en el `setup.conf` las opciones `USERS_BASENAME` y `OPERS_BASENNAME` (ver explicación en el `PASO 1`)

Ejecutar el comando:

    ./setup.sh make_requests clients

El comando genera pares key/requests en `$CRYPTO_STAGE_PATH/$MSPID-clients` para las aplicaciones clientes y para los usuarios del servicio `OPERATIONS` establecidos en el `setup.conf`.

Asimimo genera un directorio `$MSPID-clients-crypto-requests` conteniendo los requests generados.

#### PASO 7 - Establecer el peer0 como el anchor peer

En `peer0` posicionarse en `$FABRIC_INSTANCE_PATH/$MSPID-peer0` y ejecutar el comando:

    ./ch.anchor.peer.update.ch

---

### Test end2end

Para realiar una instalación de prueba completa se puede utilizar el comando

    ./setup.sh end2end peer0

 El comando crea las CAs, genera el material criptográfico necesario para el peer, crea el entorno de ejecución del peer, lo corre y verifica que quede activo.
