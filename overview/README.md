# PADFED - Blockchain - Visión General

## Introducción

El objetivo del Padrón Federal es implementar un sistema único de actualización del padrón de contribuyentes de carácter federal para evitar las múltiples inscripciones y alcanzar un tratamiento ordenado para los cambios de jurisdicción, con alcance tanto de contribuyentes locales de Ingresos Brutos  como de Convenio Multilateral.

El sistema permite a los contribuyentes efectuar la inscripción, modificación de datos y cese respecto del Impuesto sobre los Ingresos Brutos desde una webapp de AFIP, al igual que hacen hoy respecto a los impuestos nacionales, evitando la doble carga de información y mejorando la calidad de datos sobre los contribuyentes que tienen las administraciones tributarias provinciales.

Participan del proyecto las organizaciones: AFIP, la Comision Arbitral del Convenio Multilateral (COMARB) y las administraciones tributarias provinciales (ATP) que voluntariamente adhieran al mismo.

Referencia:
https://www.ca.gob.ar/hacia-un-registro-unico-tributario-a-nivel-federal

## Blockchain

En términos generales una Blockchain es un registro inmutable de transacciones replicado en una red de nodos. Cada nodo mantiene una copia del registro secuencial inmutable de transacciones previamente validadas mediante un protocolo de consenso. Las transacciones quedan agrupadas en bloques que incluyen un hash que vincula cada bloque con su precedente conformando una cadena de bloques.

En el Padron Federal se utiliza tecnología de Blockchain para mantener una base de datos conteniendo la información del padrón de contribuyentes, compartida entre las organizaciones participantes, logrando:
- la disponibilidad en casi tiempo real de los cambios que se producen sobre la información compartida,
- la garantía de inmutabilidad de los registros, fecha y origen de cada transacción,
- la integridad transaccional de la información, evitando la generación de incoherencias por fallas de sistemas o interrupción del servicio,
- el consenso entre los participantes sobre cual es el contenido histórico y el estado actual de la información compartida.
- la garantía de la auditabilidad del sistema,
- la eliminación de la necesidad de generar procesos periódicos o eventuales de conciliación o de reenvíos de registros para resolver problemas de perdida de información.

## Como participan las distintas organizaciones en la Blockchain ?

Algunas de las organizaciones, que dispongan de infraestructura de IT adecuada, van a correr uno o mas nodos de Blockchain en su data center. Cada uno de estos nodos mantendrán un copia actualizada con los datos del padrón.

Para facilitar el gobierno de la red, inicialmente debieran ser pocas las organizaciones que corran nodos, idealmente entre 3 y 5. Esta cantidad progresivamente se puede ir extendiendo.

Las organizaciones candidatas a correr nodos son AFIP, COMARB, ARBA, **XXX**, **YYY**.

Tanto las organizaciones que corran nodos en su data center, como las que no lo hagan, van a poder acceder a los mismos servicios que ofrece la Blockchain. Estos servicios permitirán:
- registrar transacciones que agregan o modifican datos del padrón 
- consultar el registro de transacciones
- consultar el estado actual de la representación de cada contribuyente, que resulta de los sucesivos cambios aplicados por las transacciones.

## Plataforma de Blockchain utilizada 

La plataforma de Blockchain utilizada para el Padrón Federal es Hyperledger Fabric. Fabric es un proyecto de código abierto dentro de la iniciativa Hyperledger de la Fundación Linux. Permite implementar una Blockchain de tipo privada y permisionada, de propósito general, no orientada a criptomonedas, de alta performance.

https://hyperledger-fabric.readthedocs.io

### Componentes de una red de Blockchain Fabric

- Aplicaciones clientes: 

    Son las aplicaciones que interactúan con la red de Blockchain conectándose a algunos de sus nodos. Crean transacciones y las envían a algunos de los nodos para que sean ejecutadas por los Smart Contract (Chaincodes) y posteriormente procesadas por toda la red.

- Chaincode:
 
    En Fabric a los Smart Contract se los denomina "Chaincode". Un chaincode expone un conjunto de funciones que pueden ser invocadas por las transacciones para crear, modificar o consultar los datos que se registran en la Blockchain. 
    
    Fabric permite que el chaincode sea escrito en lenguajes de programación convencionales como Golang, Node o Java. 

    https://hyperledger-fabric.readthedocs.io/en/release-1.4/smartcontract/smartcontract.html
    
- Transacciones: 

    Las transacciones son creadas por las aplicaciones clientes. Cada transacción conforma una invocación a una función de un chaincode. A esta invocación se la denomina Propousal. La aplicación deben enviar el Propousal hacia uno o mas nodos tipo Peer, dependiente de la Política de Respaldo establecida en la Blockchain. Deben recopilar las respuestas obtenidas y reenvía la transacción con las respuestas a un nodo de tipo Orderer. El Orderer agrega la transacción a un bloque y enviá el bloque a todos los nodos de la red para que lo validen y actualicen la Blockchain.

    https://hyperledger-fabric.readthedocs.io/en/release-1.4/txflow.html

- Política de Respaldo de Transacciones (Endorserment Policy):

    La Política de Respaldo de Transacciones, mediante operadores lógicos (AND, OR), establece cuales organizaciones deben respaldar a las transacciones de un chaincode.

    https://hyperledger-fabric.readthedocs.io/en/release-1.4/endorsement-policies.html

- Peers: 
  
    Son los nodos encargados de ejecutar las funciones implementadas en los chaincodes (respaldar transacciones) y de mantener una copia del Ledger y del State. Eventualmente se puede correr un Nodo que no tenga instalado chaincodes, dedicado exclusivamente a mantener copias del Ledger y del State.

    https://hyperledger-fabric.readthedocs.io/en/release-1.4/peers/peers.html

- Orderers: 
  
    Son los nodos encargados de generar bloques de transacciones y de enviarlos a los nodos Peers para su validación y confirmación.

    https://hyperledger-fabric.readthedocs.io/en/release-1.4/arch-deep-dive.html#ordering-service-nodes-orderers

- Channels:

    Fabric permite establecer subredes privadas entre algunos de los participantes de la Blockchain con el proposito de disponer de transacciones privadas y confidenciales.

    https://hyperledger-fabric.readthedocs.io/en/release-1.4/channels.html

- Ledger: 
  
    Cadena de bloques replicada en los nodos de la red. Cada bloque contiene un conjunto de transacciones. Cada transacción contiene un conjunto de registros leídos (readSet) y de registros modificados (writeSet). Fabric persisten el Ledger en un conjunto de archivos cada uno de 64 MB.

    https://hyperledger-fabric.readthedocs.io/en/release-1.4/ledger/ledger.html

- State: 
  
    Base de datos de tipo Key-Value-Store (KVS) que se mantiene actualizada en los Peers. Contiene la versión vigente de cada objeto registro en la Blockchain. Cada objeto se identifica con una KEY y tiene un VALUE que típicamente en formato JSON. Fabric permite utilizar como KVS una base de datos LevelDB o CouchDB. La implementación de Fabric ofrecida por Oracle utiliza Berkeley DB. 

    https://hyperledger-fabric.readthedocs.io/en/release-1.4/ledger/ledger.html#world-state

    https://hyperledger-fabric.readthedocs.io/en/release-1.4/arch-deep-dive.html#state

- Servicio MSP: 

    Es el servicio encargado de manejar la membresía en la red. Identifica a las organizaciones miembros de la red y a todos los componentes y actores de la red que posee cada organización (aplicaciones, usuarios administradores y nodos). Cada componente se identificar con un un par de clave privada y certificado X509 emitido por la CA Raíz de la organización a la que pertenece. 

    https://hyperledger-fabric.readthedocs.io/en/release-1.4/membership/membership.html
    
- TLS: 
  
    Los nodos Fabric resuelven TLS para lo cual cada nodo debe disponer de un certificado X509 emitido por la CA Raiz de la organización a la que pertenecen. Preferiblemente la CA Raíz de TLS debe ser distinta que la de MSP.

    https://hyperledger-fabric.readthedocs.io/en/release-1.4/enable_tls.html 

Todos los componentes ejecutables de una Red Fabric están dockerizados. Inclusive cada chaincode corre en su propio docker.

## Configuación de la Red Fabric del Padrón Federal

| Componente | Descripcion |
| --- | --- |
| Organizaciones con aplicaciones clientes | Potencialmente 26: AFIP, COMARB y 24 ARPs |
| Cantidad de organizaciones corriendo nodos Peers | Inicialmente entre 3 y 5: AFIP, COMARB, ARBA, ???  |
| Cantidad de nodos Peers | Inicialmente entre 6 y 10 (dos por cada organización que corra Peers) |
| Nodos Orderer | Inicialmente un solo nodo corriendo en AFIP (configurado en modo Solo). |
| Channel | Inicialmente un solo channel, denominado ``padfedchannel`` |
| Chaincode | Inicialmente un solo chaincode, denominado ``padfedcc`` |
| Política de Respaldo de Transacciones | A definir por el consorcio. |
| CA Raices | Dos para cada organización que corra nodos. Una para emitir los certificados que MSP y la otra TLS. Las organizaciones que solamente corren aplicaciones comparten un mismo par de CA Raíces gestionada por AFIP (organización ficticia MORG "Multi Organismos" |
| Testnet | Para el ciclo de desarrollo y pruebas se requiere  implementar una Testnet que debe tener por lo menos: 2 Organizaciones, 4 Peers y un Orderer 

[Ver Diagrama](https://www.lucidchart.com/documents/embeddedchart/9dbda4f3-e60a-4071-a6db-faa10945d8b8)

## Configuación equipos Peers:

### Hardware

- 4 a 8 vCPU
- 8 a 16 GB de RAM
- 500 GB en disco

### Software

- RHEL, Ubuntu, Debian   
- DOCKER 18.09 o superior    
- DOCKER-COMPOSE 1.23.1 o superior   

### Networking

- IPs públicas accesibles desde internet
- Puerto accesible desde internet en nodos Peers: 7051/tpc
- Puerto accesible desde internet en nodos Orderer: 7050/tcp
- Protocolo gRPC sobre TCP con TLS
- Opcional: ssh para administración interna
- Opcional: https para servicios de NoCs interno (salud, métricas, log)

## Chaincode

En principio en la Blockchain del Padron Federal se implementará un único Chaincode denominado denominado ``padfedcc`` desarrollado en Golang que ofrecerá funciones para actualizar y consultar el padrón de contribuyentes.

Las funciones de actualización tendrán un mecanismo de control de acceso (ACL) basado en el identificador MSP de la aplicación que genera la transacción.

La especificación de la interfase del chaincode está disponible en https://github.com/padfed/padfed-doc/tree/master/chaincode

## Modelo de Datos

El chaincode ``padfedcc`` mantiene actualizado un registro por cada componente de una persona. Esta desagregación por componentes permite generan transacciones mas pequeñas conteniendo solamente los componentes que sufren algun cambio en cada transacción. Cada registro contiene un key y un value en formato json.

La especificación del modelo de datos está disponible en https://github.com/padfed/padfed-doc/tree/master/model

## Aplicaciones de Integración desarrolladas por AFIP

El equipo de Blockchain de AFIP desarrolló dos aplicaciones que facilitan la integración entre los sistemas informáticos de las organizaciones y los servicios de la Blockchain. Las imágenes de las aplicaciones están disponibles en Docker Hub para que puedan ser descargadas y utilizadas opcionalmente por las organizaciones miembros de la red. 

Las aplicaciones son agnósticas al negocio. Pueden utilizarse en cualquier red Fabric.

| Aplicación | Descripción |
| --- | --- |
| block-consumer | Lee y procesa bloques de un determinado channel de una Blockchain. Desde cada bloque procesado extrae las transacciones que contiene y los datos modificados (writeSet) y guarda la información en una base de datos Oracle o PostgreSQL. Las organizaciones podrán utilizar este componente para mantener actualizada su propia de base de datos de Padrón. Disponible en https://cloud.docker.com/u/padfed/repository/docker/padfed/block-consumer |
| hlf-proxy | Expone como API Rest un método que permite invocar a las funciones del chaincode. Disponible en https://cloud.docker.com/u/padfed/repository/docker/padfed/bc-proxy |

[Ver Diagrama](https://www.lucidchart.com/documents/embeddedchart/d93d7832-62da-404e-986f-83051b878a01)

## Servicio HLD-Admin

Webapp desarrollada por AFIP que permitirá 
- solicitar ceritificados de MSP y de TLS para las organizaciones que solamente corren aplicaciones,
- gestionar el despliegue del chaincode

Esta aplicación aun no esta dispobible.
