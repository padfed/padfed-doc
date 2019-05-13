# PADFED Setup de la Testnet

## Introducción

El entregable network-setup-X.Y.Z.jar (en adelante network-setup) disponible en Nexus, contiene scripts que permiten realizar el setup de una Testnet de Blockchain Hyperledger Fabric v1.4.0 para Padrón Federal.

network-setup esta preparado para implementar una red con la siguiente configuración:

    • consorcio integrado por las organizaciones AFIP, ARBA, COMARB y MULTIORG
    • AFIP corriendo un nodo ORDERER (Solo)
    • AFIP, ARBA y COMARB corriendo 2 nodos PEERs, cada una
    • MULTIORG corriendo exclusivamente aplicaciones
    • nodos conectados mediate protocolo gRPC con TLS

---

## Actores que participan del proceso de Setup

Este instructivo en el punto 4 tiene indicaciones para los siguientes actores:

* Operaciones de AFIP
* Grupo Blockchain de AFIP
* Operaciones de ARBA y COMARB

---

## Contenido de network-setup

network-setup contiene los siguientes scripts:

* /src/qa/create.network.sh: genera una estructura con un directorio para cada nodo de la red
* /src/qa/clean.network.sh: elimina la estructura de directorios creada por create.network.sh
* /bin/hlf-1.4.0/bootstrap.sh: obtiene binarios de HLF requeridos para el setup, cryptogen y configtxgen
* /bin/hlf-1.4.0/get-docker-image.sh: permite descargar imágenes dockers de HLF de manera anticipada a la corrida del docker 
  
Asimismo, la estructura de los directorios generada por create.network.sh contiene los siguientes archivos:

* docker-compose.yaml: para correr el orderer o el peer, según corresponda
* ch.create.sh: crea el canal (1)
* ch.join.sh: joinea un peer al canal
* ch.add.anchor.sh: Actualiza canal definiendo un anchor peer (2)

* cc.download.sh: obtiene el chaincode desde Nexus, solo funciona en los nodos de AFIP
* cc.install.sh: instala el chaincode
* cc.instantiate.sh: instancia el chaincode (1)
* cc.upgrade.sh: actualiza el chaincode (1)
* certificados y pks requeridos para el funcionamiento del nodo (MSP y TLS)
* certificados y pks requeridos para conectarse como admin en cada nodo
* certificados y pks requeridos para que las aplicaciones (ej: block-consumer, hlf-proxy) puedan acceder a la testnet

_(1) Solamente en AFIP.PEER0_    
_(2) Solamente en los PEER0_

Estos directorios deben ser distribudos a cada uno de los nodos.

## Generación de certificados para MSP y TLS

create.network.sh utiliza el binario cryptogen para generar certificados y pks para MSP y TLS. No requiere gestionar certificados con ninguna CA.

##  Objetivos de la Testnet

Los principales objetivos de esta primera versión de la Testnet son:

* experimentar la complejidad a nivel de networking que puede tener el setup de una red con nodos distribuidos en distintos datacenters (firewalls, proxy, dns)
* relevar problemas de configiración y soluciones
* realizar pruebas de performance generando y consumiendo transacciones sobre una red con nodos distribuidos en distintos datacenters

Queda fuera del alcance de este instructivo la configuración de las aplicaciones.

## Convenciones

| Nombre | Desc |
| -------- | -------- |
| HLF     | Hyperledger Fabric |
| $INSTALL_HOME     | Directorio donde se copio el entregable network-setup-X.Y.Z.jar |
| RN     | Release Notes |
| ``<chaincode-version>``     | Versión del chaincode indicada en el RN |

### Nodos:

| # | Perfil | Data Center | FQDN | Nombre corto para este doc |
| --- | -------- | -------- | -------- | --- |
| 1 | ORDERER     | AFIP     | orderer0.orderer.blockchain-tributaria.testnet.afip.gob.ar     | ORDERER |
| 2 | PEER     | AFIP     | peer0.blockchain-tributaria.testnet.afip.gob.ar     | AFIP.PEER0 |
| 3 | PEER     | AFIP     | peer1.blockchain-tributaria.testnet.arba.gob.ar     | AFIP.PEER1 |
| 4 | PEER     | ARBA     | peer0.blockchain-tributaria.testnet.arba.gob.ar :warning: | ARBA.PEER0 |
| 5 | PEER     | ARBA     | peer1.blockchain-tributaria.testnet.arba.gob.ar :warning: | ARBA.PEER1 |
| 6 | PEER     | COMARB     | peer0.blockchain-tributaria.testnet.comarb.gob.ar     | COMARB.PEER0 |
| 7 | PEER     | COMARB     | peer1.blockchain-tributaria.testnet.comarb.gob.ar     | COMARB.PEER1 |

> [2019.05.13] A requerimiento de ARBA el nombre de sus nodos serán: peer0.blockchain-tributaria.test.arba.gob.ar y peer1.blockchain-tributaria.test.arba.gob.ar 

## Prerequisitos

### Configuración de los servidores:

* 4 a 8 vCPU
* 8 a 16 GB de RAM
* 500 GB en disco
* IPs públicas accesibles desde internet

### Software:

| SW | Equipo |
| -------- | -------- |
| RHEL, Ubuntu, Debian     | Todos los equipos  |
| DOCKER 18.09 o superior     | Todos los equipos  |
| DOCKER-COMPOSE 1.23.1 o superior     | Todos los equipos  |
| cURL     | AFIP.PEER0 y AFIP.PEER1  |
| md5sum     | AFIP.PEER0 y AFIP.PEER1  |

### Requerimientos de Ciberseguridad:

* Version de Sistema Operativo actualizada
* Versión de OpenSSH actualizada
* Servicio RPC deshabilitado

### Networking: Red donde deben instalarse los nodos de AFIP:

Los equipos ORDERER, AFIP.PEER0 y AFIP.PEER1 debe desplegarse en la red de Homologacion expuesta a internet.

### Networking: Firewall:

Deben habilitarse los siguientes accesos:

| Origen | Destino | Puertos |
| -------- | -------- | --- |
| Internet     | ORDERER     | 7050/tcp |
| Internet     | PEERs     | 7051/tcp |

### Networking: Acceso desde los nodos AFIP hacia los nodos externos

Los equipos ORDERER, AFIP.PEER0 y AFIP.PEER1 deben acceder a endpoints expuestos en los Peers de ARBA y COMARB, puertos 7051/tcp.

Estas conexiones deben ser verificadas posteriormente al paso
4.4 despues de que ARBA y AFIP logren correr sus respectivos PEERs.

### Accesos a repositorios internos

Los equipos ORDERER, AFIP.PEER0 y AFIP.PEER1 deben tener habilitado el acceso mediante protocolo HTTPS (puerto 443) a los siguientes recursos:

| Recurso | Objetivo |
| -------- | -------- |
| https://nexus.hyperledger.org  | Obtener los binarios HLF cryptogen y configtxge |
| https://hub.docker.com  | Obtener imágenes dockers del ORDERER y del PEER |
| https://nexus.cloudint.afip.gob.ar  | Obtener chaincode en los equipos AFIP.PEER0 y AFIP.PEER1 (opcional) |

### Binarios HLF v1.4.0: cryptogen y configtxgen

Estos binarios solamente se requieren en el equipo de AFIP donde se ejecute la tarea ``Generación de configuraciones en AFIP``, explicada mas adelante en este doc.

Para obtener los binarios específicos de la plataforma se puede ejecutar:

```
$ $INSTALL_HOME/bin/hlf-1.4.0/bootstrap.sh -d
```

Si se ejecuta sin argumentos bajará también las imágenes dockers oficiales de HLF v1.4.0.

Ambos binarios deben quedar instalados en $INSTALL_HOME/bin/hlf-1.4.0 y $INSTALL_HOME/bin/hlf-1.4.0.
$INSTALL_HOME/bin debe quedar incluido en el PATH.

### Imágenes Docker HLF v1.4.0.

Cuando se ejecute por primera vez en cada nodo, docker-compose intentará bajar las 3 imágenes requeridas: fabric-tools, fabric-peer y fabric-orderer.

Como alternativa se puede anticipar la descarga de las imágenes ejecutando:

```
$ $INSTALL_HOME/bin/hlf-1.4.0/get-docker.images.sh
```
El script baja todas las imágenes oficiales HLF v1.4.0, inclusive algunas que no serán utilizadas.

---

## Creación de la red

1. Generación de configuraciones en AFIP

    Actor: Operaciones de AFIP

    1.1. Conectarse por SSH a alguno de los 3 equipos ORDERER o PEERs

    Este paso podría realizarse en un equipo que cuente con el software requerido (ver [Software](#software)) aunque finalmente no integre la red HLF.

    1.2. Extraer el contenido de network-setup en $INSTALL_HOME

    Se crearán los siguientes directorios:

    ```
    $INSTALL_HOME/bin/hlf-1.4.0
    $INSTALL_HOME/scr/dev  (esté directorio se puede eliminar)
    $INSTALL_HOME/scr/qa
    ```

    1.3. En $INSTALL_HOME/src/qa ejecutar

    ```
    $ ./create.network.sh
    ```

    El script creará los siguientes directorios:

    ```
    $INSTALL_HOME/src/qa/deploy/nodes/orderer.orderer0
    $INSTALL_HOME/src/qa/deploy/nodes/afip.peer0
    $INSTALL_HOME/src/qa/deploy/nodes/afip.peer1
    $INSTALL_HOME/src/qa/deploy/nodes/arba.peer0
    $INSTALL_HOME/src/qa/deploy/nodes/arba.peer1
    $INSTALL_HOME/src/qa/deploy/nodes/comarb.peer0
    $INSTALL_HOME/src/qa/deploy/nodes/comarb.peer1
    $INSTALL_HOME/src/qa/deploy/nodes/multiorgs
    ```

    1.4. Copiar los directorios

    * orderer.orderer0 al equipo ORDERER
    * afip.peer0 al equipo AFIP.PEER0
    * afip.peer1 al equipo AFIP.PEER1

    1.5. Generar un zip con el contenido del directorio $INSTALL_HOME/src/qa y entregarlo al Grupo Blockchain de AFIP.

2. Startup de la red en AFIP

    Actor: Operaciones de AFIP (Continua)

    2.1 Opcionalmente modificar los .env de los directorios orderer0.orderer, afip.peer0 y afip.peer01 en cada uno de los equipos para indicar el path raiz donde el nodo guardará los repositorios para el Legder y el State. El directorio debe existir.

    Ejemplo:
    ```
    FABRIC_LEDGER_STORE_PATH=/data/blockchain
    ```
    2.2. En el directorio orderer0.orderer del equipo ORDERER ejecutar:

    ```
    $ docker-compose up -d
    ```

    2.3. En el directorio afip.peer0 del equipo AFIP.PEER0 ejecutar:

    ```
    $ docker-compose up -d
    $ ./ch.create.sh
    $ ./ch.add.anchor.sh
    $ ./cc.download.sh <chaincode-version>
    $ ./cc.install.sh <chaincode-version>
    $ ./cc.instantiate.sh <chaincode-version>
    ```

    2.4. En el directorio afip.peer1 en el equipo AFIP.PEER1 ejecutar:

    ```
    $ docker-compose up -d
    $ ./ch.join.sh
    $ ./cc.download.sh <chaincode-version>
    $ ./cc.install.sh <chaincode-version>

    ```

3. Delivery desde AFIP hacia ARBA y COMARB

    Actor: Grupo Blockchain de AFIP

    3.1. Verificar que se puedan acceder mediante sus FQDN los nodos de AFIP

    3.2. Obtener el chaincode a instalar ejecutando:

    ```
    $ $INSTALL_HOME/src/qa/config/cc.download.sh <chaincode-version>
    ```

    3.3. Descomprir el zip recibido en paso 4.1.10 que contiene la estructura de directorios generada por network-setup.

    3.4. En los directorios arba.peer0, arba.peer1, comarb.peer0 y comarb.peer1 copiar el chaincode obtenido en el paso 3.2 debajo de /gopath/download/

    Ejemplo:

    ```
    /qa/deploy/nodes/arba.peer0/gopath/download/padfed-chaincode-0.2.5.tar.xz
    ```

    3.5. Entregar un zip con el contenido de los directorios arba.peer0 y arba.peer1 a ARBA

    3.6. Entregar un zip con el contenido de los directorios comarb.peer0 y comarb.peer1 a la COMARB

4. Startup de los nodos de ARBA y COMARB

    Actor: Operaciones de [ARBA|COMARB]:

    4.1. Verificar que los nodos de AFIP se puedan acceder mediante sus FQDN

    4.2. En cada equipo peer: copiar el correspondiente zip enviado desde AFIP y descomprimirlo

    4.3. Opcionalmente modificar los .env del [arba|comarb].[peer0|peer1] para indicar el path raiz donde el nodo guardará los repositorios para el Legder y el State. El directorio debe existir.

    Ejemplo:
    ```
    FABRIC_LEDGER_STORE_PATH=/data/blockchain
    ```

    4.4. En el directorio [arba|comarb].[peer0|peer1] ejecutar:

    ```
    $ docker-compose up -d
    $ ./ch.join.sh
    * ./ch.add.anchor.sh (1)
    $ ./cc.install.sh <chaincode-version>
    ```

    _(1) Solamente en los peer0 que van a ser los anchor peers de cada organización_

---

## Actualización del chaincode.

Una vez que la red queda funcionado, eventualmente se requerirá actualizar el chaincode padfedcc.

La nueva versión del chaincode deberá

* instalarser en todos los peers de la red
* instanciarse exclusivamente en AFIP.PEER0.

Los Operadores recibirá una RN solicitando actualizar una determinada versión del chaincode conteniendo:

* ``<chaincode-version>``, ej ``0.4.3``
* URL del artefacto tar.xz en Nexus, ej:
    ```
    https://nexus.cloudint.afip.gob.ar/nexus/repository/padfed-bc-raw/padfed/padfed-chaincode/0.4.3/padfed-chaincode-0.4.3.tar.xz
    ```
* archivo tar.zx, requerido para ARBA y COMARB dado que no tienen acceso al Nexus de AFIP, ej: ``padfed-chaincode-0.4.3.tar.xz``

### Actualización del chaincode en AFIP

Si los peers no tienen conexión al Nexus, el Operador debe descargar en su PC el archivo tar.xz desde la URL indicada en el RN y copiarlo a los directorios gopath/download en cada peer.

#### Actualización del chaincode en AFIP.PEER0

El Operador debe conectarse por ssh al peer y ejecutar:

```
./cc.download.sh <chaincode-version> (1)
./cc.install.sh <chaincode-version>
./cc.upgrade.sh <chaincode-version>
```
_(1) si no tiene conexion al Nexus, en vez de ejecutar cc.donwload.sh debe copiar el tar.xz en gopath/download_

#### Actualización del chaincode en AFIP.PEER1

El Operador debe conectarse por ssh al peer y ejecutar:

```
./cc.download.sh <chaincode-version> (1)
./cc.install.sh <chaincode-version>
```
_(1) si no tiene conexion al Nexus, en vez de ejecutar cc.donwload.sh debe copiar el tar.xz en gopath/download_

### Actualización del chaincode los peers de ARBA y COMARB

El Operador debe copiar el tar.xz del chaincode a los directorios gopath/download en cada peer.

El Operador debe conectarse por ssh en cada peer y ejecutar

```
./cc.install.sh <chaincode-version>
```